#' ETL functionality for the airlines database
#' @description Perform ETL operations on the airlines database.
#' 
#' @inheritParams etl::etl_init
#' 
#' @details This will initialize and populate the database.
#' 
#' @method etl_init etl_airlines
#' @import etl
#' @import dplyr
#' @importFrom DBI dbWriteTable
#' @export
#' @seealso \code{\link[etl]{etl_init}}
#' 
#' @examples
#' 
#' require(dplyr)
#' \dontrun{
#' if (require(RPostgreSQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_postgres(host = "localhost", user = "postgres", dbname = "airlines")
#' }
#' airlines <- etl_connect("airlines", db)
#' etl_init(airlines)
#' 
#' if (require(RMySQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_mysql(user = "mysql", password = "mysql", dbname = "airlines")
#' }
#' airlines <- etl_connect("airlines", db)
#' etl_init(airlines)
#' 
#' etl_update(airlines, year = 2013, month = 6)
#' }

etl_init.etl_airlines <- function(obj, ...) {
  if (class(obj$con) == "MySQLConnection") {
    sql <- system.file("sql", "init.mysql", package = "airlines")
  } else if (class(obj$con) == "PostgreSQLConnection") {
    sql <- system.file("sql", "init.psql", package = "airlines")
  } else {
    sql <- system.file("sql", "init.sql", package = "airlines")
  }
  obj$init <- dbRunScript(obj$con, sql)
  init_carriers(obj)
  init_airports(obj)
  init_planes(obj)
  init_weather(obj)
  return(obj)
}

init_carriers <- function(obj, ...) {
  src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
  lcl <- paste0(obj$dir, "/carriers.csv")
  
  if (!file.exists(lcl)) {
    download.file(src, lcl)
  }
  obj$files <- append(obj$files, lcl)
  
  raw <- read.csv(lcl)
  carriers <- raw %>%
    tbl_df() %>%
    select_(carrier = ~Code, name = ~Description) %>%
    #  semi_join(flights) %>%
    filter_(~!is.na(carrier)) %>%
    arrange_(~carrier)
  
  dbWriteTable(obj$con, "carriers", as.data.frame(carriers), overwrite = TRUE, row.names = FALSE)
}

init_airports <- function(obj, ...) {
  src <- "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat"
  lcl <- paste0(obj$dir, "/airports.dat")
  
  if (!file.exists(lcl)) {
    download.file(src, lcl)
  }
  obj$files <- append(obj$files, lcl)
  
  raw <- read.csv(lcl, header = FALSE, stringsAsFactors = FALSE)
  names(raw) <- c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "region")
  
  airports <- raw %>% 
    tbl_df() %>%
    filter_(~country == "United States", ~faa != "") %>%
    filter_(~name != "Beaufort") %>%
    select_(~faa, ~name, ~lat, ~lon, ~alt, ~tz, ~dst) %>%
    mutate_(lat = ~as.numeric(lat), lon = ~as.numeric(lon)) %>%
    arrange_(~faa)
  
  dbWriteTable(obj$con, "airports", as.data.frame(airports), overwrite = TRUE, row.names = FALSE)
}

init_planes <- function(obj, ...) {
  dbWriteTable(obj$con, "planes", as.data.frame(planes), overwrite = TRUE, row.names = FALSE)
}

init_weather <- function(obj, ...) {
  dbWriteTable(obj$con, "weather", as.data.frame(weather), overwrite = TRUE, row.names = FALSE)
}