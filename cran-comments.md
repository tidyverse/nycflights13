This is a new submission.

It passes R CMD check on windows, os x and linux (ubuntu):

* False positive in spell check: "metadata"

* Untarring fails on win-builder for R-devel (maybe upload was corrupted?)

* Checking installed package size:
  installed size is  5.5Mb
  sub-directories of 1Mb or more:
    data   5.5Mb

  This is a data package that will be rarely (if ever) updated.
