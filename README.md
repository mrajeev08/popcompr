
# popcompr

<!-- badges: start -->
<!-- badges: end -->

The goal of popcompr is to ...

## Installation

You can install the released version of popcompr from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("popcompr")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(popcompr)
## basic example code
```

## Road map

1. Get utm zones associated with each country
2. For each raster data set
  - Get the coords
  - Translate them into their UTM coords (using over to get which zone they fall in or fasterize)
  - Create the raster for the utm zone * country & then use 1-based indexing to get their cell id
  - Aggregate to the cell id
  - Take the coordinates of the utm ones and assign
  - Stitch them back together in long lat into a raster
  - Plot and compare diffs etc.
To show:
- UTM grids with rasters
