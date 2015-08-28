
match_year_months <- function(files, year = NULL, months = 1:12, ...) {
  if (!is.null(year)) {
    keep_y <- match_year(files, year)
  } else {
    keep_y <- files
  }
  keep_m <- match_months(files, months)
  return(intersect(keep_y, keep_m))
}

match_year <- function(files, year = 2000, ...) {
  files[grepl(year, files)]
}

match_month <- function(files, month = 1, ...) {
  files[grepl(paste0("(-|_)", month, "\\."), files)]
}

match_months <- function(files, months = 1:12, ...) {
  unlist(lapply(months, match_month, files = files))
}