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
#' \item{dep_time,arr_time}{Actual departure and arrival times (format HHMM or HMM), local tz.}
#' \item{sched_dep_time,sched_arr_time}{Scheduled departure and arrival times (format HHMM or HMM), local tz.}
#' \item{dep_delay,arr_delay}{Departure and arrival delays, in minutes.
#'   Negative times represent early departures/arrivals.}
#' \item{hour,minute}{Time of scheduled departure broken into hour and minutes.}
#' \item{carrier}{Two letter carrier abbreviation. See \code{\link{airlines}}
#'   to get name}
#' \item{tailnum}{Plane tail number}
#' \item{flight}{Flight number}
#' \item{origin,dest}{Origin and destination. See \code{\link{airports}} for
#'   additional metadata.}
#' \item{air_time}{Amount of time spent in the air, in minutes}
#' \item{distance}{Distance between airports, in miles}
#' \item{time_hour}{Scheduled date and hour of the flight as a \code{POSIXct} date.
#'   Along with \code{origin}, can be used to join flights data to weather data.}
#' }
"flights"


#' @importFrom tibble tibble
NULL
