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
#' airlines
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
#' src_tbls(airlines)
#' }
#' 
#' # re-initialize the database with complementary tables
#' \dontrun{
#' airlines %>%
#'   etl_init() %>%
#'   etl_load(year = 2013, months = 6)
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
#'   etl_cleanup(delete_load = TRUE)
#' }


etl_load.etl_airlines <- function(obj, years = 2015, months = 1:12, ...) {
  csvs <- match_files_by_year_months(list.files(attr(obj, "load_dir")), 
                                     pattern = "flights_%Y_%m.csv", years, months)
  sapply(paste0(attr(obj, "load_dir"), "/", csvs), push_month, obj = obj, ...)
  invisible(obj)
}

#' @rdname etl_load.etl_airlines
#' @method etl_init etl_airlines
#' @inheritParams etl::etl_init
#' @importFrom DBI dbSendQuery
#' @export

etl_init.etl_airlines <- function(obj, script = NULL, 
                                  schema_name = "init", 
                                  pkg = attr(obj, "pkg"),
                                  ext = NULL, ...) {
  #  https://github.com/beanumber/airlines/issues/51
  #  DBI::dbSendQuery(obj$con, "DROP VIEW IF EXISTS summary")
  NextMethod()
  init_carriers(obj)
  init_airports(obj)
  init_planes(obj)
  invisible(obj)
}


push_month <- function(obj, csv, ...) {
  # write the table directly to the DB
  message(paste("Importing flight data from", csv, "to the database..."))
  if (DBI::dbWriteTable(obj$con, "flights", csv, append = TRUE, ...)) {
    message("Data was successfully written to database.")
  }
}

#' @importFrom readr read_csv
#' @importFrom DBI dbWriteTable

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
  
  DBI::dbWriteTable(obj$con, "carriers", 
                    as.data.frame(carriers), append = TRUE, row.names = FALSE)
}

#' @importFrom downloader download

init_airports <- function(obj, ...) {
  src <- "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat"
  lcl <- paste0(attr(obj, "raw_dir"), "/airports.dat")
  
  if (!file.exists(lcl)) {
    # https://github.com/beanumber/airlines/issues/30
    # need to test on OS X and Windows
    downloader::download(src, lcl)
  }
  
  raw <- readr::read_csv(lcl, col_names = FALSE)
  names(raw) <- c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "region")
  
  airports <- raw %>% 
    filter_(~country == "United States", ~faa != "") %>%
    filter_(~name != "Beaufort") %>%
    select_(~faa, ~name, ~lat, ~lon, ~alt, ~tz, ~dst, ~city, ~country) %>%
    mutate_(lat = ~as.numeric(lat), lon = ~as.numeric(lon)) %>%
    arrange_(~faa)
  
  DBI::dbWriteTable(obj$con, "airports", 
                    as.data.frame(airports), append = TRUE, row.names = FALSE)
}

init_planes <- function(obj, ...) {
  DBI::dbWriteTable(obj$con, "planes", 
                    as.data.frame(airlines::planes), append = TRUE, row.names = FALSE)
}

