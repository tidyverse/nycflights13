#' @title Cleanup after data loaded into DB
#'
#' @inheritParams etl::etl_cleanup
#' @export
#' @method etl_cleanup etl_airlines
#' @family etl functions
#' @examples
#'
#' \dontrun{
#' require(RPostgreSQL)
#' # connect directly
#' require(dplyr)
#' db <- src_postgres("mtcars", user = "postgres", host = "localhost")
#' etl_cars <- etl_connect("mtcars", db)
#' etl_cars %>%
#'  etl_create() %>%
#'  etl_cleanup()
#' }

etl_cleanup.etl_airlines <- function(obj, delete_zip = FALSE, delete_csv = FALSE, ...) {
  files <- list.files(obj$dir)
  if (delete_zip) {
    unlink(paste0(obj$dir, "/", files[grepl("\\.zip$", files)]))
  }  
  if (delete_csv) {
    unlink(paste0(obj$dir, "/", files[grepl("\\.csv$", files)]))
  }
  return(obj)
}