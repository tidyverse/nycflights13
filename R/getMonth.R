#' @title getMonth
#' 
#' @description a utility function to download a single month's worth of airline data
#' 
#' @param year a year represented as a four-digit integer
#' @param month the month represented as an integer
#' @param temp.dir a directory to store the raw montly data files to be downloaded.
#' 
#' @import dplyr
#' @export
#' 
#' @examples
#' 
#' library(dplyr)
#' \dontrun{
#' May <- getMonth(year = 2013, month = 5)
#' head(May)
#' dim(May)
#' May %>%
#'   group_by(year, origin) %>%
#'   summarise(N = n(), min.month = min(month), max.month = max(month)) %>%
#'   arrange(desc(N))
#' }
#' 



getMonth <- function(year = 2013, month = 1, temp.dir = tempdir()) {

  needed <- paste0("2013-", month, ".csv")
  
  if (!needed %in% dir(temp.dir)) {
    message("Downloading flight data...")
    download_month(year = year, month = month, temp.dir = temp.dir)
  }
  
  message(paste("Reading flight data from", needed))
  flights <- tbl_df(get_flights(paste0(temp.dir, "/", needed)))

  return(flights)
}



flight_url <- function(year = 2013, month) {
  base_url <- "http://www.transtats.bts.gov/Download/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
}

download_month <- function(year = 2013, month, temp.dir) {
  url <- flight_url(year, month)

  temp <- tempfile(fileext = ".zip")
  download.file(url, temp)

  files <- unzip(temp, list = TRUE)
  # Only extract biggest file
  csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]

  unzip(temp, exdir = temp.dir, junkpaths = TRUE, files = csv)

  src <- paste0(temp.dir, "/", csv)
  dst <- paste0(temp.dir, "/", year, "-", month, ".csv")
  file.rename(src, dst)
}


get_flights <- function(path) {
  read.csv(path, stringsAsFactors = FALSE) %>%
    tbl_df() %>%
    select_(
      year = ~Year, month = ~Month, day = ~DayofMonth, dep_time = ~DepTime,
      dep_delay = ~DepDelay, arr_time = ~ArrTime, arr_delay = ~ArrDelay,
      carrier = ~Carrier,  tailnum = ~TailNum, flight = ~FlightNum,
      origin = ~Origin, dest = ~Dest, air_time = ~AirTime, distance = ~Distance
    ) %>%
    mutate_(hour = ~dep_time %/% 100, minute = ~dep_time %% 100) %>%
#    filter(origin %in% c("JFK", "LGA", "EWR")) %>%
    arrange_(~year, ~month, ~day, ~dep_time)
}

