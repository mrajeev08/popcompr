#' Get country shapefile from geoboundaries
#'
#' @param country_iso the three letter code corresponding to the country.
#'  Use ?popcompr::iso_codes to see the full list.
#' @param admin_level numeric, the admin level of the shapefile (0 = the country border,
#'  then 1, 2, 3). Note that not all admin levels are available
#' @param type the type of shapefile. Geoboundaries have simplified and unsimplified,
#'  and standardized vs. unstandardized (and combinations thereof) available
#'  for use. See the api documentation for more details: \url{https://www.geoboundaries.org/api.html}
#'
#' @return a shapefile as an sf object
#' @export
#'
#' @examples
#' # Defaults to simplified
#' les_simple <- get_country_shape(country_iso = "LSO", admin_level = 2)
#'
get_country_shape <- function(country_iso, admin_level, type = "SSCU",
                              iso_codes = popcompr::iso_codes) {

  file <- iso_codes[iso_codes$iso_code == country_iso &
              iso_codes$admin_level == glue::glue("ADM{admin_level}"), ]

  if(nrow(file) != 1) {
    stop("Country iso code and admin level are not valid, check the dataset
         iso_codes included in the package for available files.")
  }

  shape <- sf::st_read(file$download[[1]])

  return(shape)

}

# get_worldpop <- function(country_iso, year) {
#
#   url <- glue::glue("ftp://ftp.worldpop.org/GIS/Population/Global_2000_2020",
#                     "{year}/{country_iso}_ppp_{year}.tif")
#
# }
