globalVariables(c("year", "month", "filename"))

#' @rdname etl_load.etl_airlines
#' @inheritParams etl::etl_extract
#' @param years a vector of integers representing the years
#' @param months a vector of integers representing the months
#' @details If a \code{year} and/or \code{month} is specified, then
#' only flight data from matching months is used.
#' @export

etl_extract.etl_airlines <- function(obj, years = 2015, months = 1:12, ...) {
  
  valid_months <- valid_year_month(years, months, begin = "1987-10-01") %>%
    dplyr::mutate(
      url = paste0("http://transtats.bts.gov/PREZIP/On_Time_Reporting_Carrier_On_Time_Performance_1987_present_", 
                   year, "_", month, ".zip"), 
      filename = gsub("Reporting_Carrier_", "", url), 
      filename = gsub("1987_present_", "", filename),
      filename = basename(filename)
    )
  
  message("Downloading flight data...")
  etl::smart_download(obj, valid_months$url, 
                      new_filenames = valid_months$filename)
  invisible(obj)
}
