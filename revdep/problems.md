# dbplyr

Version: 1.2.1

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘tibble’
      All declared Imports should be used.
    ```

# implyr

Version: 0.2.4

## In both

*   checking whether package ‘implyr’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: package ‘dplyr’ was built under R version 3.4.4
    See ‘/Users/hadley/Documents/data/nycflights/revdep/checks.noindex/implyr/new/implyr.Rcheck/00install.out’ for details.
    ```

# MonetDBLite

Version: 0.5.1

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  5.4Mb
      sub-directories of 1Mb or more:
        libs   5.1Mb
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# rsolr

Version: 0.0.8

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/rsolr_unit_tests.R’ failed.
    Last 13 lines of output:
      
         test_SolrList.R 
           test_SolrList_accessors 
      
         test_SolrQuery.R 
           test_SolrQuery 
      
         test_SolrSchema.R 
           test_SolrSchema_creation 
      
      
      Error in get("testPackage", getNamespace("BiocGenerics"))("rsolr") : 
        unit tests failed for package rsolr
      Calls: <Anonymous> -> <Anonymous>
      Execution halted
    ```

*   checking re-building of vignette outputs ... NOTE
    ```
    ...
        setdiff, sort, table, tapply, union, unique, unsplit, which,
        which.max, which.min
    
    
    Attaching package: ‘rsolr’
    
    The following object is masked from ‘package:stats’:
    
        ftable
    
    The following object is masked from ‘package:base’:
    
        grouping
    
    Starting Solr...
    Use options(verbose=TRUE) to diagnose any problems.
    Server unhandled exception during startup 'java.net.BindException: Address already in use'
    Solr started at: http://localhost:8983/solr/flights
    Error: processing vignette 'intro.Rnw' failed with diagnostics:
    Empty reply from server
    Execution halted
    ```

