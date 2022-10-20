library(dplyr)
library(readr)

# Update URL from
# http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download/
src <- "https://registry.faa.gov/database/ReleasableAircraft.zip"
lcl <- "data-raw/planes"

if (!file.exists(lcl)) {
  tmp <- tempfile(fileext = ".zip")
  download.file(src, tmp)

  dir.create(lcl)
  unzip(tmp, exdir = lcl, junkpaths = TRUE)
}

master <- read.csv("data-raw/planes/MASTER.txt", stringsAsFactors = FALSE, strip.white = TRUE)
names(master) <- tolower(names(master))

keep <- master %>%
  as_tibble() %>%
  select(nnum = n.number, code = mfr.mdl.code, year = year.mfr)

ref <- read.csv("data-raw/planes//ACFTREF.txt",
  stringsAsFactors = FALSE,
  strip.white = TRUE
)
names(ref) <- tolower(names(ref))

ref <- ref %>%
  tbl_df() %>%
  select(code, mfr, model, type.acft, type.eng, no.eng, no.seats, speed)

# Combine together

all <- keep %>%
  inner_join(ref) %>%
  select(-code)
all$speed[all$speed == 0] <- NA
all$no.eng[all$no.eng == 0] <- NA
all$no.seats[all$no.seats == 0] <- NA

engine <- c(
  "None", "Reciprocating", "Turbo-prop", "Turbo-shaft", "Turbo-jet",
  "Turbo-fan", "Ramjet", "2 Cycle", "4 Cycle", "Unknown", "Electric", "Rotary"
)
all$engine <- engine[all$type.eng + 1]
all$type.eng <- NULL

acft <- c(
  "Glider", "Balloon", "Blimp/Dirigible", "Fixed wing single engine",
  "Fixed wing multi engine", "Rotorcraft", "Weight-shift-control",
  "Powered Parachute", "Gyroplane"
)
all$type <- acft[all$type.acft]
all$type.acft <- NULL

all$tailnum <- paste0("N", all$nnum)

load("data/flights.rda")

planes <- all %>%
  select(
    tailnum, year, type,
    manufacturer = mfr, model = model,
    engines = no.eng, seats = no.seats, speed, engine
  ) %>%
  semi_join(flights, "tailnum") %>%
  arrange(tailnum)

write_csv(planes, "data-raw/planes.csv")
save(planes, file = "data/planes.rda")
