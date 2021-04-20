# nycflights13

<!-- badges: start -->
[![R-CMD-check](https://github.com/tidyverse/nycflights13/workflows/R-CMD-check/badge.svg)](https://github.com/tidyverse/nycflights13/actions)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/nycflights13)](https://cran.r-project.org/package=nycflights13)
<!-- badges: end -->

This package contains information about all flights that departed from NYC
(e.g. EWR, JFK and LGA) to destinations in the United States, Puerto Rico,
and the American Virgin Islands) in 2013: 
336,776 flights in total. To help understand what causes delays, 
it also includes a number of other useful datasets.

This package provides the following data tables.

* `flights`: all flights that departed from NYC in 2013
* `weather`: hourly meterological data for each airport
* `planes`: construction information about each plane
* `airports`: airport names and locations
* `airlines`: translation between two letter carrier codes and names

If you're interested in other subsets of flight data, see:

* [nycflights](https://github.com/jayleetx/nycflights) for flights departing 
  from NYC in the _last_ year.
  
* [anyflights](https://github.com/simonpcouch/anyflights) for flights departing
  from any airport in any year.
  
* [airlines](https://github.com/beanumber/airlines) to maintain a local SQL
  database of all flight departure data.
