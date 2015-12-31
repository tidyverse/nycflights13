library(dplyr)
library(readr)

src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
lcl <- "data-raw/airlines.csv"

if (!file.exists(lcl)) {
  download.file(src, lcl)
}

load("data/flights.rda")

raw <- read_csv(lcl)
airlines <- raw %>%
  select(carrier = Code, name = Description) %>%
  semi_join(flights) %>%
  arrange(carrier)

save(airlines, file = "data/airlines.rda")
