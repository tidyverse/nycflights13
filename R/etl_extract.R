#' etl_extract
#' 
#' @description a utility function to download a year's worth of airline data
#' 
#' @inheritParams etl::etl_extract
#' @param year a year represented as a four-digit integer
#' @param month the month represented as an integer
#' 
#' @import dplyr
#' @export
#' @family etl functions
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
#' etl_airlines <- etl_extract(etl_airlines, year = 2013)
#' list.files(etl_airlines$dir)
#' 
#' # get two years worth
#' lapply(2012:2013, etl_extract, obj = etl_airlines)
#' list.files(etl_airlines$dir)
#' }
#' 

etl_extract.etl_airlines <- function(obj, year = 2013, month = NULL, ...) {
  thisYear <- as.numeric(format(Sys.Date(), '%Y'))
  if (month < 1 | month > 12) {
    startMonth <- 1
    endMonth <- 12
  } else {
    startMonth <- month
    endMonth <- month
  }
  if (year == 1987) {
    startMonth <- min(startMonth, 10)
  }
  if (year == thisYear) {
    endMonth <- min(endMonth, as.numeric(format(Sys.Date(), '%m')) - 1)
  }
  obj$files <- append(obj$files, sapply(startMonth:endMonth, scrape_month, obj = obj, year = year))
  return(obj)
}

scrape_month <- function(obj, year = 2013, month = 1, ...) {
  needed <- paste0(year, "-", month, ".zip")
  
  if (!needed %in% dir(obj$dir)) {
    message("Downloading flight data...")
    url <- flight_url(year, month)
    download.file(url, paste0(obj$dir, "/", needed))
  }
  return(needed)
}

flight_url <- function(year = 2013, month) {
  base_url <- "http://www.transtats.bts.gov/Download/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
}
