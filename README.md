
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

## Notes and to do

Functions:
1. Function to create the raster to resample to
2. Function to resample the pop data sets to the lower res scale (chunked or not) (parallelized)
3. Function to compare the population data sets
- put in two rasters
- make the skeleton at appropriate resolution
- (if still not within memory tell the user? Or make it chunkable/memsafe as well)
- resample and brick them/stack them together
- also need to make sure to track lost people (did everyone get matched?)
- Option to compare N rasters
- digg plot = facet & no maps?

Issues to think through
- parallelizing
- when not to chunk a threshold for small stuff? benchmark to compare
- Working in long/lat make this explicit & check it
- Make sure extents are somewhat similar

Second set
1. Function to aggregate the raster brick to an sf file using fasterize!
2. Include a way to match coastlines/missing vals, as well
3. Make comparisons same way (spatially & xy coords)

Autoplot methods
1. for both raster and admin = static/dynamic + plot spatial diff & also xy corr
  - static plot
  - dynamic plot
  
Document & write up all above & share as package on github with Fleur ------------------

API infrastructure
1. country shapefiles from geoboundaries
2. raster datasets from hdx or other api? too slow?
3. options for user to be able to input either pop datasets or shapefiles (with errors when extents don't overlap!)
Easiest way is to use a data file with appropriate urls
use the data contract bit to name things appropriately
30 arc seconds in WGS84 if possible
provider | country | country_code | year | value | projection | resolution | file_url | file_size | info_url
so when you download
you choose a folder to cache things to
you choose a country & a year and you get the available data sets
you choose a value
always download the file! Because you don't actually know peoples mem reqs.?
instructions for folks to submit a pull request = hosted files add to csv in data
popgrid
grid3
other orgs
Ones on hdx:
Grid 3
Facebook/CEISIN
WorlPop
using rhdx style download (for facebook otherwise wont work!)
https://github.com/dickoa/rhdx/blob/master/R/resource.R
Ones on own site (but open):
Global Human Settlement Layer
https://ghsl.jrc.ec.europa.eu/download.php?ds=pop
use country extent and clip the larger file?
if multiple urls for a single tile have a helper function to pull that in
Ones where you need an account:
GPW 4
GRUMP 3
Oakridge LANDSCAN: https://landscan.ornl.gov

- Unit tests (to do / figure out)

Vignettes -------------------------------------------------------------------
- How to query the api & download files (keeping in mind size issues)
- How to compare @ raster scale
- How to compare @ admin scale
- Use user specific datasets (rasters & shapefiles & if things will catch it if not the same extent!)

- Reference to pop grid: https://www.popgrid.org/data-docs-table1



