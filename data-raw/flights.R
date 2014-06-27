flight_url <- function(year = 2013, month) {
  base_url <- "http://www.transtats.bts.gov/Download/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
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
  read.csv(path, stringsAsFactors = FALSE) %>%
    tbl_df() %>%
    select(
      year = Year, month = Month, day = DayofMonth, dep_time = DepTime,
      dep_delay = DepDelay, arr_time = ArrTime, arr_delay = ArrDelay,
      carrier = Carrier,  tailnum = TailNum, flight = FlightNum,
      origin = Origin, dest = Dest, air_time = AirTime, distance = Distance
    ) %>%
    mutate(hour = dep_time %/% 100, minute = dep_time %% 100) %>%
    filter(dest %in% c("JFK", "LGA", "EWR")) %>%
    arrange(year, month, day, dep_time)
}

all <- lapply(dir("data-raw/flights", full.names = TRUE), get_nyc)
flights <- rbind_all(all) %>% tbl_df()

save(flights, file = "data/flights.rda")
