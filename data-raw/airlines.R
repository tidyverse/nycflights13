library(dplyr)
library(readr)

raw <- read_csv("https://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS")

load("data/flights.rda")

airlines <- raw %>%
  select(carrier = Code, name = Description) %>%
  semi_join(flights) %>%
  arrange(carrier)

write_csv(airlines, "data-raw/airlines.csv")
save(airlines, file = "data/airlines.rda")
