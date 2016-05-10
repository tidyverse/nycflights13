#' Carrier names.
#'
#' Look up airline names from their carrier codes.
#'
#' @docType data
#' @source http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236
#' @format Data frame with columns
#' \describe{
#' \item{carrier}{Two letter abbreviation}
#' \item{name}{Full name}
#' }
#' @examples
#'   carriers
"carriers"

#' Airport metadata
#'
#' Useful metadata about airports.
#'
#' @docType data
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
#' 
#' 
#' airports
#'
#' \dontrun{
#' db <- src_postgres(host = "localhost", user="postgres", password="postgres", dbname = "airlines")
#' flights <- tbl(db, "flights")
#' airports %>% mutate(dest = faa) %>% semi_join(flights)
#' flights %>% anti_join(airports %>% mutate(dest = faa))
#' airports %>% mutate(origin = faa) %>% semi_join(flights)
#' }
"airports"

#' Plane metadata.
#'
#' Plane metadata for all plane tailnumbers found in the FAA aircraft
#' registry. American Airways (AA) and Envoy Air (MQ) report fleet numbers
#' rather than tail numbers (e.g. \url{http://www.flyerguide.com/Tail_Numbers_(AA)})
#' so can't be matched.
#' @docType data
#' @source FAA Aircraft registry,
#'  \url{http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download/}
#' @format A data frame with columns:
#' \describe{
#' \item{tailnum}{Tail number}
#' \item{year}{Year manufactured}
#' \item{type}{Type of plane}
#' \item{manufacturer,model}{Manufacturer and model}
#' \item{engines,seats}{Number of engines and seats}
#' \item{speed}{Average cruising speed in mph}
#' \item{engine}{Type of engine}
#' }
#' @examples
#' if (require("dplyr")) {
#' planes
#' 
#' \dontrun{
#' db <- src_postgres(host = "localhost", user="postgres", password="postgres", dbname = "airlines")
#' flights <- tbl(db, "flights")
#' # Flights that don't have plane metadata
#' flights %>% anti_join(planes, "tailnum")
#' }
#' }
"planes"

#' Hourly weather data
#'
#' Hourly meterological data for LGA, JFK and EWR.
#'
#' @source ASOS download from Iowa Environmental Mesonet,
#'   https://mesonet.agron.iastate.edu/request/download.phtml.
#' @format A data frame with columns
#' \describe{
#' \item{origin}{Weather station. Named origin to faciliate merging with
#'   \code{\link{flights}} data}
#' \item{year,month,day,hour}{Time of recording}
#' \item{temp,dewp}{Temperature and dewpoint in F}
#' \item{humid}{Relative humidity}
#' \item{wind_dir,wind_speed,wind_gust}{Wind direction (in degrees), speed
#'   and gust speed (in mph)}
#' \item{precip}{Preciptation, in inches}
#' \item{pressure}{Sea level pressure in millibars}
#' \item{visib}{Visibility in miles}
#' \item{time_hour}{Date and hour of the recording as a \code{POSIXct} date}
#' }
"weather"

#' Flights data
#'
#' On-time data for all flights that departed NYC (i.e. JFK, LGA or EWR) in
#' 2013.
#'
#' @source RITA, Bureau of transportation statistics,
#'  \url{http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236}
#' @format Data frame with columns
#' \describe{
#' \item{year,month,day}{Date of departure}
#' \item{dep_time,arr_time}{Actual departure and arrival times, local tz.}
#' \item{sched_dep_time,sched_arr_time}{Scheduled departure and arrival times, local tz.}
#' \item{dep_delay,arr_delay}{Departure and arrival delays, in minutes.
#'   Negative times represent early departures/arrivals.}
#' \item{hour,minute}{Time of scheduled departure broken into hour and minutes.}
#' \item{carrier}{Two letter carrier abbreviation. See \code{\link{carriers}}
#'   to get name}
#' \item{tailnum}{Plane tail number}
#' \item{flight}{Flight number}
#' \item{origin,dest}{Origin and destination. See \code{\link{airports}} for
#'   additional metadata.}
#' \item{air_time}{Amount of time spent in the air}
#' \item{distance}{Distance flown}
#' \item{time_hour}{Scheduled date and hour of the flight as a \code{POSIXct} date.
#'   Along with \code{origin}, can be used to join flights data to weather data.}
#' }
"flights"
