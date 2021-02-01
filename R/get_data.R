#' Get country shapefile from geoboundaries
#'
#' @param country_iso the three letter code corresponding to the country.
#'  Use ?popcompr::iso_codes to see the full list.
#' @param admin_level numeric, the admin level of the shapefile (0 = the country border,
#'  then 1, 2, 3). Note that not all admin levels are available
#' @param type the type of shapefile. Geoboundaries have simplified and unsimplified,
#'  and standardized vs. unstandardized (and combinations thereof) available
#'  for use. See the api documentation for more details: \url{https://www.geoboundaries.org/api.html}
#' @param timeout numeric in seconds, the amount of time to wait for the httr request, default is 2, set higher
#'  if your connection is slower (max is set to 1 min for safety)
#' @return a shapefile as an sf object
#' @export
#'
#' @examples
#' # Defaults to simplified
#' les_simple <- get_country_shape(country_iso = "LSO", admin_level = 2)
#'
get_country_shape <- function(country_iso, admin_level, type = "SSCU",
                              timeout = 2) {

  timeout <- ifelse(timeout > 60, 60, timeout)

  url <- glue::glue("https://www.geoboundaries.org/gbRequest.html?",
                    "ISO={country_iso}",
                    "&ADM=ADM{admin_level}",
                    "&TYP={type}")

  out <- httr::GET(url, httr::timeout(timeout))
  out <- jsonlite::fromJSON(rawToChar(out$content))

  if(is.null(out$gjDownloadURL)) {
    stop("url is not valid: check country_iso and admin_level.")
  }

  shape <- sf::st_read(out$gjDownloadURL)

  return(shape)

}

# get_worldpop <- function(country_iso, year) {
#
#   url <- glue::glue("ftp://ftp.worldpop.org/GIS/Population/Global_2000_2020",
#                     "{year}/{country_iso}_ppp_{year}.tif")
#
# }
