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

If direct installation from CRAN doesn't work, your R version might be too old. In that case, an update is really recommendable: [r-project.org](http://www.r-project.org/). If you can't update R, try installing from source (github) via `instGit` or devtools as mentioned above. If that's not possible either, here's a manual workaround:
click on **Download ZIP** (to the right, [link](https://github.com/brry/OSMscale/archive/master.zip)), unzip the file to some place, then
```R
setwd("that/path")
dd <- dir("OSMscale-master/R", full=T)
dummy <- sapply(dd, source)
```
This creates all R functions as objects in your globalenv workspace (and overwrites existing objects of the same name!).
