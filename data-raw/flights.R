# flights

library(airlines)
library(dplyr)
airlines <- etl("airlines", dir = "~/dumps/airlines")
airlines %>%
  etl_create(year = 1999, month = 12)
flights <- tbl(airlines, "flights") %>%
  filter(day > 20) %>%
  collect() %>%
  mutate(time_hour = lubridate::ymd_hms(time_hour))
glimpse(flights)
save(flights, file = "data/flights.rda", compress = "xz")
