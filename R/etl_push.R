#' etl_push
#' 
#' @description a utility function to push a data frame to a DB.
#' 
#' @inheritParams etl::etl_push
#' @param year four-digit integer indicating the year to upload
#' @param month integer indicating the month to upload
#' @import dplyr
#' @importFrom DBI dbWriteTable
#' @method etl_push etl_airlines 
#' @export
#' 
#' @examples
#' 
#' \dontrun{
#' library(dplyr)
#' if (require(RMySQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_mysql(user = "mysql", password = "mysql", dbname = "airlines")
#' }
#' library(etl)
#' etl_airlines <- etl_connect("airlines", db, dir = "~/dumps/airlines")
#' # get one entire year of data
#' etl_airlines <- etl_airlines %>%
#'   etl_scrape(year = 2013) %>%
#'   etl_process(month = 6) %>%
#'   etl_push(year = 2013, month = 6)
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


etl_push.etl_airlines <- function(obj, year = NULL, month = NULL, ...) {
  csvs <- dir(obj$dir, pattern = "\\.csv")
  topush <- match_year_month(csvs, year, month)
  
  obj$push <- sapply(paste0(obj$dir, "/", topush), push_month, obj = obj, ...)
  return(obj)
}


push_month <- function(obj, csv, ...) {
  message(paste("Reading flight data from", csv))
  flights <- tbl_df(get_flights(csv))
  message(print(object.size(flights), units = "Mb"))
  
  # write the table to the DB
  message("Writing flight data to the database...")
  msg <- dbWriteTable(obj$con, "flights", as.data.frame(flights), append = TRUE, row.names = FALSE, ...)
  # remove the data frame
  rm(flights)
  return(msg)
}

get_flights <- function(csv) {
  read.csv(csv, stringsAsFactors = FALSE) %>%
    tbl_df() %>%
    select_(
      year = ~Year, month = ~Month, day = ~DayofMonth, dep_time = ~DepTime,
      dep_delay = ~DepDelay, arr_time = ~ArrTime, arr_delay = ~ArrDelay,
      carrier = ~Carrier,  tailnum = ~TailNum, flight = ~FlightNum,
      origin = ~Origin, dest = ~Dest, air_time = ~AirTime, distance = ~Distance
    ) %>%
#    mutate_(hour = ~dep_time %/% 100, minute = ~dep_time %% 100) %>%
    #    filter(origin %in% c("JFK", "LGA", "EWR")) %>%
    arrange_(~year, ~month, ~day, ~dep_time)
}


