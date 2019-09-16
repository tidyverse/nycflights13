#' Plane metadata.
#'
#' Plane metadata for all plane tailnumbers found in the FAA aircraft
#' registry. American Airways (AA) and Envoy Air (MQ) report fleet numbers
#' rather than tail numbers so can't be matched.
#'
#' @source FAA Aircraft registry,
#'  <http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download/>
#' @format A data frame with columns:
#' \describe{
#' \item{tailnum}{Tail number.}
#' \item{year}{Year manufactured.}
#' \item{type}{Type of plane.}
#' \item{manufacturer, model}{Manufacturer and model.}
#' \item{engines, seats}{Number of engines and seats.}
#' \item{speed}{Average cruising speed in mph.}
#' \item{engine}{Type of engine.}
#' }
#' @examples
#' planes
#'
#' if (require("dplyr")) {
#'
#' # Flights that don't have plane metadata
#' flights %>% anti_join(planes, "tailnum")
#'
#' }
"planes"
