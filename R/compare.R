# Fast way?
# 1. get shapefile
# 2. Rasterize (in UTM) (at appropriate resolution)
# A UTM coordinate's Easting and Northing are both distance measurements made in meters.
# 3. Use coordinates and one based indexing to find the grid cells where the cells belong (for large/long countries this will be apprx and may be wrong? try with Mada and see how wrong it is) (warn if people go missing...or if using multiple UTMs using the ESRI UTM file, clip to each one and put back together...)
# Step 1: use rasterize to get points which overlap the UTM section
# Step 2: for each UTM, turn into a raster
# Step 3: use one based indexing to match point to grid cell
# Transform those back to latitude & longitude
# Do this for all the utm zones covered by the country
# put them back together and use a lat/long grid and then get raster id for each of the points and aggregate to this raster

library(raster)
library(dplyr)
library(fasterize)
library(data.table)

pop1 <- raster("data-raw/mdg_ppp_2018.tif")
pop2 <- raster("data-raw/population_mdg_2018-10-01.tif")


pop2_dt[, new_cell := cellFromXY(pop1, cbind(x, y))]

shape <- httr::GET("https://www.geoboundaries.org/gbRequest.html?ISO=MDG&ADM=ADM0")
out <- jsonlite::fromJSON(rawToChar(shape$content))
shape <- sf::st_read(out$gjDownloadURL)
utm <- sf::st_read("data-raw/World_UTM_Grid/0f893164-d038-48ff-98dd-9fefb26127d3202034-1-145zfwr.nwf1.shp")


# less than or equal to M == S
# less than or equal to N == N
# Process this so that for each one you get the parameters to use the 1 based indexing to match to grid cells
utm$dir <- ifelse(utm$ROW_ %in% LETTERS[14:26], "N", "S")
utm$zone <- paste0(utm$ZONE, utm$dir)

library(fasterize)
library(sf)
utms <- st_intersects(utm, shape, sparse = FALSE)
mada_utms <- utm[which(utms == TRUE), ]
plot(utm[which(utms == TRUE), ], max.plot = 1)


pop1_utm <- fasterize(utm, pop1, field = "FID")
pop1_dt <- data.table(pop = pop1[], utm = pop1_utm[],
                      coordinates(pop1))
pop1_dt <- pop1_dt[!is.na(pop)]
pop1_dt$crs <- glue::glue("+proj=utm +zone={utm$zone[pop1_dt$utm]} +datum=WGS84")

pop1_dt[, c("x_utm", "y_utm") := as.data.frame(
  rgdal::project(cbind(x, y), proj = as.character(crs[1]))
  ), by = "utm"]

# this takes forever
setkey(pop1_dt, utm)

# get x_topl & y_topl for each of the utm grids
pop1_reproj <-
  foreach(i = 1:nrow(mada_utms), .combine = rbind) %do% {
    print(i)
    rast <- create_utm_raster(utm, id = mada_utms$FID[i], res = 1000)
    test <- pop1_dt[utm == mada_utms$FID[i]]
    x_topl = bbox(rast)[1, "min"]
    y_topl = bbox(rast)[2, "max"]

    test[, cell_id := get_cellid(x_topl = x_topl, y_topl = y_topl,
                                 x_coord = x_utm, y_coord = y_utm,
                                 ncol = ncol(rast), nrow = nrow(rast), res_m = 1000)]

    pop <- test[, .(pop = sum(pop, na.rm = TRUE),
                    npoints = .N), by = cell_id]
    coords_rast <- coordinates(rast)

    # Last step = transform the utm coords back to lat & long
    pop[, c("x_cell", "y_cell") := data.frame(coords_rast[cell_id, ])]
    pop[, c("long_cell", "lat_cell") := as.data.frame(
      rgdal::project(cbind(x_cell, y_cell),  proj = as.character(crs(rast)), inv = TRUE))]
    pop
  }

# then aggregate them to a unified raster (together)
mada_rast <- raster(shape)
res(mada_rast) <- res(pop1)*10
values(mada_rast) <- NA

# Is this slow?
pop1_reproj[, new_cell := cellFromXY(mada_rast,
                                     cbind(long_cell, lat_cell))]
out <- pop1_reproj[, .(pop = sum(pop, na.rm = TRUE)), by = new_cell]
mada_rast[out$new_cell] <- out$pop


# Alternatively resample to an aggregated raster (just one)
# Usin over
