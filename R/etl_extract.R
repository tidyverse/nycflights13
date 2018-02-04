#' @rdname etl_load.etl_airlines
#' @inheritParams etl::etl_extract
#' @param years a vector of integers representing the years
#' @param months a vector of integers representing the months
#' @details If a \code{year} and/or \code{month} is specified, then
#' only flight data from matching months is used.
#' @export

etl_extract.etl_airlines <- function(obj, years = 2015, months = 1:12, ...) {
  
  valid_months <- valid_year_month(years, months, begin = "1987-10-01") %>%
    mutate_(url = ~paste0("http://transtats.bts.gov/PREZIP/On_Time_On_Time_Performance_", 
                     year, "_", month, ".zip"))
  
  message("Downloading flight data...")
  smart_download(obj, valid_months$url)
  invisible(obj)
}
