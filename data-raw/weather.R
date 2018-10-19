# From https://mesonet.agron.iastate.edu/request/download.phtml?network=NY_ASOS

library(tidyverse)
library(httr)
library(lubridate)

# Download ---------------------------------------------------------------------

get_asos <- function(station) {
  url <- "http://mesonet.agron.iastate.edu/cgi-bin/request/asos.py?"
  query <- list(
    station = station, data = "all",
    year1 = "2013", month1 = "1", day1 = "1",
    year2 = "2013", month2 = "12", day2 = "31", tz = "GMT",
    format = "comma", latlon = "no", direct = "yes"
  )

  dir.create("data-raw/weather", showWarnings = FALSE, recursive = TRUE)
  r <- GET(url, query = query, write_disk(paste0("./data-raw/weather/", station, ".csv")), progress())
  stop_for_status(r)
}

stations <- c("JFK", "LGA", "EWR")
paths <- paste0(stations, ".csv")
missing <- stations[!(paths %in% dir("data-raw/weather/"))]
walk(missing, get_asos)

# Load ------------------------------------------------------------------------

paths <- dir("data-raw/weather", full.names = TRUE)
all <- map(paths,
  read_csv,
  skip = 5,
  na = "M",
  col_names = TRUE,
  col_types = cols(
    .default = col_double(),
    station = col_character(),
    valid = col_datetime(format = ""),
    skyc1 = col_character(),
    skyc2 = col_character(),
    skyc3 = col_character(),
    skyc4 = col_character(),
    wxcodes = col_character(),
    metar = col_character()
  )
)
raw <- bind_rows(all)

# Rename variables and adjust units
raw2 <- raw %>%
  select(
    origin = station,
    time = valid,
    temp = tmpf,
    dewp = dwpf,
    humid = relh,
    wind_dir = drct,
    wind_speed = sknt,
    wind_gust = gust,
    precip = p01i,
    pressure = mslp,
    visib = vsby
  ) %>%
  mutate(
    # convert to mph
    wind_speed = wind_speed * 1.15078,
    wind_gust = wind_gust * 1.15078,
    # partition time into hour + minute
    minute = minute(time),
    time = update(time, minute = 0)
  )

# Handle repeated records for an hour: precipitation is cumulated hourly until
# minute 51, after which it resets to zero. For more details and additional
# links see https://github.com/rmcd1024/daily_precipitation_totals
raw3 <- raw2 %>%
  filter(minute <= 51) %>%
  group_by(origin, time) %>%
  summarise_all(max) %>%
  ungroup()

# Match structure to flights
weather <- raw3 %>%
  mutate(
    time = with_tz(time, "America/New_York"),
    year = as.integer(year(time)),
    month = as.integer(month(time)),
    day = mday(time),
    hour = hour(time)
  ) %>%
  filter(year == 2013L) %>%
  select(origin, year:hour, temp:visib, time_hour = time)

write_csv(weather, "data-raw/weather.csv")
usethis::use_data(weather, overwrite = TRUE)
