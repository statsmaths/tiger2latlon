#!/usr/bin/env Rscript -f

# install.packages("fastshp",,"http://rforge.net/",type="source")

library(fastshp)
library(foreign)
library(RCurl)

saveOutput <- function(centShp, lfile, source) {
  bname <- substr(lfile, 1, nchar(lfile) - 4)
  oname <- sprintf("%s/%s.csv.bz2", source, bname)

  fout <- bzfile(oname, "wb")
  on.exit(close(fout))
  write.table(centShp, fout, sep=",", quote=TRUE,
              row.names=FALSE, col.names=FALSE)

  return(NULL)
}


processFile <- function(lfile, source, dname) {
  # save working directory
  wd <- getwd()
  on.exit(system(sprintf("rm %s/*", tempdir())))
  on.exit(setwd(wd), add=TRUE)
  setwd(tempdir())

  # download and unzip file
  bname <- substr(lfile, 1, nchar(lfile) - 4)
  cmd <- sprintf("curl -O %s --retry 14", paste0(dname,lfile))
  system(cmd)
  unzip(lfile)

  # process shape file
  s <- read.shp(paste0(bname,".shp"))
  try({centShp <- round(centr(s)[,1:2],6)}, silent=TRUE)
  dbf <- read.dbf(paste0(bname,".dbf"), as.is=TRUE)
  centShp$geoid <- dbf$GEOID
  centShp <- centShp[,3:1]

  return(centShp)
}


processSource <- function(source) {
  dir.create(source, FALSE)

  # get list of files on the ftp server
  dname <- sprintf("ftp://ftp2.census.gov/geo/tiger/TIGER2015/%s/", source)
  ldir <- getURL(dname, ftplistonly=TRUE)
  ldir <- strsplit(ldir, "\n")[[1]]

  for (lfile in ldir) {
    centShp <- processFile(lfile, source, dname)
    saveOutput(centShp, lfile, source)
  }

}

processSource("TABBLOCK")  # block
processSource("BG")        # block group
processSource("TRACT")     # tract
processSource("COUSUB")    # County Subdivision
processSource("COUNTY")    # County
processSource("STATE")     # State
processSource("ZCTA5")     # Zip code tabulation areas, 5-digits







