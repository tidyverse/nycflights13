#' @rdname etl_init.etl_airlines
#' @inheritParams etl_transform.etl_airlines
#' @export

etl_transform.etl_airlines <- function(obj, year = NULL, months = NULL, ...) {
  zipped <- dir(obj$dir, pattern = "\\.zip")
  must_unzip <- match_year_months(zipped, year, months)
  
  unzipped <- dir(obj$dir, pattern = "\\.csv")
  tounzip <- setdiff(must_unzip, gsub("\\.csv", "\\.zip", unzipped))
  
  if (length(tounzip) > 0) {
    lapply(paste0(obj$dir, "/", tounzip), unzip_month)
  }
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
  
  # rename the CSV to match the ZIP
  file.rename(csv_fullpath, gsub(".zip", ".csv", filename))
}


