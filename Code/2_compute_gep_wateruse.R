# /*===========================================*/
#'= Objective: =
#' + Compute the GEP of water for the three sectors: industry, irrigated agriculture, and municipal.
#' + Create tables and figures to report
# /*===========================================*/


library(data.table)
library(dplyr)
library(ggplot2)
library(viridis)

library(sf)
library(spData)
data(world)

# /*===========================================*/
#'=  Calculation =
# /*===========================================*/
# /*===== Set paths =====*/
# --- Current Working Directory (need to be changed)--- #
pwd <- here::here() # Replace with your working directory. It should be the root of the project (path to the project folder in which "Data" folder is contained.)

# --- Path to the "intermediate" output folder --- #
out_interm_dir <- file.path(pwd, "Data/intermediate")

# --- Path to the "final" output folder --- #
out_final_dir <- file.path(pwd, "Data/final")

# Check if the output directory exists, if not create it
if (!dir.exists(out_dir)) {
  dir.create(out_dir, recursive = TRUE)
  cat("Output directory created:", out_dir, "\n")
} else {
  cat("Output directory already exists:", out_dir, "\n")
}

# /*===== Loading the data =====*/
w_dt_country <- fread(file.path(out_interm_dir, "water_p_q.csv"))


# /*===== Calculating GEP (in billion dollars) of water by sector and year =====*/
w_dt_country[, `:=`(
  gep_w_ag_bil = wue_irrag_usdpm3 * w_agriculture / 10^9,
  gep_w_ind_bil = wue_industry_usdpm3 * w_industry / 10^9, 
  gep_w_mun_bil= wue_municipal_usdpm3 * w_municipal / 10^9 
)]

fwrite(w_dt_country, file.path(out_final_dir, "gep_water_y_country.csv"))


# /*===== Aggregate by year across countries =====*/
w_dt_global <- 
  w_dt_country[,.(
    total_gep_w_ag_bil = sum(gep_w_ag_bil, na.rm = TRUE),
    total_gep_w_ind_bil = sum(gep_w_ind_bil, na.rm = TRUE),
    total_gep_w_mun_bil = sum(gep_w_mun_bil, na.rm = TRUE)
  ), by = year]



w_dt_country_long <- 
  melt(w_dt_country, id.vars = c("year", "country"), measure.vars = c("gep_w_ag_bil", "gep_w_ind_bil", "gep_w_mun_bil"))

w_dt_global_long <- melt(w_dt_global, id.vars = "year")


w_dt_sf <- 
  left_join(
    world, 
    w_dt_country[year %in% seq(2007, 2022, by = 5)], 
    by = c("iso_a2" = "iso_code2")
  )

# /*===========================================*/
#'=  Visualization =
# /*===========================================*/
# ggplot() +
#   geom_sf(data = world)


ggplot(w_dt_global_long, aes(x = year, y = value, color = variable)) + 
  geom_point() +
  geom_line() + 
  labs(x = "Year", y = "GEP of water (in billion)")

ggplot() + 
  geom_sf(data = world, fill = NA) +
  geom_sf(data = w_dt_sf, aes(fill = gep_w_ag_bil)) + 
  facet_wrap(vars(year)) +
  scale_fill_viridis()

ggplot() + 
  geom_sf(data = world, fill = NA) +
  geom_sf(data = w_dt_sf, aes(fill = gep_w_ind_bil)) + 
  facet_wrap(vars(year)) +
  scale_fill_viridis()

ggplot() + 
  geom_sf(data = world, fill = NA) +
  geom_sf(data = w_dt_sf, aes(fill = gep_w_mun_bil)) + 
  facet_wrap(vars(year)) +
  scale_fill_viridis()
