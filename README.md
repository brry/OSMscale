### intro

`OSMscale` is an R package to easily handle and project lat-long coordinates, 
download background maps and add a correct scale bar to 'OpenStreetMap' plots in any map projection.
There are some other spatially related miscellaneous functions as well.

### installation

`OSMscale` is available on CRAN: [![CRAN_Status_Badge](http://www.r-pkg.org/badges/version-last-release/OSMscale)](https://cran.r-project.org/package=OSMscale) [![downloads](http://cranlogs.r-pkg.org/badges/OSMscale)](http://www.r-pkg.org/services)
[![Rdoc](http://www.rdocumentation.org/badges/version/OSMscale)](http://www.rdocumentation.org/packages/OSMscale)
!["OSMscale dependencies"](https://tinyverse.netlify.com/badge/OSMscale)

It relies on [OpenStreetMap](http://blog.fellstat.com/?cat=15) to do the actual work,
thus `rgdal` and `rjava` must be available.

* **On Windows**: Check if Java is available. 
There should be no errors when running `  install.packages("rJava") ; library(rJava)  ` in R.
If necessary, install [Java](http://www.java.com/de/download/manual.jsp) in the same bit-version as R (eg 64bit).
The Java binary file must be on the [search path](http://www.java.com/en/download/help/path.xml), 
which will normally happen automatically.

* **On Linux**: open a terminal (CTRL+ALT+T) and paste (CTRL+SHIFT+V) the following 
line by line to install gdal and rJava:
```R
sudo apt update
sudo apt install libgdal-dev libproj-dev
sudo apt-get install r-cran-rjava
R
install.packages("rgdal")
library("rgdal"); library("rJava") # should not return errors
q("no") # to quit R
```

* Now actually install `OSMscale` from within R:

```R
install.packages("OSMscale") 
library(OSMscale)
?OSMscale

# To update to the most recent development version:
if(!requireNamespace("remotes", quitly=TRUE)) install.packages("remotes")
remotes::install_github("brry/OSMscale")
```
In case you run into the 32/64 bits error: "JAVA_HOME cannot be determined from the Registry", try  
`remotes::install_github("brry/OSMscale", build_opts="--no-multiarch")`

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
