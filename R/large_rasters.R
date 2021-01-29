# Rationale (large datasets)
# when not to chunk a threshold for small stuff?
# To efficiently compare rasters, we look at an apprx scale of ~ 1km at equator
# Resample to a grid by country
# For user inputs, we set that resolution
# Working in lat/long

# Functions:
# 1. Function to create the raster to resample to
# 2. Function to resample the pop data sets to the lower res scale (chunked or not) (parallelized)
# 3. Function to compare the population data sets
# - put in two rasters
# - make the skeleton at appropriate resolution
# - (if still not within memory tell the user? Or make it chunkable/memsafe as well)
# - resample and brick them/stack them together
# return a raster brick or something that is ggplottable / plotlyable / leaflettable for interactive viz
# diagnostics (look at the distribution of diffs)
# vizualize them spatially & as corr
# remember to keep track of NA mismatches (issue with resampling?) Where do people go missing?

# Second set
# 1. Function to aggregate the raster brick to an sf file using fasterize!
# 2. Include a way to match coastlines/missing vals, as well
# 3. Make comparisons same way (spatially & xy coords)

# Autoplot methods
# 1. for both raster and admin = static/dynamic + plot spatial diff & also xy corr

# Document & write up all above & share as package on github with Fleur ------------------

# API infrastructure
# 1. country shapefiles from geoboundaries
# 2. raster datasets from hdx or other api? too slow?
# 3. options for user to be able to input either pop datasets or shapefiles (with errors when extents don't overlap!)

# Unit tests (to do / figure out)

# Vignettes -------------------------------------------------------------------
# How to query the api & download files (keeping in mind size issues)
# How to compare @ raster scale
# How to compare @ admin scale
# Use user specific datasets (rasters & shapefiles & if things will catch it if not the same extent!)

library(raster)
library(data.table)
library(foreach)

pop1 <- raster("data-raw/mdg_ppp_2018.tif")
pop2 <- raster("data-raw/population_mdg_2018-10-01.tif")

# or aggregate one up for making it faster to work with
fast_rast <- raster(pop1)
res(fast_rast) <- res(pop1)*10
values(fast_rast) <- NA # set all to NA

bs <- blockSize(pop2)

end_cell <- bs$row * ncol(pop2)
start_cell <- end_cell - end_cell[1] + 1
end_cell <- start_cell + bs$nrows*ncol(pop2) - 1

out <-
  foreach(i = 1:length(start), .combine = rbind) %do% {

    print(i)/bs$n * 100

    new_id <- cellFromXY(fast_rast, xyFromCell(pop2, cell = start_cell[i]:end_cell[i]))
    pop <- getValues(pop2, row = bs$row[i], nrows = bs$nrows[i])

    if(sum(pop, na.rm = TRUE) > 0) {
      temp_dt <- data.table(pop, new_id)
      out <- temp_dt[, .(pop = sum(pop, na.rm = TRUE)), by = new_id]
    } else {
      out <- NULL
    }

    out
  }

pop2_comp <- setValues(fast_rast, NA)
pop2_comp[out$new_id] <- out$pop

bs <- blockSize(pop1, chunksize = ncell(pop1))

end_cell <- bs$row * ncol(pop1)
start_cell <- end_cell - end_cell[1] + 1
end_cell <- start_cell + bs$nrows*ncol(pop1) - 1

out2 <-
  foreach(i = 1:length(start_cell), .combine = rbind) %do% {

    print(i)/bs$n * 100

    new_id <- cellFromXY(fast_rast, xyFromCell(pop1, cell = start_cell[i]:end_cell[i]))
    pop <- getValues(pop1, row = bs$row[i], nrows = bs$nrows[i])

    if(sum(pop, na.rm = TRUE) > 0) {
      temp_dt <- data.table(pop, new_id)
      out <- temp_dt[, .(pop = sum(pop, na.rm = TRUE)), by = new_id]
    } else {
      out <- NULL
    }

    out
  }

pop1_comp <- setValues(fast_rast, NA)
pop1_comp[out2$new_id] <- out2$pop

