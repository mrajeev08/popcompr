# Preparing example data used in vignettes
library(raster)
library(dplyr)

lso_worldpop_2019 <- raster("data-raw/lso_ppp_2019.tif")
lso_facebook_2019 <- raster("data-raw/population_lso_2019-07-01_geotiff/population_lso_2019-07-01.tif")

# storing data in external
writeRaster(lso_worldpop_2019, "inst/external/lso_worldpop_2019.tif", overwrite = TRUE)
writeRaster(lso_facebook_2019, "inst/external/lso_facebook_2019.tif", overwrite = TRUE)

# set to text string
lso_facebook_2019 <- paste("To acess this dataset, use the following code:",
                         "raster(system.file('external/lso_facebook_2019.tif', package='popcompr'))",
                         "See ?lesotho_fb_2019 for documentation of this dataset.", sep = "\n")
lso_worldpop_2019 <- paste("To acess this dataset, use the following code:",
                         "raster(system.file('external/lso_worldpop_2019.tif', package='popcompr'))",
                         "See ?lesotho_wp_2019 for documentation of this dataset.", sep = "\n")
usethis::use_data(lso_worldpop_2019, overwrite = TRUE)
usethis::use_data(lso_facebook_2019, overwrite = TRUE)

# Get available data sets
iso_names <- readr::read_csv("data-raw/iso_country_names.csv")
out <- httr::GET(glue::glue("https://www.geoboundaries.org/gbRequest.html?", "ISO=ALL"))
out <- jsonlite::fromJSON(rawToChar(out$content))
out %>%
  select(iso_code = boundaryISO, year = boundaryYear, admin_level = boundaryType,
         source = `boundarySource-1`, license = licenseDetail) %>%
  left_join(iso_names) -> geoboundaries

usethis::use_data(geoboundaries, overwrite = TRUE)
