# ==============================
# 📌 RANDOM FOREST TRAINING - WILDFIRE FBFM MODEL
# ==============================

# 📢 SETUP: Define your working directory (optional)
# setwd("YOUR/WORKING/DIRECTORY")  # Change this if needed

# ✅ Load required libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(terra, dplyr, caret, randomForest, doParallel, pbapply)

# ==============================
# 📌 USER-DEFINED FILE PATHS
# ==============================
tiff_path <- file.path("data", "input_tiff.tif")  # 🔹 Change to your TIFF file path
output_model_path <- file.path("models", "rf_model_combined.rds")  # 🔹 Output for RF model

# ✅ Check if the TIFF file exists
if (!file.exists(tiff_path)) stop("❌ ERROR: The TIFF file does not exist. Please check the file path!")

# ==============================
# 📌 STEP 1: Load the Original TIFF File
# ==============================
cat("📢 Loading TIFF file from:", tiff_path, "\n")
tiff_data <- terra::rast(tiff_path)

# ==============================
# 📌 STEP 2: Convert TIFF to Data Frame
# ==============================
cat("📢 Converting TIFF to dataframe...\n")
data <- terra::as.data.frame(tiff_data, xy = TRUE) %>%
  mutate(
    CC_fuelid = ifelse(CH_fuelid == 0, 0, CC_fuelid)  # Ensure CC_fuelid is properly adjusted
  ) %>%
  na.omit() %>%  # Remove rows with missing values
  filter(FBFM != -9999) %>%  # Exclude missing FBFM values
  droplevels()  # Clean factor levels

# ==============================
# 📌 STEP 3: Exclude Small Classes
# ==============================
min_class_size <- 10  # Minimum number of observations for inclusion
filtered_data <- data %>%
  group_by(FBFM) %>%
  filter(n() >= min_class_size) %>%  # Exclude classes with fewer than 10 observations
  ungroup() %>%
  droplevels()

# ==============================
# 📌 STEP 4: Stratified Sampling (10% of Data)
# ==============================
set.seed(123)
subset_data <- filtered_data %>%
  group_by(FBFM) %>%
  slice_sample(prop = 0.1) %>%
  ungroup() %>%
  droplevels()

# ✅ Check the class distribution
cat("📢 Class distribution after filtering and sampling:\n")
print(table(subset_data$FBFM))

# ==============================
# 📌 STEP 5: Define Predictors and Response
# ==============================
predictors <- c("Elevation", "Slope", "Aspect", "CC_fuelid", "CH_fuelid", "Type_fuelID", "Crops")
response <- "FBFM"

# ==============================
# 📌 STEP 6: Parallel Processing Setup
# ==============================
num_cores <- parallel::detectCores() - 2  # Reserve 2 cores for system
cl <- makeCluster(num_cores)
registerDoParallel(cl)

# ==============================
# 📌 STEP 7: Train Random Forest in Batches (100 Trees Each)
# ==============================
batch_size <- 100
num_batches <- 5
rf_model <- NULL

for (i in 1:num_batches) {
  cat("\n📢 Training batch", i, "of", num_batches, "with", batch_size, "trees...\n")
  
  # Train the batch model
  batch_model <- randomForest(
    as.formula(paste("FBFM ~", paste(predictors, collapse = " + "))),
    data = subset_data,
    ntree = batch_size
  )
  
  # Combine batches
  if (is.null(rf_model)) {
    rf_model <- batch_model
  } else {
    rf_model <- randomForest::combine(rf_model, batch_model)
  }
  
  cat("✅ Batch", i, "completed.\n")
}

# ==============================
# 📌 STEP 8: Save the Trained Model
# ==============================
cat("📢 Saving the trained RF model to:", output_model_path, "\n")
saveRDS(rf_model, file = output_model_path)

# ==============================
# 📌 STEP 9: Cleanup and Display Model
# ==============================
stopCluster(cl)
registerDoSEQ()

cat("✅ Model training complete! Summary:\n")
print(rf_model)