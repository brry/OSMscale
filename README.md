### intro

Functionality to handle and project lat-long coordinates, easily download background maps
and add a correct scale bar to 'OpenStreetMap' plots in any map projection.
There are some other spatially related miscellaneous functions as well.

### installation

`OSMscale` is available on CRAN: [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version-last-release/OSMscale)](https://cran.r-project.org/package=OSMscale) [![downloads](http://cranlogs.r-pkg.org/badges/OSMscale)](http://www.r-pkg.org/services)
[![Rdoc](http://www.rdocumentation.org/badges/version/OSMscale)](http://www.rdocumentation.org/packages/OSMscale)

It relies on [OpenStreetMap](http://blog.fellstat.com/?cat=15) to do the actual work.
Thus `rgdal` and `rjava` must be available.

* Install [Java](http://www.java.com/de/download/manual.jsp) in the in same bit-version as R (eg 64bit).
The Java binary file must be on the [search path](http://www.java.com/en/download/help/path.xml), 
which will normally happen automatically.

* Install the `rJava` package.
On Linux, open a terminal (CTRL+ALT+T) and paste (CTRL+SHIFT+V) `sudo apt-get install r-cran-rjava`. 
On windows, in R itself, use `install.packages("rJava")`.

* Install the `rgdal` package.
In the Linux terminal, first run:
`sudo apt update && sudo apt install libgdal-dev libproj-dev`
and then in R itself: `install.packages("rgdal")`.
On Windows, the latter should suffice, as gdal will be installed automatically.

* Make sure that the java and gdal executables can be found. 
The following commands should not return errors:
`library("rJava") ;  library("rgdal")`

* Now actually install `OSMscale`:

```R
install.packages("OSMscale") 
library(OSMscale)
?OSMscale

# To update to the most recent development version:
berryFunctions::instGit("brry/berryFunctions")
berryFunctions::instGit("brry/OSMscale")
```

### basic usage
Assuming a data.frame with lat-long coordinates:
```R
d <- read.table(sep=",", header=TRUE, text=
"lat, long # could e.g. be copied from googleMaps, rightclick on What's here?
55.685143, 12.580008
52.514464, 13.350137
50.106452, 14.419989
48.847003, 2.337213
51.505364, -0.164752")
png("ExampleMap.png", width=4, height=3, units="in", res=150)

map <- pointsMap(lat, long, data=d, type="maptoolkit-topo", proj=putm(d$long), scale=FALSE)
scaleBar(map, abslen=500, y=0.8, cex=0.8)
lines(projectPoints(d$lat, d$long), col="blue", lwd=3)
points(projectPoints(52.386609, 4.877008, to=putm(zone=32)), cex=3, lwd=2, col="purple")

dev.off()
```
![ExampleMap](https://github.com/brry/OSMscale/blob/master/ExampleMap.png "Example Map")

### trouble

If direct installation doesn't work, your R version might be too old. 
In that case, an update is really recommendable: [r-project.org](https://www.r-project.org/). 
If you can't update R, try installing from source (github) via `instGit` as mentioned above. 
If that's not possible either, you might be able to `source` some functions from the 
[package zip folder](https://github.com/brry/OSMscale/archive/master.zip)
```R
Vectorize(source)(dir("path/you/unzipped/to/OSMscale-master/R", full=T))
```
This creates all R functions as objects in your globalenv workspace (and overwrites existing objects of the same name!).
