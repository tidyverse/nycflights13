
match_year_months <- function(files, years = 1987:as.numeric(format(Sys.Date(), '%Y')), months = 1:12, ...) {
  if (!is.null(years)) {
    keep_y <- match_years(files, years)
  } else {
    keep_y <- files
  }
  keep_m <- match_months(files, months)
  return(intersect(keep_y, keep_m))
}

match_year <- function(files, year = 2000, ...) {
  files[grepl(year, files)]
}

match_years <- function(files, years = 1987:as.numeric(format(Sys.Date(), '%Y')), ...) {
  unlist(lapply(years, match_year, files = files))
}

match_month <- function(files, month = 1, ...) {
  files[grepl(paste0("(-|_)", month, "\\."), files)]
}

match_months <- function(files, months = 1:12, ...) {
  unlist(lapply(months, match_month, files = files))
}