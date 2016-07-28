# OSMscale

Provides functionality to project points to UTM and add a scalebar to OpenStreetMap plots.
    
Code to install:

```R
# Avoid installing devtools with all its dependencies:
source("http://raw.githubusercontent.com/brry/berryFunctions/master/R/instGit.R")
instGit("brry/OSMscale")

# or using devtools:
if(!requireNamespace("devtools", quitly=TRUE)) install.packages("devtools")
devtools::install_github("brry/OSMscale")

library(OSMscale)
?OSMscale
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
scaleBar(map, abslen=500e3, y=0.8, cex=0.8)
lines(projectPoints(d$lat, d$long), col="blue", lwd=3)

dev.off()
```
![ExampleMap](https://github.com/brry/OSMscale/blob/master/ExampleMap.png "Example Map")


I plan irregularly spaced github releases that follow the version number:
```R
devtools::install_github("brry/OSMscale@v0.2.1") # 2016-07
```

If direct installation doesn't work, your R version might be too old. In that case, an update is really recommendable: [r-project.org](http://www.r-project.org/). If you can't update R, try installing from source (github) via `instGit` or devtools as mentioned above. If that's not possible either, here's a manual workaround:
click on **Download ZIP** (to the right, [link](https://github.com/brry/OSMscale/archive/master.zip)), unzip the file to some place, then
```R
setwd("that/path")
dd <- dir("OSMscale-master/R", full=T)
dummy <- sapply(dd, source)
```
This creates all R functions as objects in your globalenv workspace (and overwrites existing objects of the same name!).
