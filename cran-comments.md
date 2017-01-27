This is a minor update to fix the NOTE I accidentally introduced in the last release.

---

## Test environments
* local OS X install, R 3.3.2
* ubuntu 12.04 (on travis-ci), R 3.3.2
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

* Checking installed package size:
  installed size is  6.9Mb
  sub-directories of 1Mb or more:
    data   6.9Mb

  This is a data package that will be rarely updated.

## Reverse dependencies

* I have run R CMD check on the 5 downstream dependencies.
  (Summary at https://github.com/hadley/nycflights13/tree/master/revdep). 
  
* All passed with no errors or warnings.
