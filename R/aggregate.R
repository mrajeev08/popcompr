#' Aggregate population rasters to a shapefile
#'
#' @param brick brick of pops
#' @param sf sf object (shapefile with country admin units)
#' @param max_adjacent window to look at when matching cells with a population value, but no associated polygon id
#'
#' @return an sf object with columns for each layer in the raster brick
#' @export
#' @import sf raster fasterize
#'
#'
aggregate_to_shp <- function(brick, sf, max_adjacent = 100) {

  sf$id <- 1:nrow(sf)
  nlayers <- dim(brick)[3]

  # fasterize
  for(i in seq_len(nlayers)) {
    prast <- brick[[i]]

    # find the right shapefile ids
    ids <- fasterize(sf, prast, field = "id")

    # match any NonNas with a max adj
    missing <- which((!is.na(prast) & is.na(ids))[] == 1)
    ids <- match_nearest(cell_ids = missing, to_match = ids, max_adjacent)

    r_dt <- data.table(pop = prast[], id = ids[])
    r_dt <- r_dt[, .(pop = sum(pop, na.rm = TRUE)), keyby = "id"]
    missing <- r_dt[is.na(id)]$pop
    r_dt <- r_dt[!is.na(id)]

    if(length(missing) > 0 && missing > 0) {
      print(paste0("warning: ", missing, " people were not matched."))
    }

    sf[, paste0(names(prast))] <- r_dt$pop # is keyed by id so will match to row #
  }

  # return sf
  return(sf)

}

#' Match to closest non-NA cell
#'
#' Matches cells in pop raster which do not have a match to a shapefile feature
#' to nearest cell that does have a match. Mainly issue with coastal
#' populations or shapefiles with holes.
#'
#' @param cell_ids cells with NA values for shapefile feature
#' @param to_match raster with associated values from shapefile
#' @param max_adjacent max cell window to look for nearest non-NA cells
#'
#' @import raster
#' @keywords internal
#'
match_nearest <- function(cell_ids, to_match, max_adjacent = 10) {

  # For each cell_id to match: get the adjacent cell_ids
  find <- data.table(adjacent(to_match, cell_ids))

  # Get the admin values at the adjacent cell_ids
  find$match <- to_match[find$to]
  suppressWarnings({
    matched <- find[, .(match = min(match, na.rm = TRUE)), by = "from"] # match is the friction grid index
  })
  matched <- matched[!is.infinite(match)]
  find <- find[!(from %in% matched$from)]


  for (i in 1:max_adjacent) {
    if (nrow(find > 0)) {
      adj_next <- adjacent(to_match, unique(find$to))
      adj_next <- data.table(to = adj_next[, "from"],
                             to_i = adj_next[, "to"]) # next to_i
      adj_next$match <- to_match[adj_next$to_i]
      # this throws warnings: throw out now!
      suppressWarnings({
        matches <- adj_next[, .(match = min(match, na.rm = TRUE)), by = "to"]
      })
      find <- find[, c("from", "to")][matches, on = "to"]
      matches <- find[, .(match = min(match, na.rm = TRUE)), by = "from"]
      matched <- rbind(matched, matches[!is.infinite(match)])

      find <- find[, c("from", "to")][adj_next, on = "to", allow.cartesian = TRUE]
      find <- unique(find[, c("to", "to_i") := .(to_i, NULL)][!(from %in% matched$from)]) # search out
    } else {
      break
    }
  }

  if (nrow(find > 0)) {
    print("Warning: still unmatched pixels!")
  }

  to_match[cell_ids] <- matched$match[match(cell_ids, matched$from)]

  return(to_match)
}
