airlines
================

[![Travis-CI Build Status](https://travis-ci.org/beanumber/airlines.svg?branch=master)](https://travis-ci.org/beanumber/airlines)

The `airlines` package provides a user-friendly interface to create and maintain an SQL database of flight information from the [U.S. Bureau of Transportation Statistics Airline On-Time Performance](http://www.transtats.bts.gov/DatabaseInfo.asp?DB_ID=120&Link=0) data. The user of the `airlines` package only needs a valid place to store the data -- no sophisticated SQL administration skills are necessary.

Several existing R package could be considered subsets of these data:

1.  [nycflights13](http://github.com/hadley/nycflights13): all outgoing flights from the three New York City airports (LGA, JFK, and EWR) during 2013
2.  [hflights](http://github.com/hadley/hflights): all outgoing flights from the three New York City airports (IAH and HOU) during 2011

This `airlines` package will allow you to download data for over 165 million flights from 1987 to present, from all domestic airports.

Install
-------

The [`etl`](http://github.com/beanumber/etl) package (on CRAN) provides the generic framework for the `airlines` package. Since the `airlines` package currently lives on GitHub and not on CRAN, you have to install it using `devtools`:

``` r
install.packages("devtools")
devtools::install_github("beanumber/airlines")
```

To begin, load the `airlines` package. Note that this loads `etl`, which in turn loads `dplyr`.

``` r
library(airlines)
```

Populate
--------

Any `etl`-derived package can make use of the SQL backends supported by `dplyr`. Here, we illustrate how to set up a local MySQL database to store the flight data. This approach uses a MySQL options file located at `~/.my.cnf`.

``` r
system("mysql -e 'CREATE DATABASE IF NOT EXISTS airlines;'")
db <- src_mysql_cnf(dbname = "airlines")
```

Once we have a database connection, we create an `etl` object, initialize the database, and then populate it with data. Please note that to update the database with all 30 years worth of flights may take a few hours.

``` r
ontime <- etl("airlines", db = db, dir = "~/dumps/airlines")
```

``` r
ontime %>%
  etl_init() %>%
  etl_update(years = 1987:2016)
```

Verify
------

There are over 300 months worth of files to download, and they will occupy more than 21 GB in their zipped and unzipped states.

``` r
summary(ontime)
```

    ## files:
    ##     n      size                              path
    ## 1 349  6.504 GB  /home/bbaumer/dumps/airlines/raw
    ## 2 345 18.725 GB /home/bbaumer/dumps/airlines/load

    ##       Length Class           Mode       
    ## con   1      MySQLConnection S4         
    ## info  8      -none-          list       
    ## disco 3      -none-          environment

The full flights table should contain about 169 million flights from October 1987 to June 2016.

``` r
ontime %>%
  tbl(from = "flights") %>%
  summarise(numFlights = n())
```

    ## Source:   query [?? x 1]
    ## Database: mysql 5.7.13-0ubuntu0.16.04.2 [bbaumer@localhost:/airlines]
    ## 
    ##   numFlights
    ##        <dbl>
    ## 1  169405490

Analyze
-------

The number of flights per year seems to have peaked in 2007.

``` r
ontime %>%
  tbl(from = "flights") %>%
  group_by(year) %>%
  summarise(numMonths = n_distinct(month), numFlights = n()) %>%
  print(n = 40)
```

    ## Source:   query [?? x 3]
    ## Database: mysql 5.7.13-0ubuntu0.16.04.2 [bbaumer@localhost:/airlines]
    ## 
    ##     year numMonths numFlights
    ##    <int>     <dbl>      <dbl>
    ## 1   1987         3    1311826
    ## 2   1988        12    5202096
    ## 3   1989        12    5041200
    ## 4   1990        12    5270893
    ## 5   1991        12    5076925
    ## 6   1992        12    5092157
    ## 7   1993        12    5070501
    ## 8   1994        12    5180048
    ## 9   1995        12    5327435
    ## 10  1996        12    5351983
    ## 11  1997        12    5411843
    ## 12  1998        12    5384721
    ## 13  1999        12    5527884
    ## 14  2000        12    5683047
    ## 15  2001        12    5967780
    ## 16  2002        12    5271359
    ## 17  2003        12    6488540
    ## 18  2004        12    7129270
    ## 19  2005        12    7140596
    ## 20  2006        12    7141922
    ## 21  2007        12    7455458
    ## 22  2008        12    7009726
    ## 23  2009        12    6450285
    ## 24  2010        12    6450117
    ## 25  2011        12    6085281
    ## 26  2012        12    6096762
    ## 27  2013        12    6369482
    ## 28  2014        12    5819811
    ## 29  2015        12    5819079
    ## 30  2016         6    2777463

Please see [the vignette](https://github.com/beanumber/airlines/blob/master/vignettes/intro.Rmd) for more detail about how to use this package.
