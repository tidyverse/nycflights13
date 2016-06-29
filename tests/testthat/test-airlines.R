context("airlines")

## TODO: Rename context
## TODO: Add more tests
test_that("instantiation works", {
  ontime <- etl("airlines") 
  expect_is(ontime, c("etl_airlines", "src_sql"))
})

# test_that("multibyte error", {
#   airlines <- etl("airlines", dir = "~/dumps/airlines") 
#   airlines %>%
#     etl_create(years = 2001, months = 3)
# })
# 
# test_that("postgres works", {
#   db <- src_postgres(user = "postgres", host = "localhost", 
#                      dbname = "airlines", password = "postgres", port = 5434)
#   airlines <- etl("airlines", db = db, dir = "~/dumps/airlines")
#   airlines %>%
#     etl_create(years = 1999, months = 12, header = TRUE)
#   expect_equal(airlines %>%
#     tbl("flights") %>%
#     nrow(), 469945)
# })
