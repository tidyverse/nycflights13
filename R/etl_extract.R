#' @rdname etl_load.etl_airlines
#' @inheritParams etl::etl_extract
#' @param years a vector of integers representing the years
#' @param months a vector of integers representing the months
#' @details If a \code{year} and/or \code{month} is specified, then
#' only flight data from matching months is used.
#' @export

etl_extract.etl_airlines <- function(obj, years = 2015, months = 1:12, ...) {
  this_year <- as.numeric(format(Sys.Date(), '%Y'))
  years <- intersect(1987:this_year, years)
  months <- intersect(1:12, months)
  
  valid_months <- data.frame(expand.grid(years, months)) %>%
    rename_(year = ~Var1, month = ~Var2) %>%
    filter_(~!(year == 1987 & month < 10)) %>%
    filter_(~!(year == this_year & month > as.numeric(format(Sys.Date(), '%m')) - 1)) %>%
    arrange_(~year, ~month)
  
  mapply(FUN = scrape_month, valid_months$year, valid_months$month, MoreArgs = list(obj = obj))
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
  base_url <- "http://tsdata.bts.gov/PREZIP/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
}
