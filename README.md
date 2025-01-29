Generating FBFM Fuel Types Using RF Model
This repository contains two R scripts to generate Fire Behavior Fuel Models (FBFM) using Random Forest (RF) models. The process involves training the RF model and applying it to a TIFF layer to predict missing FBFM values.

Files in the Repository
wildfire_data_analysis with 500 trees - sharing.R:

Script for training the Random Forest model using 500 trees in batches.
Outputs a trained RF model saved as .rds for later use.
Applying RF model and Saving Predicted TIFF.R:

Script for applying the trained RF model to a TIFF file.
Predicts missing FBFM values and generates a new TIFF file with complete data.
How to Use These Scripts
Prerequisites
Software:
R (version 4.0 or later)
RStudio (optional but recommended)
Packages:
pacman (manages dependencies)
terra, dplyr, caret, randomForest, doParallel, pbapply
Data:
Original TIFF file (modified_layers_canada.tif).

Step 1: Train the RF Model
Open wildfire_data_analysis with 500 trees - sharing.R in R or RStudio.
Modify the following placeholders if needed:
Set your working directory: setwd("path/to/your/directory").
Update the path to your TIFF file: new_file_path.
Run the script:
This script trains the Random Forest model in 5 batches of 100 trees each.
The trained model is saved as rf_model_combined.rds.

Step 2: Apply the RF Model to Predict Missing FBFM
Open Applying RF model and Saving Predicted TIFF.R in R or RStudio.
Modify the following placeholders:
Set your working directory: setwd("path/to/your/directory").
Update the path to the original TIFF file: original_tiff_path.
Update the path to the trained RF model: model_path.
Specify where to save the new TIFF file: output_tiff_path.

Run the script:
The script identifies missing FBFM values (-9999) and predicts them using the RF model.
A new TIFF file with the predicted values is saved as predicted_FBFM_layers_canada.tif.
Outputs

Trained RF Model: rf_model_combined.rds.
Predicted TIFF File: predicted_FBFM_layers_canada.tif.

Notes and Customizations
Ensure your working directory and file paths are updated to match your environment.
Modify parameters in the scripts (e.g., number of trees, cross-validation folds) as needed.
For large TIFF files, consider running the scripts in batches to manage memory usage.
Contact
For questions or issues, feel free to open an issue in this repository or contact me by my email: nima..284010@yahoo.com
