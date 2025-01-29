# Set the working directory
# setwd("YOUR/WORKING/DIRECTORY")

# Load required libraries
if (!require("pacman")) install.packages("pacman")
pacman::p_load(terra, dplyr, caret, randomForest)

# Define file paths as below

# User-defined paths

original_tiff_path <- file.path("data", "input_tiff.tif")  # Replace with your file path
model_path <- file.path("models", "rf_model_combined.rds")  # Path to saved RF model
output_tiff_path <- file.path("output", "predicted_FBFM_layers.tif")  # Output file path


# ✅ Check if files exist before proceeding
if (!file.exists(original_tiff_path)) stop("❌ ERROR: The TIFF file does not exist. Please check the file path!")
if (!file.exists(model_path)) stop("❌ ERROR: The Random Forest model file does not exist!")


# 📌 STEP 1: Load the Original TIFF File
# ==============================
cat("📢 Loading TIFF file from:", original_tiff_path, "\n")
tiff_data <- terra::rast(original_tiff_path)

# ==============================
# 📌 STEP 2: Load the Trained RF Model
# ==============================
cat("📢 Loading RF model from:", model_path, "\n")
rf_model <- readRDS(model_path)

# ==============================
# 📌 STEP 3: Convert TIFF to Data Frame
# ==============================
data <- terra::as.data.frame(tiff_data, xy = TRUE) %>%
  mutate(
    CC_fuelid = ifelse(CH_fuelid == 0, 0, CC_fuelid)  # Adjust CC_fuelid as needed
  )

# ==============================
# 📌 STEP 4: Identify Missing FBFM Values (-9999) for Prediction
# ==============================
data_to_predict <- data %>%
  filter(FBFM == -9999) %>%  # Select rows where FBFM is missing
  select(-FBFM)  # Remove FBFM since we are predicting it

# ✅ Ensure there are missing values to predict
if (nrow(data_to_predict) > 0) {
  
  cat("📢 Predicting missing FBFM values...\n")
  
  # ==============================
  # 📌 STEP 5: Predict FBFM Values
  # ==============================
  predicted_values <- predict(rf_model, newdata = data_to_predict)
  
  # ==============================
  # 📌 STEP 6: Merge Predicted Values Back
  # ==============================
  data$FBFM[data$FBFM == -9999] <- as.numeric(as.character(predicted_values))
  
  # ==============================
  # 📌 STEP 7: Convert Data Frame Back to Raster
  # ==============================
  updated_tiff <- terra::rast(data, type = "xyz")  # Create raster from x, y, and FBFM values
  
  # ==============================
  # 📌 STEP 8: Save Updated TIFF File
  # ==============================
  cat("📢 Saving the updated TIFF to:", output_tiff_path, "\n")
  terra::writeRaster(updated_tiff, output_tiff_path, overwrite = TRUE)
  
  cat("✅ Predicted FBFM raster saved successfully!\n")
  
} else {
  cat("⚠️ No missing FBFM values (-9999) found for prediction. Skipping model application.\n")
}