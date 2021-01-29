f6 <- function(x, a, filename = '') {

  out <- raster(x)
  small <- canProcessInMemory(out, 3)

  filename <- trim(filename)

  if (! small & filename == '') {
    filename <- rasterTmpFile()
  }
  if (filename != '') {
    out <- writeStart(out, filename, overwrite=TRUE)
    todisk <- TRUE
  } else {
    vv <- matrix(ncol = nrow(out), nrow = ncol(out))
    todisk <- FALSE
  }

  bs <- blockSize(r)

  for (i in 1:bs$n) {
    v <- getValues(x, row=bs$row[i], nrows=bs$nrows[i])
    v <- v + a # setting the values for the other raster this way
    if (todisk) {
      out <- writeValues(out, v, bs$row[i])
    } else {
      cols <- bs$row[i]:(bs$row[i]+bs$nrows[i]-1)
      vv[,cols] <- matrix(v, nrow=ncol(out))
    }
  }
  if (todisk) {
    out <- writeStop(out)
  } else {
    out <- setValues(out, as.vector(vv))
  }
  return(out)
}
s <- f6(r, 5)
