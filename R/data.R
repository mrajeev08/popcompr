#' Data frame of available datasets through the geoBoundaries API.
#'
#' @format A data frame with 644 rows and 6 variables:
#' \describe{
#'   \item{iso_code}{the three letter iso code for each country, see the source url for more information}
#'   \item{year}{the year of the dataset}
#'   \item{admin_level}{the admin level of the available dataset}
#'   \item{source}{the source of the dataset}
#'   \item{license}{the license of the dataset}
#'   \item{country}{the country name}
#' }
#'
#'@source \url{https://www.geoboundaries.org/api.html}
#'@keywords dataset
#'
"iso_codes"


#' Population counts for Lesotho from Facebook/CIESIN for the year 2019.
#'
#' @format A geotiff file with number of people per pixel estimated by Facebook/CIESIN
#'  for the year 2020 at a resolution of 3 arc seconds (apprx 100m at the equator),
#'  projected in Geographic Coordinate System, WGS84.
#'  See source url for more details.
#'
#'@details This is just a help file, to access the file see the example below.
#'
#'@source \url{https://data.humdata.org/dataset/highresolutionpopulationdensitymaps-lso}
#'@keywords dataset
#'
#'@examples
#'\dontrun{
#'lesotho_fb_2019 <- raster(system.file("external/lso_facebook_2019.tif", package="popcompr"))
#'}
#'
#'
"lso_facebook_2019"

#' Population counts for Lesotho from WorldPop for the year 2019.
#'
#' @format A geotiff file with number of people per pixel estimated by World Pop
#'  for the year 2020 at a resolution of 1 arc seconds (apprx 30m at the equator),
#'  projected in Geographic Coordinate System, WGS84.
#'  See source url for more details.
#'
#'@details This is just a help file, to access the file see the example below.
#'
#'@source \url{https://data.humdata.org/dataset/worldpop-population-counts-for-lesotho}
#'@keywords dataset
#'@examples
#'\dontrun{
#'lesotho_wp_2019 <- raster(system.file("external/lso_worldpop_2019.tif", package="popcompr"))
#'}
#'
"lso_worldpop_2019"
