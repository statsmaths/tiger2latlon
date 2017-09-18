#!/usr/bin/env Rscript -f

# install.packages("fastshp",,"http://rforge.net/",type="source")

library(fastshp)
library(foreign)
library(RCurl)

saveOutput <- function(centShp, lfile, oname) {

  fout <- bzfile(oname, "wb")
  on.exit(close(fout))
  write.table(centShp, fout, sep=",", quote=TRUE,
              row.names=FALSE, col.names=TRUE)

  return(NULL)
}

processFile <- function(lfile, source, dname) {
  # save working directory
  wd <- getwd()
  on.exit(system(sprintf("rm %s/*", tempdir())))
  on.exit(setwd(wd), add=TRUE)
  setwd(tempdir())

  dname <- sprintf("https://www2.census.gov/geo/tiger/TIGER2015/%s/", source)

  # download and unzip file
  f <- RCurl::CFILE(lfile, mode="wb")
  ret <- RCurl::curlPerform(url = file.path(dname, lfile), writedata = f@ref, noprogress=FALSE)
  RCurl::close(f)

  bname <- substr(lfile, 1, nchar(lfile) - 4)
  # cmd <- sprintf("curl -O %s --retry 14", paste0(dname, lfile))
  # system(cmd)
  unzip(lfile)

  # process shape file
  s <- read.shp(paste0(bname,".shp"))
  try({centShp <- round(centr(s)[,2:1],6)}, silent=TRUE)
  dbf <- read.dbf(paste0(bname,".dbf"), as.is=TRUE)
  colnames(dbf) <- tolower(colnames(dbf))
  colnames(centShp) <- c("lat", "lon")
  dbf <- cbind(dbf, centShp)

  return(dbf)
}


processSource <- function(source) {
  dir.create(source, FALSE)

  # get list of files on the ftp server
  dname <- sprintf("ftp://ftp2.census.gov/geo/tiger/TIGER2015/%s/", source)
  ldir <- getURL(dname, ftplistonly=TRUE)
  ldir <- strsplit(ldir, "\n")[[1]]

  for (lfile in ldir) {
    bname <- substr(lfile, 1, nchar(lfile) - 4)
    oname <- sprintf("%s/%s.csv.bz2", source, bname)
    if (!file.exists(oname)) {
      centShp <- processFile(lfile, source, dname)
      saveOutput(centShp, lfile, oname)
    }
  }

}

#processSource("TABBLOCK")  # block
#processSource("BG")        # block group
#processSource("TRACT")     # tract
#processSource("COUNTY")    # county
#processSource("STATE")     # state
#processSource("ZCTA5")     # zip code "tabulation areas", 5-digits

processSource("CSA")  # block
processSource("CBSA")  # block






