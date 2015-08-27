#' etl_init
#' 
#' @description Initialize the database.
#' 
#' @inheritParams etl::etl_init
#' 
#' @details This will initialize the database.
#' 
#' @method etl_init etl_airlines
#' 
#' @import etl
#' @export
#' @seealso \code{\link[etl]{etl_init}}
#' 
#' @examples
#' 
#' library(dplyr)
#' library(etl)
#' 
#' \dontrun{
#' if (require(RPostgreSQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_postgres(host = "localhost", user = "postgres", dbname = "airlines")
#' }
#' etl_airlines <- etl_connect("airlines", db)
#' etl_init(etl_airlines)
#' 
#' if (require(RMySQL)) {
#' # must have pre-existing database "airlines"
#' db <- src_mysql(user = "mysql", password = "mysql", dbname = "airlines")
#' }
#' etl_airlines <- etl_connect("airlines", db)
#' etl_init(etl_airlines)
#' }

etl_init.etl_airlines <- function(obj, ...) {
  # sql <- system.file(package = "airlines")
  obj$init <- dbRunScript(obj$con, "~/Dropbox/lib/airlines/inst/sql/init.mysql")
}