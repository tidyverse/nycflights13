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

test_that("mysql works", {
  if (require(RMySQL) & mysqlHasDefault()) {
    db <- src_mysql(default.file = "~/.my.cnf", 
                       groups = "rs-dbi", dbname = "test", 
                       user = NULL, password = NULL)
    test_dir <- "~/dumps/airlines"
    if (dir.exists(test_dir)) {
      expect_s3_class(ontime_mysql <- etl("airlines", db = db, dir = test_dir), "src_mysql")
      ontime_mysql %>%
        etl_init()
      expect_message(ontime_mysql %>% etl_update(years = 1987, months = 10), "success")
      expect_output(print(ontime_mysql), "flights")
      expect_equal(ontime_mysql %>% tbl("flights") %>% collect(n = Inf) %>% nrow(), 448620)
    }
  }
})

test_that("MonetDBLite works", {
  if (require(MonetDBLite)) {
    db <- MonetDBLite::src_monetdblite()
    test_dir <- "~/dumps/airlines"
    if (dir.exists(test_dir)) {
      expect_s3_class(ontime_monet <- etl("airlines", db = db, dir = test_dir), "src_monetdb")
      expect_message(ontime_monet %>% etl_update(years = 1987, months = 10), "success")
      expect_output(print(ontime_monet), "flights")
      expect_equal(ontime_monet %>% tbl("flights") %>% collect(n = Inf) %>% nrow(), 448620)
    }
  }
})

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
