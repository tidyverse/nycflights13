#' etl_process
#' 
#' @description a utility function to process a single month's worth of airline data
#' 
#' @inheritParams etl::etl_process
#' @param year a year represented as a four-digit integer
#' @param month the month represented as an integer
#' 
#' @import dplyr
#' @export
#' 
#' @examples
#' 
#' \dontrun{
#' 
#' library(dplyr)
#' if (require(RMySQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_mysql(user = "mysql", password = "mysql", dbname = "airlines")
#' }
#' library(etl)
#' etl_airlines <- etl_connect("airlines", db, dir = "~/dumps/airlines")
#' # get one entire year of data
#' etl_airlines <- etl_scrape(etl_airlines, year = 2013)
#' list.files(etl_airlines$dir)
#' etl_process(etl_airlines, month = 6)
#' list.files(etl_airlines$dir)
#' }


etl_process.etl_airlines <- function(obj, year = NULL, month = NULL, ...) {
  zips <- dir(obj$dir, pattern = "\\.zip")
  tounzip <- match_year_month(zips, year, month)
  
  lapply(paste0(obj$dir, "/", tounzip), unzip_month, dir = obj$dir)
  return(obj)
}

unzip_month <- function(filename, dir) {
  files <- unzip(filename, list = TRUE)
  # Only extract biggest file
  csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]
  message(paste("Unzipping", csv))
  unzip(filename, exdir = dir, overwrite = TRUE, junkpaths = TRUE, files = csv)
  #  src <- paste0(obj$dir, "/", csv)
  #  dst <- paste0(obj$dir, "/", year, "-", month, ".csv")
  #  file.rename(src, dst)
}


