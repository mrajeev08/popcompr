#' Autoplot functions for pop comparisons
#'
#' This function generates automatic comparison plots of pixel level
#' or admin level population comparisons from the \code{\link{compare_pop}}
#' (a raster brick), or the \code{\link{aggregate_to_shp}} (an sf object). If
#' comparing a large number of rasters, you should be careful of memory
#' requirements (a general guideline is that ncell(exe) * nlayers(exe) should not
#' exceed 1e8, but this may be system dependent).
#'
#' @param comp_obj sf or RasterBrick object generated by comparison functions (see Details)
#' @param select_pops a numeric or character vector of either numeric indices or
#'  colum names, defaults to all population columns (i.e. ones with the prefix "popcmp")
#' @param type character with option of the type of plots (all ggplots):
#'  "hex" (requires `hexbin`), "pairs" (requires `GGally`),
#'  "map" (requires and `sf`), and "hist". Defaults to "map".
#' @param interactive logical, should the plot be returned as an interactive
#'  html plot using `plotly`? Defaults to FALSE.
#' @param save logical, should the plot be saved rather than returned? Requires
#'  both path & ext params.
#' @param path if save = TRUE, then the filepath to write the plot out to
#' @param ext file extension (i.e. "jpeg", "png", "tiff")
#' @param width width of file to write to, gets passed to ggsave
#' @param height height of file to write to, gets passed to ggsave
#'
#' @return either a ggplot or a message stating where the ggplot was written
#'  out to.
#' @export
#' @import raster sf ggplot2
#'
plot_compare <- function(comp_obj,
                         select_pops = NULL, # this can either be names or index of list
                         type = "map",
                         interactive = FALSE,
                         save = FALSE,
                         path = NULL,
                         ext = "jpeg",
                         width = 8,
                         height = 8) {

  if(save & is.null(path)) stop("Please pass a filename to the `path argument` to save!")

  object_brick <- type_comp(comp_obj)

  pop_names <- select_handler(select_pops, comp_obj, object_brick)

  ind_mat <- t(combn(pop_names, 2))

  comp_dt <- prep_dt(comp_obj, pop_names, object_brick)

  if(type %in% "map" | type %in% "hist") {

    out <- diff_plot(ind_mat, comp_dt, comp_obj, type, object_brick)

  }

  if(type %in% "hex") {

    out <- hex_plot(ind_mat, comp_dt)

  }

  if(type %in% "pairs") {
    if((require(GGally))) {
      out <-
        GGally::ggpairs(comp_dt, columns = pop_names)
    } else {
      stop("For a pairs plot, please install the `GGally` package or try the
           other plot options.")
    }

  }

  if(interactive) {
    if((require(plotly))) {
      out <- plotly::ggplotly(out)
    } else {
      interactive <- FALSE
      message("For interactive plots, please install the `plotly` package.
              Returning static plot")
    }
  }

  if(save) {

    if(interactive) ext <- "html"
    save_popplot(out, path, ext = ext, width = width, height = width)
    return(paste("Saved plot output to", paste0(path, ".", ext)))

  } else {
    return(out)
  }

}


#' Summary function for pop comparisons
#'
#' This function generates automatic summary stats of pixel level
#' or admin level population comparisons from the \code{\link{compare_pop}}
#' (a raster brick), or the \code{\link{aggregate_to_shp}} (an sf object).
#'
#' @inheritParams plot_compare
#' @param funs list of functions, you can pass your own with a single parameter
#'  x or you can use the defaults (sum, mean, max, min, sd, and length_nas)
#'
#' @return a table with the rows corresponding to the summary stats and the
#'  columns the population datasets
#'
#' @export
#' @import raster sf
#'
summary_compare <- function(comp_obj, select_pops = NULL,
                           funs = list(sum = function(x) sum(x, na.rm = TRUE),
                                       mean = function(x) mean(x, na.rm = TRUE),
                                       max = function(x) max(x, na.rm = TRUE),
                                       min = function(x) min(x, na.rm = TRUE),
                                       sd = function(x) sd(x, na.rm = TRUE),
                                       length_nas = function(x) sum(is.na(x)))) {

  object_brick <- type_comp(comp_obj)

  if(!all(unlist(lapply(funs, is.function)))) {
    stop("Not all items in list funs are functions!")
  }

  # select handler here
  pop_names <- select_handler(select_pops, comp_obj, object_brick)

  if(object_brick) {
    comp <- as.list(comp_obj[[pop_names]])
  } else {
    comp <- sf::st_drop_geometry(comp_obj)[, pop_names]
  }

  out <- data.frame(simplify2array(lapply(comp, map_apply, funs = funs)))

  names(out) <- pop_names

  return(out)

}

# Plotting helpers ----
mapply_in_place <- function(ind_mat, comp_dt) {

  out_names <- paste(ind_mat[, 1], "-", ind_mat[, 2])

  # Doing this to avoid copy on modify of large dt
  # Doesn't return anything but modifies the comp_dt in the function environment
  invisible(
    mapply(
      function(c1, c2, name) {
        comp_dt[, (name) := get(c1) - get(c2)]
        return(1)
      },
    c1 = ind_mat[, 1],
    c2 = ind_mat[, 2],
    name = out_names)
  )

}


#' @import foreach
mapply_hex <- function(ind_mat, comp_dt) {

  out <-
    foreach(i = 1:nrow(ind_mat), .combine = "rbind",
            .export = "data.table") %do% {

      c1 <- ind_mat[i, 1]
      c2 <- ind_mat[i, 2]
      out <- data.table(pop_x = comp_dt[[c1]],
                        pop_y = comp_dt[[c2]],
                        name_x = c1, name_y = c2)
    }

  return(out)

}

#' @import ggplot2

hex_plot <- function(ind_mat, comp_dt) {

  out <- mapply_hex(ind_mat, comp_dt)

  out <-
    ggplot(out) +
    geom_hex(aes(x = pop_x, y = pop_y), color = "grey") +
    facet_grid(name_x ~ name_y, switch = "both", drop = TRUE,
               scales = "free") +
    geom_abline(intercept = 0, slope = 1, linetype = 2, color = "grey") +
    scale_fill_distiller(direction = 1, trans = "log",
                         labels = function(x) round(x, -1)) +
    labs(x = "", y = "") +
    theme(strip.background = element_blank(),
          strip.placement = "outside")

  return(out)

}

#' @import ggplot2 sf
diff_plot <- function(ind_mat, comp_dt, comp_obj, type, object_brick) {

  mapply_in_place(ind_mat, comp_dt)

  if(object_brick) {

    comp_dt_long <- melt(comp_dt[, c(1, 2,
                                     grep(" - ", names(comp_dt))),
                                 with = FALSE],
                         id.vars = c("x", "y"))

  } else {

    pop_names_long <- c("id", names(comp_dt)[grep(" - ", names(comp_dt))])
    comp_dt_long <- melt(comp_dt[ , pop_names_long, with = FALSE],
                         id.vars = "id")
    comp_obj$id <- 1:nrow(comp_obj)
    comp_dt_long <- dplyr::left_join(dplyr::select(comp_obj, id), comp_dt_long)

  }

  if(type %in% "hist") {
    out <-
      ggplot(comp_dt_long) +
      geom_histogram(aes(x = value)) +
      labs(x = "Difference between \n population estimates") +
      facet_wrap(~variable,
                 labeller = labeller(variable = label_wrap_gen(25)))

  } else {

    out <-
      ggplot(comp_dt_long) +
      scale_fill_gradient2(labels = inv_diff,
                           name = "Difference between \n population estimates") +
      facet_wrap(~variable, labeller = labeller(variable = label_wrap_gen(25)))


    if(object_brick) {
      out <-
        out +
        geom_raster(aes(x = x, y = y, fill = trans_diff(value)))
        coord_quickmap()

    } else {
      out <-
        out +
        geom_sf(aes(fill = trans_diff(value)))
    }
  }
  return(out)
}

select_handler <- function(select_pops, comp_obj, object_brick) {

  if(is.null(select_pops)) {

    pop_names <- names(comp_obj)[grep("popcmp_", names(comp_obj), fixed = TRUE)]

  } else {
    if(object_brick) {

      if(is.numeric(select_pops)) {
        valid_inds <- 1:nlayers(comp_obj)
        pop_names <- names(comp_obj)[select_pops]
      } else {
        valid_inds <- names(comp_obj)
        pop_names <- select_pops
      }
    } else {

      if(is.numeric(select_pops)) {
        valid_inds <- 1:ncol(comp_obj)
        pop_names <- names(comp_obj)[select_pops]
      } else {
        valid_inds <- names(comp_obj)
        pop_names <- select_pops
      }

    }

    check_inds <- select_pops[!(select_pops %in% valid_inds)]

    if(!all(check_inds)) {

      stop(paste("You've selected the following invalid raster layer indexes:\n",
                 select_pops[!check_inds],
                 "for a raster brick with these possible layers: \n",
                 valid_inds))
    }
  }

  # return pop_names
  return(pop_names)
}


# Other helpers ----

prep_dt <- function(comp_obj, pop_names, object_brick) {

  if(object_brick) {
    # use data.table for speed & efficiency
    comp_dt <- data.table(as.data.frame(comp_obj, xy = TRUE))

    # set NAs to zero for comparison
    setnafill(comp_dt, fill = 0, cols = .SD)

  } else {
    comp_dt <- data.table(sf::st_drop_geometry(comp_obj[, pop_names]))
    comp_dt$id <- 1:nrow(comp_dt)
  }

  return(comp_dt)

}

save_popplot <- function(out, path, ext, width = 8, height = 8) {

  if("plotly" %in% class(out)) {
    htmlwidgets::saveWidget(as_widget(out), paste0(path, ".html"))
  } else {
    ggsave(paste0(path, ".", ext), out, width = width, height = height)
  }

}

type_comp <- function(comp_obj) {

  if(any(c("RasterBrick", "sf") %in% class(comp_obj))) {
    obj_brick <- ifelse("RasterBrick" %in% class(comp_obj), TRUE, FALSE)
    return(obj_brick)
  } else {
    stop("comp_obj is neither an sf object or a RasterBrick, please double
         check input!")
  }
}

map_apply <- function(x, funs) {
  out <- mapply(function(f) f(x[]), f = funs)
}

# transform functions for vizualizing differences
trans_diff <- function(x) {
  logged <- log(abs(x) + 1e-6) * sign(x)
  return(logged)
}
inv_diff <- function(x) {
  inv <- (exp(abs(x)) - 1e-6) * sign(x)
  return(round(inv, 2))
}

