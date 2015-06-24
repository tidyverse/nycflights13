library(dplyr)

src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
lcl <- "data-raw/airlines.csv"

if (!file.exists(lcl)) {
  download.file(src, lcl)
}

# load("data/flights.rda")

raw <- read.csv(lcl)
carriers <- raw %>%
  tbl_df() %>%
  select(carrier = Code, name = Description) %>%
#  semi_join(flights) %>%
  filter(!is.na(carrier)) %>%
  arrange(carrier)

save(carriers, file = "data/carriers.rda", compress = "xz")
