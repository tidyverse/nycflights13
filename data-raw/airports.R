library(dplyr)
library(readr)
library(purrr)
library(geonames) # to determine timezones

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


# Find time zones
get_tz <- function(lat, lon) {
  cat(".")
  GNtimezone(lat, lon)
}
tz <- map2(airports$lat, airports$lon, safely(get_tz))
tz <- transpose(tz)

ok <- tz$error %>% map_lgl(is.null)
airports[!ok, ]

airports$tzone <- tz$result %>%
  map("timezoneId", .null = NA) %>%
  map_chr(as.character)

# Verify the results
library(ggplot2)
airports %>%
  filter(lon < 0) %>%
  ggplot(aes(lon, lat)) +
  geom_point(aes(colour = factor(tzone)), show.legend = FALSE) +
  coord_quickmap()

write_csv(airports, "data-raw/airports.csv")
save(airports, file = "data/airports.rda")
