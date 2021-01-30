#' Title
#'
#' @param pop1
#' @param pop2
#' @param res_degrees
#'
#' @return
#' @export
#' @import raster
#' @examples
#'
#' To do: check crs here too? (just in case)
#'
make_template <- function(pops, res_degrees) {

  # make sure all crs's are the same
  if(!all_longlat(pops)) stop("Not all rasters are in Lat/Long CRS")

  ext <- do.call(raster::merge, lapply(pops, raster::extent))

  temp <- raster(pops[[1]])
  temp <- extend(temp, ext) # make sure extent covers all the rasters

  # set degree
  res(temp) <- res_degrees
  values(temp) <- NA # set all to NA
  return(temp)

}

resample_to_template <- function(pop, template, parallel,
                                 estimate_time) {

  out <- resample_fun(pop, template, parallel, estimate_time)

  if(estimate_time) {

    return(out)

  } else {

    # reaggregate at the end
    out <- out[, sum(V1, na.rm = TRUE), keyby = new_id]
    missing <- out[is.na(new_id)]$V1
    out <- out[!is.na(new_id)]

    template[out$new_id] <- out$V1
    names(template) <- names(pop)

    if(length(missing) > 0) {
      print(paste0("warning: ", missing, " people were not matched."))
    }

    return(template)

  }


}

resample_fun <- function(pop, template, parallel, estimate_time) {

  bs <- blockSize(pop)

  end_cell <- bs$row * ncol(pop)
  start_cell <- end_cell - end_cell[1] + 1
  end_cell <- start_cell + bs$nrows*ncol(pop) - 1

  `%myinfix%` <- ifelse(parallel, `%dopar%`, `%do%`)

  if(!estimate_time) chnks <- length(start_cell) else chnks <- 1

  ts <- system.time({
    out <-
      foreach(i = seq_len(chnks),
              .combine = rbind,
              .export = c('data.table', 'raster')) %myinfix% {

                new_id <- raster::cellFromXY(template,
                                             raster::xyFromCell(pop, cell = start_cell[i]:end_cell[i]))
                pop_vals <- raster::getValues(pop, row = bs$row[i], nrows = bs$nrows[i])
                inds <- !is.na(pop_vals)
                new_id <- new_id[inds]
                pop_vals <- pop_vals[inds]

                if(sum(pop_vals, na.rm = TRUE) > 0) {

                  out <- data.table(pop_vals, new_id)[, sum(pop_vals, na.rm = TRUE),
                                                      keyby = new_id]
                } else {
                  out <- NULL
                }
                out
              }
  })

  if(estimate_time) return(ts["elapsed"] * bs$n) else return(out)

}

compare_pop <- function(pops, res_degrees = 30/3600,
                        parallel = FALSE, estimate_time = FALSE) {

  # Is pops a list of rasters?
  if(!is.list(pops)) stop("Pops should be a list of rasters.")
  if(!all_raster(pops)) stop("Not all list elements are rasters.")

  # create template
  template <- make_template(pops, res_degrees)
  nlayers <- length(pops)
  popcomp <- vector("list", nlayers)

  # replace them with the new resampled raster
  for(i in seq_len(nlayers)) {
    popcomp[[i]] <- resample_to_template(pops[[i]], template, parallel,
                                         estimate_time)
  }

  if(estimate_time) {
    message(paste("It will take approximately",
                  sum(unlist(popcomp)), "seconds to complete the full job serially",
                  "(to run it set estimate_time = FALSE."))
  } else {
    # make a raster brick
    popcomp <- brick(popcomp)
    return(popcomp)
  }
}

all_longlat <- function(pops) {

  # are all rasters in lat long?
  all(unlist(lapply(pops, raster::isLonLat)))

}

all_raster <- function(pops) {

  # are all rasters in lat long?
  all(unlist(lapply(pops, function(x) inherits(x, "RasterLayer"))))

}




