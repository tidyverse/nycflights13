#' @title buildIndices
#' 
#' @description Build indices in the airlines database
#' 
#' @param db a \code{dplyr} \code{src} or a \code{DBI} connection
#' 
#' @import dplyr
#' @importFrom DBI dbWriteTable dbGetQuery
#' @export
#' 
#' @examples
#' 
#' library(dplyr)
#' if (require(RPostgreSQL)) {
#'  # must have pre-existing database "airlines"
#'  db <- src_postgres(host = "localhost", user="postgres", password="postgres", dbname = "airlines")
#' }
#' 
#' start <- Sys.time()
#' flights <- tbl(db, "flights")
#' flights %>%
#'   filter(dest == 'BDL') %>%
#'   collect()
#' 
#' end <- Sys.time()
#' end - start
#' 
#' # build the indices
#' \dontrun{
#' buildIndices(db)
#' 
#' start <- Sys.time()
#' flights <- tbl(db, "flights")
#' flights %>%
#'   filter(dest == 'BDL') %>%
#'   collect()
#' 
#' end <- Sys.time()
#' end - start
#' }




buildIndices <- function (db) {
  if ("src" %in% class(db)) {
    con <- db$con
  } else {
    con <- db
  }
  message("Creating indices...")
  dbGetQuery(con, "ALTER TABLE airports ADD CONSTRAINT airports_pk PRIMARY KEY (faa);")
  dbGetQuery(con, "ALTER TABLE carriers ADD CONSTRAINT carrier_pk PRIMARY KEY (carrier);")
  dbGetQuery(con, "ALTER TABLE planes ADD CONSTRAINT tailnum_pk PRIMARY KEY (tailnum);")
  dbGetQuery(con, "CREATE INDEX year_idx on weather(year);")
  dbGetQuery(con, "CREATE INDEX origin_idx on weather(origin);")
  dbGetQuery(con, "CREATE INDEX date_idx on weather(date);")
#  dbGetQuery(con, "CREATE INDEX Year on flights(Year);")
  dbGetQuery(con, "CREATE INDEX Date on flights(Year, Month, Day);")
  dbGetQuery(con, "CREATE INDEX Origin on flights(Origin);")
  dbGetQuery(con, "CREATE INDEX Dest on flights(Dest);")
  dbGetQuery(con, "CREATE INDEX Carrier on flights(Carrier);")
  dbGetQuery(con, "CREATE INDEX TailNum on flights(TailNum);")
}