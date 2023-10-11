# Version 0.5.19 (2023-10-11)
- `sp` dependency moved to `sf`
- Readme improved, News reformatted
- `scaleBar`: bug from last update for large abslen values (relative to plot) fixed
- `earthDist`: almost.equal slow for vectorized calling, equality testing replaced with fast code
- `maxEarthDist`: generalized to take any function, can be applied to each point separately (= new default)

# Version 0.5.1 (2017-04-12)
- `earthDist`: bug (overeager testing) fixed for coordinates close to each other
- `earthDist`: now formally tested with testthat + sped up significantly
- `pointsMap`: margins left as set in the function
- option to turn off tracing removed (tracing is now fast anyways)
- installation instructions in readme greatly improved
- New function: `maxEarthDist`
- For all changes, see: https://github.com/brry/OSMscale/compare/master@{2017-01-18}...master@{2017-04-12}#files_bucket

# Version 0.4.1 (2017-01-19)
- `scaleBar` default choices improved
- `pointsMap` remowes margins before plotting and has proj argument instead of utm
- `earthDist` can now compute distance relative to any of the coordinate pairs
- numerical inaccuracies in `earthDist` captured
- Scroll down at the url below for a side by side comparison of all changes: https://github.com/brry/OSMscale/compare/master@{2016-09-21}...master@{2017-01-18}?diff=split&name=master%40{2017-01-18}

# Version 0.3.5 (2016-09-21)
- `do.call(scaleBar, ...)` computing time in pointsMap removed
- API unified to `function(lat, long, data, ...)`
- `scaleBar`: automatic abslen and ndiv selection greatly improved
- tracing of errors is simplified through `berryFunctions::traceCall()`
- `pointsMap` can now handle a single coordinate location
- `projectPoints` can now return the spTransform output
- documentation and a few defaults have been improved

# Version 0.2.9 (2016-08-21)
- first release on CRAN
- Detailed changes at https://github.com/brry/OSMscale/commits/master
- documentation (examples + github readme) expanded + improved
- `scaleBar` automatic length selection improved and abslen unit bug corected
- `projectPoints` can now handle datasets with NAs
- `pointsMap`: argument scale can now be a list of arguments
- new functions: `degree`, `earthDist`, `checkLL`
- new projection functions: `putm`, `posm`, `pll`
- moved here from berryFunctions: `equidistPoints`, `randomPoints`, `triangleArea`

# Version 0.2.1 (2016-07-27)
- second stable release
- suppress warning from `openmap`
- scalebar `type="bar"` added
- argument rearranged and names changed sometimes
- now prints progress messages

# Version 0.1.7 (2016-06-21)
- first stable release with 3 functions: `pointsMap`, `projectPoints`, `scaleBar`
- Can download openstreetmap background map for a data.frame with points,
- project those (and the map itself) to UTM (or any other projection),
- draws accurate scalebars even in the default OSM mercator projection (currently minimalistic in design)
