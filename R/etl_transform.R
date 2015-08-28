#' @rdname etl_init.etl_airlines
#' @inheritParams etl_transform.etl_airlines
#' @export

etl_transform.etl_airlines <- function(obj, year = NULL, month = NULL, ...) {
  zips <- dir(obj$dir, pattern = "\\.zip")
  tounzip <- match_year_month(zips, year, month)
  
  lapply(paste0(obj$dir, "/", tounzip), unzip_month)
  return(obj)
}

unzip_month <- function(filename) {
  files <- unzip(filename, list = TRUE)
  # Only extract biggest file
  csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]
  message(paste("Unzipping", csv))
  unzip(filename, exdir = dirname(filename), overwrite = TRUE, junkpaths = TRUE, files = csv)
  
  # fix unprintable charater bug. See:
  # https://github.com/beanumber/airlines/issues/11
  csv_fullpath <- paste0(dirname(filename), "/", csv)
  if (grepl("2001_3.csv", csv_fullpath)) {
    bad <- readLines(csv_fullpath)
    good <- gsub("[^[:print:]]", "", bad)
    writeLines(good, csv_fullpath)
  }
  
  #  src <- paste0(obj$dir, "/", csv)
  #  dst <- paste0(obj$dir, "/", year, "-", month, ".csv")
  #  file.rename(src, dst)
}


