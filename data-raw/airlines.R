library(dplyr)

src <- "http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS"
lcl <- "data-raw/airlines.csv"

if (!file.exists(lcl)) {
  download.file(src, lcl)
}

raw <- read.csv(lcl)
airlines <- raw %>%
  tbl_df() %>%
  select(carier = Code, name = Description)
