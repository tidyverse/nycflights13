#' Load airlines data
#' 
#' @description load the airlines data
#' 
#' @inheritParams etl_load.etl_airlines
#' @import etl
#' @importFrom DBI dbWriteTable
#' @method etl_load etl_airlines 
#' @export
#' 
#' @seealso \code{\link[etl]{etl}}, \code{\link[etl]{etl_load}}
#' @examples
#' 
#' # SQLite by default
#' airlines <- etl("airlines")
#' str(airlines)
#' 
#' \dontrun{
#' if (require(RMySQL)) {
#'   # must have pre-existing database "airlines"
#'   db <- src_mysql(user = "r-user", password = "mypass", dbname = "airlines_nick")
#' }
#' 
#' airlines <- etl("airlines", db, dir = "~/dumps/airlines")
#' # get two months of data
#' airlines %>%
#'   etl_extract(year = 2013, months = 5:6) %>%
#'   etl_transform(months = 6) %>%
#'   etl_load(year = 2013, months = 6)
#' }
#' 
#' # re-initialize the database with complementary tables
#' \dontrun{
#' airlines %>%
#'   etl_load(schema = TRUE, year = 2013, months = 5)
#' }
#' 
#' # check the results
#' \dontrun{
#' airlines %>%
#'   tbl("flights") %>%
#'   group_by(year, origin) %>%
#'   summarise(N = n(), min_month = min(month), max_month = max(month)) %>%
#'   arrange(desc(N))
#' }
#' 
#' # delete intermediate files
#' \dontrun{
#' airlines %>%
#'   etl_cleanup(delete_csv = TRUE)
#' }


etl_load.etl_airlines <- function(obj, schema = FALSE, year = 2015, months = 1:12, ...) {
  csvs <- dir(attr(obj, "load_dir"), pattern = "\\.csv")
  topush <- match_year_months(csvs, year, months)
  
  if (is(obj$con, "DBIConnection")) {
    if (schema == TRUE) {
      schema <- get_schema(obj, schema_name = "init", pkg = "airlines")
      cat(schema)
    }
    if (!missing(schema)) {
      message(dbRunScript(obj$con, schema, ...))
      init_carriers(obj)
      init_airports(obj)
      init_planes(obj)
      init_weather(obj)
    }
    sapply(paste0(attr(obj, "load_dir"), "/", topush), push_month, obj = obj, ...)
  } else {
    stop("Invalid connection to database.")
  }
  invisible(obj)
}


push_month <- function(obj, csv, ...) {
  message(paste("Reading flight data from", csv))
  flights <- tbl_df(get_flights(csv))
  message(print(object.size(flights), units = "Mb"))
  
  # write the table to the DB
  message("Writing flight data to the database...")
  if (DBI::dbWriteTable(obj$con, "flights", as.data.frame(flights), append = TRUE, row.names = FALSE, ...)) {
    message("Data was successfully written to database.")
    message(DBI::dbListTables(obj$con))
  }
    
  # remove the data frame
  rm(flights)
}

get_flights <- function(csv) {
  read.csv(csv, stringsAsFactors = FALSE) %>%
    tbl_df() %>%
    select_(
      year = ~Year, month = ~Month, day = ~DayofMonth, dep_time = ~DepTime,
      dep_delay = ~DepDelay, arr_time = ~ArrTime, arr_delay = ~ArrDelay,
      carrier = ~Carrier,  tailnum = ~TailNum, flight = ~FlightNum,
      origin = ~Origin, dest = ~Dest, air_time = ~AirTime, distance = ~Distance,
      cancelled = ~Cancelled
    ) %>%
#    mutate_(hour = ~dep_time %/% 100, minute = ~dep_time %% 100) %>%
    #    filter(origin %in% c("JFK", "LGA", "EWR")) %>%
    arrange_(~year, ~month, ~day, ~dep_time)
}

init_carriers <- function(obj, ...) {
  src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
  lcl <- paste0(attr(obj, "raw_dir"), "/carriers.csv")
  
  if (!file.exists(lcl)) {
    download.file(src, lcl)
  }
  
  raw <- read.csv(lcl)
  carriers <- raw %>%
    tbl_df() %>%
    select_(carrier = ~Code, name = ~Description) %>%
    #  semi_join(flights) %>%
    filter_(~!is.na(carrier)) %>%
    arrange_(~carrier)
  
  dbWriteTable(obj$con, "carriers", as.data.frame(carriers), append = TRUE, row.names = FALSE)
}

init_airports <- function(obj, ...) {
  src <- "http://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat"
  lcl <- paste0(attr(obj, "raw_dir"), "/airports.dat")
  
  if (!file.exists(lcl)) {
    download.file(src, lcl)
  }
  
  raw <- read.csv(lcl, header = FALSE, stringsAsFactors = FALSE)
  names(raw) <- c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "region")
  
  airports <- raw %>% 
    tbl_df() %>%
    filter_(~country == "United States", ~faa != "") %>%
    filter_(~name != "Beaufort") %>%
    select_(~faa, ~name, ~lat, ~lon, ~alt, ~tz, ~dst, ~city, ~country) %>%
    mutate_(lat = ~as.numeric(lat), lon = ~as.numeric(lon)) %>%
    arrange_(~faa)
  
  dbWriteTable(obj$con, "airports", as.data.frame(airports), append = TRUE, row.names = FALSE)
}

init_planes <- function(obj, ...) {
  dbWriteTable(obj$con, "planes", as.data.frame(planes), append = TRUE, row.names = FALSE)
}

init_weather <- function(obj, ...) {
  dbWriteTable(obj$con, "weather", as.data.frame(weather), append = TRUE, row.names = FALSE)
}

