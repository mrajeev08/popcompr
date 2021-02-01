#' All items in list in Long Lat coordinateS?
#'
#' @param pops list of rasters
#'
#' @return boolean
#' @import raster

all_longlat <- function(pops) {

  # are all rasters in lat long?
  all(unlist(lapply(pops, raster::isLonLat)))

}

#' All items in list raster?
#'
#' @param pops list of rasters
#'
#' @return boolean
#' @import raster

all_raster <- function(pops) {

  # are all rasters in lat long?
  all(unlist(lapply(pops, function(x) inherits(x, "RasterLayer"))))

}
