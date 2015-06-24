#' @title trim
#' 
#' @description Enforce minimal referential integrity on the flights DB. 
#' 
#' @param db a \code{dplyr} \code{src}
#' @param flights a \code{tbl} containing flight information
#' 
#' @details This function will enforce minimal referential integrity on a table 
#' of flights. That is, given a data set of flights, it will trim the \code{\link{airports}}, 
#' \code{\link{planes}}, and \code{\link{carriers}} tables to include only those
#' entries that are present in \code{flights}. 
#' 
#' @return a list of \code{tbl}s
#' 
#' @import dplyr
#' @export
#' 
#' @examples
#' 
#' library(dplyr)
#' 
#' if (require(RPostgreSQL)) {
#'  # must have pre-existing database "airlines"
#'  db <- src_postgres(host = "localhost", user="postgres", password="postgres", dbname = "airlines")
#' }
#' 
#' # save files in a specific location
#' \dontrun{
#' pushYear(db, year = 2013, temp.dir = "~/dumps")
#' }
#' 
#' # restrict to just flights from NYC in 2013
#' \dontrun{
#' flights <- tbl(db, "flights")
#' nycFlights13 <- flights %>%
#'   filter(year == 2013) %>%
#'   filter(origin %in% c("JFK", "LGA", "EWR"))
#' tbl_list <- trim(db, flights = nycFlights13)
#' airports <- collect(tbl_list$airports)
#' save(airports, file = "data/airports.rda")
#' }

trim <- function (db, flights) {
  airports <- tbl(db, "airports")
  planes <- tbl(db, "planes")
  carriers <- tbl(db, "carriers")
  
  airports_dest_trimmed <- airports %>%
    semi_join(flights, by = c("faa" = "dest")) 
  airports_orig_trimmed <- airports %>%
    semi_join(flights, by = c("faa" = "origin")) 
  airports_trimmed = union(airports_dest_trimmed, airports_orig_trimmed)
  
  planes_trimmed <- planes %>%
    semi_join(flights, by = c("tailnum" = "tailnum"))
  
  carriers_trimmed <- carriers %>%
    semi_join(flights, by = c("carrier" = "carrier"))
  
  return(list(airports = airports_trimmed, planes = planes_trimmed, carriers = carriers_trimmed))
}