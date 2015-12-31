library(dplyr)
library(readr)

if (!file.exists("data-raw/airports.dat")) {
  download.file(
    "http://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/airports.dat?format=raw",
    "data-raw/airports.dat"
  )
}

raw <- read_csv("data-raw/airports.dat",
  col_names = c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst")
)

airports <- raw %>%
  filter(country == "United States", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst) %>%
  group_by(faa) %>% slice(1) %>% ungroup() # take first if duplicated

write.csv(airports, "data-raw/airports.csv", row.names = FALSE)
save(airports, file = "data/airports.rda")
