# flights

library(airlines)
library(dplyr)
db <- src_sqlite(path = "~/dumps/airlines/airlines.sqlite3", create = TRUE)
airlines <- etl("airlines", db, dir = "~/dumps/airlines")
airlines %>%
  etl_create(year = 1987, month = 11)
flights <- tbl(airlines, "flights") %>%
  collect() %>%
  mutate(time_hour = lubridate::ymd_hms(time_hour))
glimpse(flights)
save(flights, file = "data/flights.rda", compress = "xz")
