# popcompr

`popcompr` is an R package to make it easier  different high resolution population datasets for humanitarian and research purposes. It is under active development and has not been released, but the code is available through a [GPL3 license](LICENSE.md). See the documentation at [https://mrajeev08.github.io/popcompr/](https://mrajeev08.github.io/popcompr/).

## Installation

You can install the development version of `popcompr` using the `remotes` package:

``` r
remotes::install_github("mrajeev08/popcompr")
```

## Example using data from Lesotho

Included in the package are two datasets on population estimates in Lesotho (simply choosing Lesotho because its small) downloaded from [HDX](https://data.humdata.org). See `?lso_worlpop_2019` and `?lso_facebook_2019` for more details. You have to access them using the system.file arguments so that the functions can correctly work with the raster files stored on the disk.

This example compares these two datasets at a default resolution of 0.0833 degrees (or approximately 1 km<sup>2</sup> at the equator):

``` r
library(popcompr)

# comparing at pixel level with data included in the package
lesotho_wp_2019 <- raster(system.file("external/lso_facebook_2019.tif", package="popcompr"))
lesotho_fb_2019 <- raster(system.file("external/lso_worldpop_2019.tif", package="popcompr"))
pop_list <- list(lesotho_wp_2019, lesotho_fb_2019)

# compare pop function
compare_pop(pop_list, parallel = FALSE)
```

You can also compare population estimates at the administrative level. Access to country shapefiles is provided through a wrapper to the [geoBoundaries API](https://www.geoboundaries.org/api.html). 
To see available datasets, use `View(iso_codes`)`. An example for Lesotho:

- Get admin shapefile
``` r
# Find the right iso code & see which admin levels are available
dplyr::filter(iso_codes, grepl("Les", country))
les_shape <- get_country_shape(country_iso = "LSO", admin_level = 2)

```

- And then aggregate the population datasets to the admin unit:
``` r
# get admin level comparison
les_shape <- aggregate_to_shp(brick = exe, sf = les_shape, max_adjacent = 100)
```

See the [documentation](https://mrajeev08.github.io/popcompr/) for examples of vizualizations. 

Here are also some great resources on gridded population datasets from CIESIN at Columbia University: [https://sedac.ciesin.columbia.edu/mapping/popgrid](https://sedac.ciesin.columbia.edu/mapping/popgrid).

# Dev in docker

First clone the repo:
```
git clone https://github.com/mrajeev08/popcompr.git
```
Then navigate to the repo and build the image (might take a while if rocker/geospatial is not already built):
```
docker build . -t popcompr
```
Then run your container:
```
docker run -d -p 8787:8787 --name popcompr -e USER=mrajeev -e PASSWORD=pass popcompr:latest
```
Navigate to `http://localhost:8787` in your browser and then use the username and password to use Rstudio. 

## Roadmap

This package is in it's very starting stages. Here's the planned/proposed dev.

### Little fixes
- managing imports from `data.table` & `raster` (including conflict with `shift`)
- supress or manage warnings on `data.table` with `gmin` in `match_nearest`
- generally refactor `match_nearest` to be faster and cleaner
- double check where people go missing (is it because of holes? technically extents should be merged and should cover all the raster inputs)
- better guidance on resolution and rationale for default 
- rename `iso_codes` to geoBoundaries_data
- option to pass a field to aggregate to (i.e. if you download adm3 shapefile, make it easier to aggregate to 
admin 2/1?)

### Refactoring existing functions
- use a unified naming system so that you can programitcally decide what to plot and also parse labels (i.e. data contract)
- right now, defaults to a memory safe aggregation method using chunks regardless of raster size.
  - benchmark to see when single calls are faster
  - programatically decide when to do it the memory safe way (using `raster::canProcessInMemory`)
- warn/error if extents don't match by at least xx% between population rasters or shapefiles
- don't make the user parallelize, but instead use future?
- multithreaded downloads?
- write unit tests!

### Expanding code base
- autoplot functions (use S3 classes)? For static/interactive plots comparing up to N pop
- API access to available population datasets by country:
  - World Pop (has an API)
  - Facebook/CIESIN (no API but on hdx)
  - grid3 (no API but on hdx)
  - GPW4 (no API and requires registration for download)
  - LANDSCAN (no API and requires registration for download)
  - see [https://www.popgrid.org/data-docs-table1](https://www.popgrid.org/data-docs-table1) for more details on all datasets
  - https://github.com/dickoa/rhdx for example of accessing files through hdx api
- option to crop files to an extent and then do the comparison?




