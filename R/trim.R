#' @title trim
#' 
#' @description Enforce minimal referential integrity on the flights DB. 
#' 
#' @import dplyr
#' @importFrom DBI dbWriteTable
#' @export
#' 
#' @examples
#' 
#' library(dplyr)
#' 
#' if (require(RPostgreSQL)) {
#'  # must have pre-existing database "airlines"
#'  db <- src_postgres(host = "localhost", user="postgres", password="postgres", dbname = "airlines")
#' }
#' 
#' #' # save files in a specific location
#' \dontrun{
#' feb <- getMonth(year = 2013, month = 2, temp.dir = "~/dumps")
#' pushFlights(db, feb)
#' pushYear(db, year = 2013, temp.dir = "~/dumps")
#' }
#' 
#' #' # check the results
#' \dontrun{
#' flights.db <- tbl(db, "flights")
#' flights.db %>%
#'   group_by(year, origin) %>%
#'   summarise(N = n(), min.month = min(month), max.month = max(month)) %>%
#'   arrange(desc(N))
#' }

trim <- function () {
  
}