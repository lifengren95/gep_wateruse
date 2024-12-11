############################################################
# Project: Global GEP: Water Use Data Preperation
# Author: Lifeng Ren
# Date Created: 12/11/2024
# Last Modified: 12/11/2024
# Description: This script with takes in the csvs saved from the Aquastats platform
############################################################

#------------------------------------------------------------
# 1. Setup----
#------------------------------------------------------------

# 1.1 Load Required Libraries
library(dplyr)
library(data.table)

# 1.2 Define Working Directory
#setwd("D:/Users/lifengren/Dropbox/400_research/440_UMN/gep/gep_fisheries/scripts")
setwd("C:/Users/lifengren/Dropbox/400_research/440_UMN/gep/gep_wateruse/scripts")

# Define output directory
output_dir <- "../intermediate/aquastat_cleaned/"

# Create the directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  cat("Output directory created:", output_dir, "\n")
} else {
  cat("Output directory already exists:", output_dir, "\n")
}
#------------------------------------------------------------
# 2. Data Import
#------------------------------------------------------------

# List of datasets to process

# 2.1 Load Data
# List of file paths for all datasets
file_paths <- c(
  "../raw_data/aquastat/auqastat_water_efficiency.csv"
)

auqastat_water_efficiency <- fread(file_paths, fill = TRUE)


#------------------------------------------------------------
# 3. Data Cleaning
#------------------------------------------------------------

# 1. Filter rows: keep only those with Unit == "US$/m3"
auqastat_clean <- auqastat_water_efficiency[Unit == "US$/m3"]

# 2. Drop unwanted columns: Symbol, Subgroup, and IsAggregate
auqastat_clean[, c("Symbol", "Subgroup", "IsAggregate") := NULL]

# 3. Keep only relevant Variables
target_variables <- c("SDG 6.4.1. Water Use Efficiency",
                      "SDG 6.4.1. Irrigated Agriculture Water Use Efficiency",
                      "SDG 6.4.1. Industrial Water Use Efficiency",
                      "SDG 6.4.1. Services Water Use Efficiency")

auqastat_clean <- auqastat_clean[Variable %in% target_variables]

# 4. Rename Area and Year to country and year for clarity
setnames(auqastat_clean, old = c("Area", "Year"), new = c("country", "year"))

# 5. Reshape the data from long to wide
auqastat_wide <- dcast(auqastat_clean, country + year ~ Variable, value.var = "Value")

# 6. Rename the columns to the required indicator names
setnames(auqastat_wide,
         old = c("SDG 6.4.1. Water Use Efficiency",
                 "SDG 6.4.1. Irrigated Agriculture Water Use Efficiency",
                 "SDG 6.4.1. Industrial Water Use Efficiency",
                 "SDG 6.4.1. Services Water Use Efficiency"),
         new = c("wue_general_usdpm3",
                 "wue_irrigation_usdpm3",
                 "wue_industrial_usdpm3",
                 "wue_municipal_usdpm3"))

# Save data
fwrite(auqastat_wide, paste0(output_dir,"aquastats_cleaned.csv"))

