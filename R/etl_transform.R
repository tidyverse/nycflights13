globalVariables(".")

#' @rdname etl_load.etl_airlines
#' @inheritParams etl_transform.etl_airlines
#' @export

etl_transform.etl_airlines <- function(obj, years = 2015, months = 1:12, ...) {
  zipped <- dir(attr(obj, "raw_dir"), pattern = "\\.zip")
  must_unzip <- match_year_months(zipped, years, months)
  
  unzipped <- dir(attr(obj, "load_dir"), pattern = "\\.csv")
  cat(unzipped)
  missing <- !gsub("On_Time_On_Time_Performance", "flights", must_unzip) %in% 
    gsub("\\.csv", "\\.zip", unzipped)
  tounzip <- must_unzip[missing]
  
  if (length(tounzip) > 0) {
    lapply(paste0(attr(obj, "raw_dir"), "/", tounzip), clean_flights)
  }
  invisible(obj)
}

#' @importFrom readr read_csv
#' @importFrom lubridate make_datetime

clean_flights <- function(path_zip) {
  # rename the CSV to match the ZIP
  load_dir <- gsub("/raw", "/load", dirname(path_zip))
  path_csv <- basename(path_zip) %>%
    gsub("On_Time_On_Time_Performance", "flights", x = .) %>%
    paste0(load_dir, "/", x = .) %>%
    gsub("\\.zip", "\\.csv", x = .)
  # col_types <- readr::cols(
  #   DepTime = col_integer(),
  #   ArrTime = col_integer(),
  #   CRSDepTime = col_integer(),
  #   CRSArrTime = col_integer(),
  #   Carrier = col_character()
  # )
  # can't get col_types argument to work!
  # readr::read_csv(path_zip, col_types = col_types) %>%
  readr::read_csv(path_zip) %>%
    select_(
      year = ~Year, month = ~Month, day = ~DayofMonth, 
      dep_time = ~as.numeric(DepTime), sched_dep_time = ~as.numeric(CRSDepTime), dep_delay = ~DepDelay, 
      arr_time = ~as.numeric(ArrTime), sched_arr_time = ~as.numeric(CRSArrTime), arr_delay = ~ArrDelay, 
      carrier = ~Carrier,  tailnum = ~TailNum, flight = ~FlightNum,
      origin = ~Origin, dest = ~Dest, air_time = ~AirTime, distance = ~Distance,
      cancelled = ~Cancelled
    ) %>%
#    filter(origin %in% c("JFK", "LGA", "EWR")) %>%
    mutate_(hour = ~as.numeric(sched_dep_time) %/% 100,
           minute = ~as.numeric(sched_dep_time) %% 100,
           time_hour = ~lubridate::make_datetime(year, month, day, hour, minute, 0)) %>%
#    mutate_(tailnum = ~ifelse(tailnum == "", NA, tailnum)) %>%
    arrange_(~year, ~month, ~day, ~dep_time) %>%
    readr::write_csv(path = path_csv)
}

## deprecated
# 
# unzip_month <- function(path_zip) {
#   files <- unzip(path_zip, list = TRUE)
#   # Only extract biggest file
#   csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]
#   message(paste("Unzipping", csv))
#   load_dir <- gsub("/raw", "/load", dirname(path_zip))
#   unzip(path_zip, exdir = load_dir, overwrite = TRUE, junkpaths = TRUE, files = csv)
#   
#   # fix unprintable charater bug. See:
#   # https://github.com/beanumber/airlines/issues/11
#   # UPDATE: this doesn't seem to be an issue since readr uses UTF-8 by default
#   path_csv <- paste0(load_dir, "/", csv)
#   if (grepl("2001_3.csv", path_csv)) {
#     bad <- readLines(path_csv)
#     good <- gsub("[^[:print:]]", "", bad)
#     writeLines(good, path_csv)
#   }
#   
#   # rename the CSV to match the ZIP
#   path_csv_new <- gsub(".zip", ".csv", paste0(load_dir, "/", basename(path_zip)))
#   file.rename(path_csv, path_csv_new)
#   return(path_csv_new)
# }
