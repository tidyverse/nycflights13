#' ETL functionality for airlines data
#' 
#' @description These functions implement \code{etl_airlines} methods
#' for the core ETL functions defined in \code{\link[etl]{etl}}. 
#' 
#' @inheritParams etl_load.etl_airlines
#' @import etl
#' @importFrom DBI dbWriteTable
#' @importFrom methods is
#' @importFrom utils download.file
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
#'   # if not, try
#'   system("mysql -e 'CREATE DATABASE IF NOT EXISTS airlines;'")
#'   db <- src_mysql(default.file = path.expand("~/.my.cnf"), group = "client",
#'                   user = NULL, password = NULL, dbname = "airlines")
#' }
#' 
#' airlines <- etl("airlines", db, dir = "~/dumps/airlines")
#' # get two months of data
#' airlines %>%
#'   etl_extract(year = 2013, months = 5:6) %>%
#'   etl_transform(year = 2013, months = 5:6) %>%
#'   etl_load(year = 2013, months = 6)
#' }
#' 
#' # re-initialize the database with complementary tables
#' \dontrun{
#' airlines %>%
#'   etl_load(schema = TRUE, year = 2013, months = 6)
#' 
#' # Initialize the database and import one month of data
#' airlines %>%
#'   etl_create(year = 2013, months = 5)
#'  
#'  # add another month WITHOUT re-initializing the database
#'  airlines %>%
#'    etl_update(year = 2013, months = 6)
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


etl_load.etl_airlines <- function(obj, schema = FALSE, years = 2015, months = 1:12, ...) {
  csvs <- dir(attr(obj, "load_dir"), pattern = "\\.csv")
  topush <- match_year_months(csvs, years, months)
  
  if (methods::is(obj$con, "DBIConnection")) {
    if (schema == TRUE & inherits(obj, "src_mysql")) {
      schema <- get_schema(obj, schema_name = "init", pkg = "airlines")
    }
    if (!missing(schema)) {
      if (file.exists(as.character(schema))) {
        dbRunScript(obj$con, schema, ...)
      }
      init_carriers(obj)
      init_airports(obj)
      init_planes(obj)
    }
    sapply(paste0(attr(obj, "load_dir"), "/", topush), push_month, obj = obj, ...)
  } else {
    stop("Invalid connection to database.")
  }
  invisible(obj)
}


push_month <- function(obj, csv, ...) {
  # write the table directly to the DB
  message(paste("Importing flight data from", csv, "to the database..."))
  if (DBI::dbWriteTable(obj$con, "flights", csv, append = TRUE, ...)) {
    message("Data was successfully written to database.")
  }
}


init_carriers <- function(obj, ...) {
  src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
  lcl <- paste0(attr(obj, "raw_dir"), "/carriers.csv")
  
  if (!file.exists(lcl)) {
    utils::download.file(src, lcl)
  }
  
  raw <- readr::read_csv(lcl)
  carriers <- raw %>%
    select_(carrier = ~Code, name = ~Description) %>%
    #  semi_join(flights) %>%
    filter_(~!is.na(carrier)) %>%
    arrange_(~carrier)
  
  dbWriteTable(obj$con, "carriers", as.data.frame(carriers), append = TRUE, row.names = FALSE)
}

init_airports <- function(obj, ...) {
  src <- "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat"
  lcl <- paste0(attr(obj, "raw_dir"), "/airports.dat")
  
  if (!file.exists(lcl)) {
    # https://github.com/beanumber/airlines/issues/30
    # need to test on OS X and Windows
    utils::download.file(src, lcl, method = "curl")
  }
  
  raw <- readr::read_csv(lcl, col_names = FALSE)
  names(raw) <- c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "region")
  
  airports <- raw %>% 
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

