library(dplyr)
library(readr)

flight_url <- function(year = 2013, month) {
  base_url <- "https://www.transtats.bts.gov/PREZIP/"
  sprintf(paste0(base_url, "On_Time_Reporting_Carrier_On_Time_Performance_1987_present_%d_%d.zip"), year, month)
}

download_month <- function(year = 2013, month) {
  url <- flight_url(year, month)

  temp <- tempfile(fileext = ".zip")
  download.file(url, temp)

  files <- unzip(temp, list = TRUE)
  # Only extract biggest file
  csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]

  unzip(temp, exdir = "data-raw/flights", junkpaths = TRUE, files = csv)

  src <- paste0("data-raw/flights/", csv)
  dst <- paste0("data-raw/flights/", "2013-", month, ".csv")
  file.rename(src, dst)
}

months <- 1:12
needed <- paste0("2013-", months, ".csv")
missing <- months[!(needed %in% dir("data-raw/flights"))]

lapply(missing, download_month, year = 2013)

get_nyc <- function(path) {
  col_types <- cols(
    DepTime = col_integer(),
    ArrTime = col_integer(),
    CRSDepTime = col_integer(),
    CRSArrTime = col_integer(),
    Reporting_Airline = col_character()#,
    # UniqueCarrier = col_character()
  )
  read_csv(path, col_types = col_types) %>%
    select(
      year = Year, month = Month, day = DayofMonth,
      dep_time = DepTime, sched_dep_time = CRSDepTime, dep_delay = DepDelay,
      arr_time = ArrTime, sched_arr_time = CRSArrTime, arr_delay = ArrDelay,
      carrier = Reporting_Airline, flight = Flight_Number_Reporting_Airline,
      tailnum = Tail_Number, origin = Origin, dest = Dest,
      air_time = AirTime, distance = Distance
    ) %>%
    filter(origin %in% c("JFK", "LGA", "EWR")) %>%
    mutate(
      hour = sched_dep_time %/% 100,
      minute = sched_dep_time %% 100,
      time_hour = lubridate::make_datetime(year, month, day, hour, 0, 0, tz = "America/New_York")
    ) %>%
    arrange(year, month, day, dep_time)
}

all <- lapply(dir("data-raw/flights", full.names = TRUE), get_nyc)
flights <- bind_rows(all)
flights$tailnum[flights$tailnum == ""] <- NA

save(flights, file = "data/flights.rda", compress = "bzip2")
