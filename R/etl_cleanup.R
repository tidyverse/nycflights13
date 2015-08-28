#' @rdname etl_init.etl_airlines
#' @inheritParams etl::etl_cleanup
#' @param delete_zip should the ZIP files we downloaded be deleted? 
#' @param delete_csv should the CSV files we downloaded by deleted?
#' @export
#' @seealso \code{\link[etl]{etl_cleanup}}
#' @method etl_cleanup etl_airlines

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