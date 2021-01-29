#' Create temporary pop raster with pops matched to non-NA cell
#' Matches cells in pop raster which do not have a match to the friction surface
#' to nearest cell that does have a match to the friction surface. Mainly issue with coastal
#' populations.
#'
#' @param unmatched_pix
#' @param matched_raster
#' @param max_adjacent
#'
#' @import data.table
#' @import raster
#'
match_nearest <- function(unmatched_pix, matched_raster, max_adjacent = 100) {
  find <- data.table(adjacent(matched_raster, unmatched_pix@grid.index))
  find$match <- matched_raster[find$to]
  matched <- find[, .(match = min(match, na.rm = TRUE)), by = "from"] # match is the friction grid index
  matched <- matched[!is.infinite(match)]
  find <- find[!(from %in% matched$from)]

  for (i in 1:max_adjacent) {
    if (nrow(find > 0)) {
      adj_next <- adjacent(matched_raster, unique(find$to))
      adj_next <- data.table(to = adj_next[, "from"], to_i = adj_next[, "to"]) # next to_i
      adj_next$match <- matched_raster[adj_next$to_i]

      matches <- adj_next[, .(match = min(match, na.rm = TRUE)), by = "to"]
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

  unmatched_pix$match_id <- matched$match[match(unmatched_pix@grid.index, matched$from)]
  matched_raster[unmatched_pix@grid.index] <- unmatched_pix$match_id

  return(matched_raster)
}
