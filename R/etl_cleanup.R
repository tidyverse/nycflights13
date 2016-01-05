#' @rdname etl_load.etl_airlines
#' @inheritParams etl::etl_cleanup
#' @param delete_zip should the ZIP files we downloaded be deleted? 
#' @param delete_csv should the CSV files we downloaded by deleted?
#' @export
#' @method etl_cleanup etl_airlines
#' @examples 
#' 


etl_cleanup.etl_airlines <- function(obj, delete_zip = FALSE, delete_csv = FALSE, ...) {
  if (delete_zip) {
    message(paste0("Deleting ZIP files from ", attr(obj, "raw_dir")))
    raw_files <- list.files(attr(obj, "raw_dir"))
    unlink(paste0(attr(obj, "raw_dir"), "/", raw_files[grepl("\\.zip$", raw_files)]))
  }  
  if (delete_csv) {
    message(paste0("Deleting CSV files from ", attr(obj, "load_dir")))
    load_files <- list.files(attr(obj, "load_dir"))
    unlink(paste0(attr(obj, "load_dir"), "/", load_files[grepl("\\.csv$", load_files)]))
  }
  invisible(obj)
}