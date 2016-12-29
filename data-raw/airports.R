library(dplyr)
library(readr)
library(purrr)

if (!file.exists("data-raw/airports.dat")) {
  download.file(
    "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat",
    "data-raw/airports.dat"
  )
}

raw <- read_csv("data-raw/airports.dat",
  col_names = c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "tzone")
)

airports <- raw %>%
  filter(country == "United States", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst, tzone) %>%
  group_by(faa) %>% slice(1) %>% ungroup() # take first if duplicated


# Verify the results
library(ggplot2)
airports %>%
  filter(lon < 0) %>%
  ggplot(aes(lon, lat)) +
  geom_point(aes(colour = factor(tzone)), show.legend = FALSE) +
  coord_quickmap() +
  theme_void()
ggsave("data-raw/airports.svg", width = 8, height = 6)

write_csv(airports, "data-raw/airports.csv")
save(airports, file = "data/airports.rda")
