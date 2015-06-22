#' @title push
#' 
#' @description a utility function to push a data frame to a DB.
#' 
#' @param db a \code{dplyr} \code{src} or a \code{DBI} connection
#' @param df a \code{tbl_df} to push to the database server
#' @param year a year represented as a four-digit integer
#' @param tablename the name of the table in the database to which you want to 
#' push the data. The default is "flights".
#' @param append append these rows to an existing table?
#' @param row.names include the row.names as the first column in the table? 
#' @param ... arguments passed to \code{getMonth} or \code{dbWriteTable}.
#' 
#' @import dplyr
#' @importFrom DBI dbWriteTable
#' @export
#' 
#' @examples
#' 
#' library(dplyr)
#' if (require(RMySQL)) {
#'  # must have pre-existing database "airlines"
#'  db <- src_mysql(host = "localhost", user="bbaumer", password="fakepass", dbname = "airlines")
#' }
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

push <- function (db, df, tablename, ...) {
  if ("src" %in% class(db)) {
    con <- db$con
  } else {
    con <- db
  }
  message("Writing database table: ", tablename)
  # # dplyr way -- doesn't work
  # copy_to(db, weather, "weather")
  dbWriteTable(con, tablename, as.data.frame(df), ...)
}

#' @export
#' @rdname push

pushFlights <- function (db, df, tablename = "flights", append=TRUE, row.names = FALSE) {
  push(db, df, tablename = "flights", append = append, row.names = row.names)
}

#' @export
#' @rdname push

pushFlightsYear <- function(db, year, ...) {
  for(i in 1:12) {
    flights <- getMonth(year, i, ...)
    pushFlights(db, flights)
    rm(flights)
  }
}

