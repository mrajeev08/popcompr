
create_utm_raster <- function(utm_sf, id, res) {

  utm_sf %>%
    filter(FID == id ) -> shp
  r <- raster(shp)
  values(r) <- 1:ncell(r)
  r_proj <- projectRaster(r,
                            crs = CRS(glue::glue("+proj=utm +zone={shp$zone} +datum=WGS84")))
  res(r_proj) <- res
  values(r_proj) <- 1:ncell(r_proj)

  return(r_proj)

}

# get topleft x & y, then use res in meters to assign them to a grid cell
get_cellid <- function(x_topl, y_topl, x_coord, y_coord, ncol, nrow, res_m) {

  col <- ceiling((x_coord - x_topl)/res_m)
  row <- ceiling(-(y_coord - y_topl)/res_m)
  cell_id <- row*ncol - (ncol - col)
  return(cell_id)

}
