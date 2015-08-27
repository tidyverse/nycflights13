#' etl_init
#' 
#' @description Initialize the database.
#' 
#' @inheritParams etl::etl_init
#' 
#' @details This will initialize the database.
#' 
#' @method etl_init etl_airlines
#' 
#' @import etl
#' @export
#' @seealso \code{\link[etl]{etl_init}}
#' 
#' @examples
#' 
#' library(dplyr)
#' library(etl)
#' 
#' \dontrun{
#' if (require(RPostgreSQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_postgres(host = "localhost", user = "postgres", dbname = "airlines")
#' }
#' etl_airlines <- etl_connect("airlines", db)
#' etl_init(etl_airlines)
#' 
#' if (require(RMySQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_mysql(user = "mysql", password = "mysql", dbname = "airlines")
#' }
#' etl_airlines <- etl_connect("airlines", db)
#' etl_init(etl_airlines)
#' }

etl_init.etl_airlines <- function(obj, ...) {
  # sql <- system.file(package = "airlines")
  obj$init <- dbRunScript(obj$con, "~/Dropbox/lib/airlines/inst/sql/init.mysql")
  return(obj)
}

carriers <- function(obj, ...) {
  src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
  lcl <- paste0(obj$dir, "/carriers.csv")
  
  if (!file.exists(lcl)) {
    download.file(src, lcl)
  }
  obj$files <- append(obj$files, lcl)
  
  raw <- read.csv(lcl)
  carriers <- raw %>%
    tbl_df() %>%
    select(carrier = Code, name = Description) %>%
    #  semi_join(flights) %>%
    filter(!is.na(carrier)) %>%
    arrange(carrier)
  
  dbWriteTable(obj$con, "carriers", as.data.frame(carriers), overwrite = TRUE, row.names = FALSE)
}

airports <- function(obj, ...) {
  src <- "http://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/airports.dat?format=raw"
  lcl <- paste0(obj$dir, "/airports.dat")
  
  if (!file.exists(lcl)) {
    download.file(src, lcl)
  }
  obj$files <- append(obj$files, lcl)
  
  raw <- read.csv(lcl, header = FALSE, stringsAsFactors = FALSE)
  names(raw) <- c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst")
  
  airports <- raw %>% 
    tbl_df() %>%
    filter(country == "United States", faa != "") %>%
    filter(name != "Beaufort") %>%
    select(faa, name, lat, lon, alt, tz, dst) %>%
    mutate(lat = as.numeric(lat), lon = as.numeric(lon)) %>%
    arrange(faa)
  
  dbWriteTable(obj$con, "airports", as.data.frame(airports), overwrite = TRUE, row.names = FALSE)
}

planes <- function(obj, ...) {
  dbWriteTable(obj$con, "planes", as.data.frame(planes), overwrite = TRUE, row.names = FALSE)
}