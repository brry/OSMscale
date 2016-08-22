# OSMscale

Provides functionality to project points to UTM and add a scalebar to OpenStreetMap plots.
The scalebar is correct even in the default mercator projection.
There also is a function for easy map download and plotting - just give it a data.frame with coordinates.

This package relies on [OpenStreetMap](http://blog.fellstat.com/?cat=15) to do the actual work.
Thus you must have [java](www.java.com) installed in the in same bit-version as R (eg 64bit), see
http://www.java.com/de/download/manual.jsp.
The Java binary file must be on the [search path](http://www.java.com/en/download/help/path.xml), which will normally happen automatically.

Code to install from CRAN:
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/OSMscale)](http://cran.r-project.org/package=OSMscale) [![downloads](http://cranlogs.r-pkg.org/badges/OSMscale)](http://www.r-pkg.org/services)
```R
install.packages("OSMscale")
library(OSMscale)
?OSMscale

# To update to the most recent development version:
berryFunctions::instGit("brry/OSMscale")
```


Basic usage:
```R
d <- read.table(sep=",", header=TRUE, text=
"lat, long # could e.g. be copied from googleMaps, rightclick on What's here?
55.685143, 12.580008
52.514464, 13.350137
50.106452, 14.419989
48.847003, 2.337213
51.505364, -0.164752")
png("ExampleMap.png", width=4, height=3, units="in", res=150)
par(mar=c(0,0,0,0) )

map <- pointsMap(d, type="maptoolkit-topo", utm=TRUE, scale=FALSE, pch=16, col=2)
scaleBar(map, abslen=500, y=0.8, cex=0.8)
lines(projectPoints(d$lat, d$long), col="blue", lwd=3)

dev.off()
```
![ExampleMap](https://github.com/brry/OSMscale/blob/master/ExampleMap.png "Example Map")


If direct installation doesn't work, your R version might be too old. In that case, an update is really recommendable: [r-project.org](http://www.r-project.org/). If you can't update R, try installing from source (github) via `instGit` as mentioned above. If that's not possible either, here's a manual workaround:
click on **Clone/Download - Download ZIP** (at the top or [here](https://github.com/brry/OSMscale/archive/master.zip)), unzip the file to some place, then
```R
setwd("that/path")
dd <- dir("OSMscale-master/R", full=T)
dummy <- sapply(dd, source)
```
This creates all R functions as objects in your globalenv workspace (and overwrites existing objects of the same name!).
