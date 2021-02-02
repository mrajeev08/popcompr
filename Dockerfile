# base image: rocker/verse (with a specific version of R)
#   has R, RStudio, tidyverse, devtools, tex, and publishing-related packages
FROM rocker/geospatial:latest

# required
LABEL maintainer="Malavika Rajeev"

# install package from github
ADD . /home/rstudio/popcompr

RUN Rscript -e 'devtools::install_dev_deps("/home/rstudio/popcompr")'