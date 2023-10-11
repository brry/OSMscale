### intro

`OSMscale` is an R package to easily handle and project lat-long coordinates, 
download background maps and add a correct scale bar to 'OpenStreetMap' plots in any map projection.
There are some other spatially related miscellaneous functions as well.

`OSMscale` is available on CRAN: [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version-last-release/OSMscale)](https://cran.r-project.org/package=OSMscale) [![downloads](http://cranlogs.r-pkg.org/badges/OSMscale)](http://www.r-pkg.org/services)
[![Rdoc](http://www.rdocumentation.org/badges/version/OSMscale)](http://www.rdocumentation.org/packages/OSMscale)

It relies on [OpenStreetMap](https://blog.fellstat.com/?cat=5) to do the actual work,
thus `rjava` must be available, see [installation tips](https://bookdown.org/brry/course/packages.html#rjava-on-windows).

### usage

```R
# installation:
install.packages("OSMscale") 
library(OSMscale)

# table with lat-long coordinates:
d <- read.table(sep=",", header=TRUE, text=
"lat, long
55.685143, 12.580008
52.514464, 13.350137
50.106452, 14.419989
48.847003, 2.337213
51.505364, -0.164752")
pointsMap(lat, long, data=d)

# projections:
png("ExampleMap.png", width=4, height=3, units="in", res=150)
map <- pointsMap(lat, long, data=d, type="nps", proj=putm(d$long), scale=FALSE)
scaleBar(map, abslen=500, y=0.8, cex=0.8)
lines(projectPoints(d$lat, d$long), col="blue", lwd=3)
points(projectPoints(52.386609, 4.877008, to=putm(zone=32)), cex=3, lwd=2, col="purple")
dev.off()
```
![ExampleMap](https://github.com/brry/OSMscale/blob/master/ExampleMap.png "Example Map")

