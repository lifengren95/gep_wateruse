# /*===========================================*/
#'= Objective: =
#' + Clean the Country-level AquaStat Data that contains the water use efficiency data and water withdrawal data by sector. 
# /*===========================================*/

# NOTE: Once you change the path to the project folder defined in the `pwd` variable in the code, it should work without any issues.

library(data.table)
library(dplyr)

library(countrycode) # to get ISO code with country name


# /*===========================================*/
#'=  Preparation =
# /*===========================================*/
# /*===== Set paths =====*/
# --- Current Working Directory (need to be changed)--- #
pwd <- here::here() # Replace with your working directory. It should be the root of the project (path to the project folder in which "Data" folder is contained.)

# --- Path to the "raw" data folder --- #
raw_input_dir <- file.path(pwd, "Data/raw")

# --- Path to the "intermediate" output folder --- #
out_interm_dir <- file.path(pwd, "Data/intermediate")

# Check if the output directory exists, if not create it
if (!dir.exists(out_interm_dir)) {
  dir.create(out_interm_dir, recursive = TRUE)
  cat("Output directory created:", out_interm_dir, "\n")
} else {
  cat("Output directory already exists:", out_interm_dir, "\n")
}


# /*===== Loading AquaStat Dataset =====*/
w_dt_all <- 
  fread(
    file = file.path(raw_input_dir, "AQUASTAT_2007_2022.csv"),
    fill = TRUE
  )


# /*===========================================*/
#'=  Data Cleaning =
# /*===========================================*/
# === Target variables related to water prices === #
ls_vars_p <- 
  c(
    "SDG 6.4.1. Industrial Water Use Efficiency",
    "SDG 6.4.1. Irrigated Agriculture Water Use Efficiency",
    "SDG 6.4.1. Services Water Use Efficiency"
  )

ls_vars_p_new_names <-
  c(
    "wue_industry_usdpm3",
    "wue_irrag_usdpm3",
    "wue_municipal_usdpm3"
  )


# === Target variables related to water withdrawals === #
ls_vars_q <- 
  c(
    "Agricultural water withdrawal",
    # "Irrigation water withdrawal",
    "Municipal water withdrawal",
    "Industrial water withdrawal" 
  )

ls_vars_q_new_names <- 
  c(
    "w_agriculture",
    # "w_irrigation",
    "w_municipal",
    "w_industry"
  )


# /*===== Data Cleaning =====*/
w_dt <- 
  # --- Remove Aggregated data --- #
  w_dt_all[IsAggregate == FALSE] %>%
  # --- Keep rows related to P and Q --- #
  .[Variable %in% c(ls_vars_p, ls_vars_q),] %>%
  # --- Convert from 10^9 m3/year to m3/year for water withdrawal --- #
  .[Variable %in% ls_vars_q, Value := Value * 10^9]

w_dt_wide <- 
  dcast(w_dt, Area + Year ~ Variable, value.var = "Value") %>%
  # --- Change column names --- #
  setnames(
    old = c("Area", "Year", ls_vars_p, ls_vars_q),
    new = c("country", "year", ls_vars_p_new_names, ls_vars_q_new_names)
  ) %>%
  # --- Add ISO code --- #
  .[, `:=`(
    iso_code2 = countrycode(country, "country.name", "iso2c"),
    iso_code3 = countrycode(country, "country.name", "iso3c")
  )]



# /*===== Save in the .csv format =====*/
fwrite(w_dt_wide, file.path(out_interm_dir, "water_p_q.csv"))


