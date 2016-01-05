#' @rdname etl_load.etl_airlines
#' @inheritParams etl_transform.etl_airlines
#' @export

etl_transform.etl_airlines <- function(obj, year = 2015, months = 1:12, ...) {
  zipped <- dir(attr(obj, "raw_dir"), pattern = "\\.zip")
  must_unzip <- match_year_months(zipped, year, months)
  
  unzipped <- dir(attr(obj, "load_dir"), pattern = "\\.csv")
  tounzip <- setdiff(must_unzip, gsub("\\.csv", "\\.zip", unzipped))
  
  if (length(tounzip) > 0) {
    lapply(paste0(attr(obj, "raw_dir"), "/", tounzip), unzip_month)
  }
  invisible(obj)
}

unzip_month <- function(filename) {
  files <- unzip(filename, list = TRUE)
  # Only extract biggest file
  csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]
  message(paste("Unzipping", csv))
  load_dir <- gsub("/raw", "/load", dirname(filename))
  unzip(filename, exdir = load_dir, overwrite = TRUE, junkpaths = TRUE, files = csv)
  
  # fix unprintable charater bug. See:
  # https://github.com/beanumber/airlines/issues/11
  csv_fullpath <- paste0(load_dir, "/", csv)
  if (grepl("2001_3.csv", csv_fullpath)) {
    bad <- readLines(csv_fullpath)
    good <- gsub("[^[:print:]]", "", bad)
    writeLines(good, csv_fullpath)
  }
  
  # rename the CSV to match the ZIP
  csv_new_path <- gsub(".zip", ".csv", paste0(load_dir, "/", basename(filename)))
  file.rename(csv_fullpath, csv_new_path)
}


