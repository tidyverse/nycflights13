#' Airport metadata
#'
#' Useful metadata about airports.
#'
#' @source <http://openflights.org/data.html>, downloaded 2014-06-27
#' @format A data frame with columns:
#' \describe{
#'  \item{faa}{FAA airport code.}
#'  \item{name}{Usual name of the airport.}
#'  \item{lat, lon}{Location of airport.}
#'  \item{alt}{Altitude, in feet.}
#'  \item{tz}{Timezone offset from GMT.}
#'  \item{dst}{Daylight savings time zone. A = Standard US DST: starts on the
#'     second Sunday of March, ends on the first Sunday of November.
#'     U = unknown. N = no dst.}
#'  \item{tzone}{IANA time zone, as determined by GeoNames webservice.}
#' }
#' @examples
#' airports
#'
#' if (require("dplyr")) {
#'
#' airports %>% rename(dest = faa) %>% semi_join(flights)
#' flights %>% anti_join(airports %>% rename(dest = faa))
#' airports %>% rename(origin = faa) %>% semi_join(flights)
#'
#' }
"airports"
