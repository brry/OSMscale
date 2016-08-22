#' Add a Scalebar to OpenStreetMap Plots
#'
#' Functionality to handle and project lat-long coordinates,
#' easily download background maps
#' and add a correct scale bar to 'OpenStreetMap' plots in any map projection.
#' There are some other spatially related miscellaneous functions as well.
#'
#' @name OSMscale-package
#' @aliases OSMscale-package OSMscale
#' @docType package
#' @note Get the most recent code updates at \url{https://github.com/brry/OSMscale}
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, June 2016
#' @seealso \code{\link{scaleBar}}, \code{\link{pointsMap}}, \code{\link{projectPoints}}
#' @keywords package documentation
#' @examples
#'
#' d <- read.table(sep=",", header=TRUE, text=
#' "lat, long
#' 55.685143, 12.580008
#' 52.514464, 13.350137
#' 50.106452, 14.419989
#' 48.847003, 2.337213
#' 51.505364, -0.164752")
#'
#' # zoom set to 3 to speed up tests. automatic zoom determination is better.
#' map <- pointsMap(d, type="maptoolkit-topo", utm=TRUE, scale=FALSE, zoom=3, pch=16, col=2)
#' scaleBar(map, abslen=500, y=0.8, cex=0.8)
#' lines(projectPoints(d$lat, d$long), col="blue", lwd=2)
#'
NULL

#' GPS recorded bike track
#'
#' My daily bike route, recorded with the app OSMtracker on my Samsung Galaxy S5
#'
#'
#' @name biketrack
#' @docType data
#' @format 'data.frame':	254 obs. of  4 variables:\cr
#' $ lon : num  13 13 13 13 13 ...\cr
#' $ lat : num  52.4 52.4 52.4 52.4 52.4 ...\cr
#' $ time: POSIXct, format: "2016-05-18 07:53:22" "2016-05-18 07:53:23" ...\cr
#' $ ele : num  66 66 66 67 67 67 68 69 69 69 ....
#' @source GPS track export from OSMtracker App
#' @keywords datasets
#' @examples
#'
#' data(biketrack)
#' plot(biketrack[,1:2])
#' # see equidistPoints
#'
NULL
