# Plotting functions once I figure out naming conventions
#
# exe2$diff <- exe2$layer.1 - exe2$layer.2
# # base plot
# plot(exe2$diff, col = colorRampPalette(c("red", "blue"))(11),
#      breaks = c(-1e6, -1000, -400, -200, -100, 0, 100, 200, 400, 800, 1e6))
#
# # ggplot
# popcomp <- as.data.table(as.data.frame(exe2, xy = TRUE))
# popcomp[, diff := layer.1 - layer.2]
#
# transform <- function(x) {
#   logged <- log(abs(x) + 1e-6) * sign(x)
#   return(logged)
# }
#
# inv_trans <- function(x) {
#   inv <- (exp(abs(x)) - 1e-6) * sign(x)
#   return(round(inv, 2))
# }
#
# map_compare <-
#   ggplot(popcomp) +
#   geom_raster(aes(x = x, y = y, fill = transform(diff))) +
#   scale_fill_gradient2(labels = inv_trans) +
#   coord_quickmap()
#
# hex_compare <-
#   ggplot(popcomp) +
#   geom_hex(aes(x = layer.1, y = layer.2), color = "grey") +
#   geom_abline(intercept = 0, slope = 1, linetype = 2, color = "grey") +
#   scale_fill_distiller(direction = 1, trans = "log",
#                        labels = function(x) round(x, -1))
#
# interactive plots? (very slow, could try d3?)
# plot_ly(popcomp, x = ~x, y = ~y, z = ~diff) %>%
#   add_heatmap()
#
# ggplot(mada_shape) +
#   geom_point(aes(x = pop1, y = pop2)) +
#   geom_abline(intercept = 0, slope = 1, linetype = 2, color = "grey")
# mada_shape$diff <- mada_shape$pop1 - mada_shape$pop2
#
# ggplot(mada_shape) +
#   geom_histogram(aes(x = diff))
#
# ggplot(mada_shape) +
#   geom_sf(aes(fill = diff))
