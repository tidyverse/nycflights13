
match_year_month <- function(files, year = NULL, month = NULL, ...) {
  ignore <- NULL
  if (!is.null(year)) {
    ignore <- union(ignore, files[!grepl(year, files)])
  }  
  if (!is.null(month)) {
    ignore <- union(ignore, files[!grepl(paste0(month, "\\."), files)])
  }
  return(setdiff(files, ignore))
}