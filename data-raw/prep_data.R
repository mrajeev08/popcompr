# Preparing example data used in vignettes
library(raster)
library(dplyr)

lesotho_wp_2019 <- raster("data-raw/lso_ppp_2019.tif")
names(lesotho_wp_2019) <- "lso_worldpop_2019"

lesotho_fb_2019 <- raster("data-raw/population_lso_2019-07-01_geotiff/population_lso_2019-07-01.tif")
names(lesotho_fb_2019) <- "lso_facebook_2019"

# storing data in external
writeRaster(lesotho_wp_2019, "inst/extdata/lesotho_wp_2019.tif", overwrite = TRUE)
writeRaster(lesotho_fb_2019, "inst/extdata/lesotho_fb_2019.tif", overwrite = TRUE)

# Get available data sets
iso_names <- readr::read_csv("data-raw/iso_country_names.csv")
out <- httr::GET(glue::glue("https://www.geoboundaries.org/gbRequest.html?", "ISO=ALL"))
out <- jsonlite::fromJSON(rawToChar(out$content))
out %>%
  select(iso_code = boundaryISO, year = boundaryYear, admin_level = boundaryType,
         source = `boundarySource-1`, license = licenseDetail) %>%
  left_join(iso_names) -> iso_codes

usethis::use_data(iso_codes, overwrite = TRUE)
