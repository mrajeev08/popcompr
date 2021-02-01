#' Title
#'
#' @param pops list of rasters
#'
#' @return boolean
#' @import raster
#' @keywords internal

all_longlat <- function(pops) {

  # are all rasters in lat long?
  all(unlist(lapply(pops, raster::isLonLat)))

}

#' Title
#'
#' @param pops list of rasters
#'
#' @return boolean
#' @import raster
#' @keywords internal

all_raster <- function(pops) {

  # are all rasters in lat long?
  all(unlist(lapply(pops, function(x) inherits(x, "RasterLayer"))))

}
