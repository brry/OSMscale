## Test environments
* x86_64-w64-mingw32/x64 (64-bit) with 3.3.0 (2016-05-03)
* win-builder (devel and release)

## R CMD check results

Status: 2 ERRORs, 1 WARNING, 1 NOTE

* Error and warning stems from berryFunctions not being up to date on CRAN.
(CRAN Release 1.10.0 does not yet include is.error and checkFile)
Now updating berryFunctions first.

NOTE:

Found the following (possibly) invalid URLs:
  URL: http://www.movable-type.co.uk/scripts/latlong.html
    From: man/earthDist.Rd
    Status: Error
    Message: libcurl error code 7
    	Failed to connect to www.movable-type.co.uk port 80: Timed out
    	
* Worked fine in browser. Will see if it persists

## Downstream dependencies
There are currently no downstream dependencies for this packag
