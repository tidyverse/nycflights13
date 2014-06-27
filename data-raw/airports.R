library(dplyr)

if (!file.exists("data-raw/airports.dat")) {
  download.file(
    "http://sourceforge.net/p/openflights/code/HEAD/tree/openflights/data/airports.dat?format=raw",
    "data-raw/airports.dat"
  )
}

raw <- read.csv("data-raw/airports.dat", 
  header = FALSE, 
  stringsAsFactors = FALSE)
names(raw) <- c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst")

airports <- raw %>% 
  tbl_df() %>%
  filter(country == "United States", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst) %>%
  mutate(lat = as.numeric(lat), lon = as.numeric(lon)) %>%
  arrange(faa)

write.csv(airports, "data-raw/airports.csv", row.names = FALSE)
save(airports, file = "data/airports.rda")
