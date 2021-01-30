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

cells_away <- function(origin_cell, dist_m, res_m, ncol, nrow, ncells) {

  n_away <- floor(dist_m/res_m)
  origin_row <- ceiling(origin_cell/ncol)
  origin_col <- ifelse(origin_cell %% ncol == 0, ncol, origin_cell %% ncol)

  if(n_away == 0) {
    return(origin_cell)
  } else {
    aways <- data.table(expand.grid(col = -n_away:n_away, row = -n_away:n_away))
    aways <- aways[abs(row) + abs(col) != 0 & pmax(abs(col), abs(row)) == n_away]
    aways <- aways[, c("col", "row") := .(origin_col + col,
                                          origin_row + row)]
    aways <- aways[row <= nrow & row > 0 & col <= ncol & col > 0]
    aways[, cell_id :=  (col - 1) * ncol  + ifelse(row %% ncol == 0,
                                                   ncol,
                                                   row %% ncol)]
    if(nrow(aways) > 0) out <- aways$cell_id else out <- ncells + 1
    return(out)
  }

}


moves_away <- function(tolook = 100, cell_ids) {

  n_away <- data.table(expand.grid(col = -tolook:tolook, row = -tolook:tolook))
  rowcols <- data.table(rowColFromCell(cell_ids, rast))
  origin_col <- ifelse(origin_cell %% ncol == 0, ncol, origin_cell %% ncol)

  if(n_away == 0) {
    return(origin_cell)
  } else {
    aways <-
    aways <- aways[abs(row) + abs(col) != 0 & pmax(abs(col), abs(row)) == n_away]
    aways <- aways[, c("col", "row") := .(origin_col + col,
                                          origin_row + row)]
    aways <- aways[row <= nrow & row > 0 & col <= ncol & col > 0]
    aways[, cell_id :=  (col - 1) * ncol  + ifelse(row %% ncol == 0,
                                                   ncol,
                                                   row %% ncol)]
    if(nrow(aways) > 0) out <- aways$cell_id else out <- ncells + 1
    return(out)
  }

}
