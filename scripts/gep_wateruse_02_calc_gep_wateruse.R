############################################################
# Project: Global GEP: Water Use Calculation
# Author: Lifeng Ren, Shunkei Kakimoto
# Date Created: 12/11/2024
# Last Modified: 12/11/2024
# Description: This script with takes in the cleaned csvs saved from the Aquastats platform
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
output_dir <- "../intermediate/gep_wateruse_res/"

# Create the directory if it doesn't exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
  cat("Output directory created:", output_dir, "\n")
} else {
  cat("Output directory already exists:", output_dir, "\n")
}
#------------------------------------------------------------
# 2. Data Import----
#------------------------------------------------------------

# List of datasets to process

# 2.1 Load Data
# List of file paths for all datasets
cleaned_aquastats_wue_paths <- "../intermediate/aquastat_cleaned/aquastats_cleaned.csv"
cleaned_withdrawl_paths <- "../intermediate/withdrawl_cleaned/water_withdraw.csv"

wue_dt <- fread(cleaned_aquastats_wue_paths, fill = TRUE)
withdrawl_dt <- fread(cleaned_withdrawl_paths, fill = TRUE)

#------------------------------------------------------------
# 3. Data Merging
#------------------------------------------------------------

# 1. Extract the unique iso_code-country pairs from withdrawl_dt
withdrawl_country_map <- unique(withdrawl_dt[, .(iso_code, country)])

# View any country names that don't match directly
unmatched <- setdiff(wue_dt[, unique(country)], withdrawl_country_map[, unique(country)])
cat("Countries in wue_dt not found in withdrawl_dt:\n")
print(unmatched)

# At this point, you need to harmonize names. For example:
# wue_dt uses "Cabo Verde" but withdrawl_dt uses "Cape Verde"
wue_dt[country == "Cabo Verde", country := "Cape Verde"]

# Similarly, if wue_dt uses "Côte d'Ivoire" and withdrawl_dt uses "Cote d'Ivoire", harmonize:
wue_dt[country == "Côte d'Ivoire", country := "Cote d'Ivoire"]

# Continue this for all discrepancies found. For instance, Timor-Leste vs East Timor:
wue_dt[country == "Timor-Leste", country := "East Timor"]

# After harmonization, check again:
unmatched_after <- setdiff(wue_dt[, unique(country)], withdrawl_country_map[, unique(country)])
cat("Countries still unmatched:\n")
print(unmatched_after)

# If unmatched_after is empty, great! Otherwise, continue correcting names or omit those countries.

# 3. Once countries are harmonized, perform a left join to add iso_code to wue_dt
wue_dt <- merge(wue_dt, withdrawl_country_map, by = "country", all.x = TRUE)

# Display rows where iso_code is missing
missing_iso_code <- wue_dt[is.na(iso_code)]


# Create a named vector (lookup) for iso codes
iso_lookup <- c(
  "Bolivia (Plurinational State of)" = "BOL",
  "Brunei Darussalam" = "BRN",
  "Democratic People's Republic of Korea" = "PRK",
  "Democratic Republic of the Congo" = "COD",
  "Iran (Islamic Republic of)" = "IRN",
  "Lao People's Democratic Republic" = "LAO",
  "Liechtenstein" = "LIE",
  "Netherlands (Kingdom of the)" = "NLD",
  "Republic of Korea" = "KOR",
  "Republic of Moldova" = "MDA",
  "Russian Federation" = "RUS",
  "Sao Tome and Principe" = "STP",
  "Syrian Arab Republic" = "SYR",
  "Türkiye" = "TUR",
  "United Kingdom of Great Britain and Northern Ireland" = "GBR",
  "United Republic of Tanzania" = "TZA",
  "United States of America" = "USA",
  "Venezuela (Bolivarian Republic of)" = "VEN",
  "Viet Nam" = "VNM"
)

# Update iso_code for these countries in wue_dt
wue_dt[country %in% names(iso_lookup), iso_code := iso_lookup[country]]

# Display rows where iso_code is missing
missing_iso_code <- wue_dt[is.na(iso_code)]
unique(missing_iso_code$country)

# Create a vector of region names to drop
regions_to_drop <- c(
  "Australia and New Zealand",
  "Central Asia",
  "Central and Southern Asia",
  "Eastern Asia",
  "Eastern and South-Eastern Asia",
  "Europe",
  "Europe and Northern America",
  "Land Locked Developing Countries",
  "Latin America and the Caribbean",
  "Least Developed Countries",
  "Northern Africa",
  "Northern Africa and Western Asia",
  "Northern America",
  "Oceania",
  "Oceania (excluding Australia and New Zealand)",
  "Small Island Developing States",
  "South-eastern Asia",
  "Southern Asia",
  "Sub-Saharan Africa",
  "Western Asia",
  "World"
)

# Drop these rows from wue_dt
wue_dt <- wue_dt[!(country %in% regions_to_drop)]


# Merge wue_dt with withdrawl_dt by iso_code, country, and year
final_merged_dt <- merge(
  wue_dt, 
  withdrawl_dt, 
  by = c("iso_code", "country", "year"), 
  all = TRUE
)

# Keep only years 2000, 2005, 2010, and 2015
final_filtered_dt <- final_merged_dt[year %in% c(2000, 2005, 2010, 2015)]

# Calculate new columns:
# Agricultural GEP = wue_irrigation_usdpm3 * w_agriculture
# Industrial GEP   = wue_industrial_usdpm3 * w_industry
# Municipal GEP    = wue_municipal_usdpm3 * w_munucipal

final_filtered_dt[, gep_water_agricultural := wue_irrigation_usdpm3 * w_agriculture]
final_filtered_dt[, gep_water_industrial   := wue_industrial_usdpm3 * w_industry]
final_filtered_dt[, gep_water_municipal    := wue_municipal_usdpm3 * w_munucipal]

# Save data
fwrite(final_filtered_dt, paste0(output_dir,"gep_wateruse.csv"))
