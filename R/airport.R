#' Airport metadata
#'
#' Useful metadata about airports.
#'
#' @source \url{http://openflights.org/data.html}, downloaded 2014-06-27
#' @format A data frame with columns:
#' \describe{
#'  \item{faa}{FAA airport code}
#'  \item{name}{Usual name of the aiport}
#'  \item{lat,lon}{Location of airport}
#'  \item{alt}{Altitude, in feet}
#'  \item{tz}{Timezone offset from GMT}
#'  \item{dst}{Daylight savings time zone. A = Standard US DST: starts on the
#'     second Sunday of March, ends on the first Sunday of November.
#'     U = unknown. N = no dst.}
#' }
#' @examples
#' if (require("dplyr")) {
#' airports
#'
#' airports %>% mutate(dest = faa) %>% semi_join(flights)
#' flights %>% anti_join(airports %>% mutate(dest = faa))
#' airports %>% mutate(origin = faa) %>% semi_join(flights)
#'
#' }
"airports"
