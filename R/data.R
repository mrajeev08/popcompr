#' List of country iso codes.
#'
#' @format A data frame with 246 rows and 2 variables:
#' \describe{
#'   \item{iso_code}{the three letter iso code for each country, see the source url for more information}
#'   \item{country}{the country name}
#' }
#'
#'@source \url{https://unstats.un.org/unsd/tradekb/knowledgebase/country-code}
#'
"iso_codes"


#' Population counts for Lesotho from Facebook/CIESIN for the year 2019.
#'
#' @format A geotiff file with number of people per pixel estimated by Facebook/CIESIN
#'  for the year 2020 at a resolution of 3 arc seconds (apprx 100m at the equator),
#'  projected in Geographic Coordinate System, WGS84.
#'  See source url for more details.
#'
#'@source \url{https://data.humdata.org/dataset/highresolutionpopulationdensitymaps-lso}
#'
"lesotho_fb_2019"

#' Population counts for Lesotho from WorldPop for the year 2019.
#'
#' @format A geotiff file with number of people per pixel estimated by World Pop
#'  for the year 2020 at a resolution of 1 arc seconds (apprx 30m at the equator),
#'  projected in Geographic Coordinate System, WGS84.
#'  See source url for more details.
#'
#'@source \url{https://data.humdata.org/dataset/worldpop-population-counts-for-lesotho}
#'
"lesotho_wp_2019"
