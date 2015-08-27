#' etl_scrape
#' 
#' @description a utility function to download a year's worth of airline data
#' 
#' @inheritParams etl::etl_scrape
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
#' 
#' # get two years worth
#' lapply(2012:2013, etl_scrape, obj = etl_airlines)
#' list.files(etl_airlines$dir)
#' }
#' 

etl_scrape.etl_airlines <- function(obj, year = 2013, startMonth = 1, endMonth = 12, ...) {
  thisYear <- as.numeric(format(Sys.Date(), '%Y'))
  if (startMonth < 1 | startMonth > 12) {
    startMonth <- 1
  }
  if (endMonth < 1 | endMonth > 12) {
    endMonth <- 12
  }
  if (startMonth > endMonth) {
    startMonth <- min(startMonth, endMonth)
    endMonth <- max(startMonth, endMonth)
  }
  if (year == 1987) {
    startMonth <- min(startMonth, 10)
  }
  if (year == thisYear) {
    endMonth <- min(endMonth, as.numeric(format(Sys.Date(), '%m')) - 1)
  }
  lapply(startMonth:endMonth, scrape_month, obj = obj, year = year)
  return(obj)
}

scrape_month <- function(obj, year = 2013, month = 1, ...) {
  needed <- paste0(year, "-", month, ".zip")
  
  if (!needed %in% dir(obj$dir)) {
    message("Downloading flight data...")
    url <- flight_url(year, month)
    download.file(url, paste0(obj$dir, "/", needed))
  }
}

flight_url <- function(year = 2013, month) {
  base_url <- "http://www.transtats.bts.gov/Download/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
}
