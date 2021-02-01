# Preparing example data used in vignettes

library(raster)

lesotho_wp_2019 <- raster("data-raw/lso_ppp_2019.tif")
names(lesotho_wp_2019) <- "lso_worldpop_2019"

lesotho_fb_2019 <- raster("data-raw/population_lso_2019-07-01_geotiff/population_lso_2019-07-01.tif")
names(lesotho_fb_2019) <- "lso_facebook_2019"

iso_codes <- readr::read_csv("data-raw/iso_codes.csv")
usethis::use_data(lesotho_wp_2019, overwrite = TRUE)
usethis::use_data(lesotho_fb_2019, overwrite = TRUE)
usethis::use_data(iso_codes, overwrite = TRUE)
