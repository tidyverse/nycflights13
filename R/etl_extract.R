#' @rdname etl_load.etl_airlines
#' @inheritParams etl::etl_extract
#' @param year a year represented as a four-digit integer
#' @param months a vector of integers representing the months
#' @details If a \code{year} and/or \code{month} is specified, then
#' only flight data from matching months is used.
#' @export

etl_extract.etl_airlines <- function(obj, year = 2015, months = 1:12, ...) {
  thisYear <- as.numeric(format(Sys.Date(), '%Y'))
  months <- intersect(1:12, months)
  if (year == 1987) {
    months <- intersect(10:12, months)
  }
  if (year == thisYear) {
    months <- intersect(1:(as.numeric(format(Sys.Date(), '%m')) - 1), months)
  }
#  obj$files <- append(obj$files, sapply(months, scrape_month, obj = obj, year = year))
  sapply(months, scrape_month, obj = obj, year = year)
  invisible(obj)
}

scrape_month <- function(obj, year = 2013, month = 1, ...) {
  needed <- paste0(year, "-", month, ".zip")
  
  if (!needed %in% dir(attr(obj, "raw_dir"))) {
    message("Downloading flight data...")
    url <- flight_url(year, month)
    download.file(url, paste0(attr(obj, "raw_dir"), "/", needed))
  }
  return(needed)
}

flight_url <- function(year = 2013, month) {
  base_url <- "http://www.transtats.bts.gov/Download/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
}
