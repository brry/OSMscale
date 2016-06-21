#' Get map for lat-long points
#'
#' Download and plot map with the extend of a dataset with lat-long coordinates
#'
#' @details detailsMayBeRemoved
#'
#' @return Map returned by \code{\link{openmap}}
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{projectPoints}}, \code{\link[OpenStreetMap]{openmap}}
#' @keywords hplot spatial
#' @importFrom grDevices extendrange
#' @importFrom berryFunctions owa
#' @importFrom OpenStreetMap openmap openproj osm
#' @importFrom sp CRS
#' @importFrom graphics points
#' @export
#' @examples
#' d <- read.table(sep=",", header=TRUE, text=
#' "lat, long # could e.g. be copied from googleMaps, rightclick on What's here?
#' 43.221028, -123.382998
#' 43.215348, -123.353804
#' 43.227785, -123.368694
#' 43.232649, -123.355895")
#' map <- pointsMap(d)
#' map_utm <- pointsMap(d, map=map, utm=TRUE)
#' axis(1); axis(2) # now in meters
#' projectPoints(d$lat, d$long)
#' scaleBar(map_utm, x=0.2, y=0.8, unit="mi", col="red")
#' pointsMap(d[1:2,], map=map_utm, add=TRUE, parg=list(col="red"))
#'
#' d <- data.frame(long=c(12.95, 12.98, 13.22, 13.11), lat=c(52.40,52.52, 52.36, 52.45))
#' map <- pointsMap(d, type="bing") # aerial map
#'
#' @param data Data.frame with coordinates
#' @param x,y Names of columns in \code{data} containing longitude (East-West)
#'            and latitude (North-South) coordinates. DEFAULT: "long","lat"
#' @param fx,fy Extend factors (additional map space around actual points)
#'              passed to \code{\link{extendrange}}. DEFAULT: 0.05
#' @param type Tile server in \code{\link[OpenStreetMap]{openmap}}
#' @param map Optional map object. If given, it is not downloaded again. DEFAULT: NULL
#' @param utm Logical: Convert map to UTM (or other \code{proj})?
#'            Consumes some extra time. DEFAULT: FALSE
#' @param zone UTM zone, see e.g. \url{https://upload.wikimedia.org/wikipedia/commons/e/ed/Utm-zones.jpg}.
#'             Only used if utm=TRUE. DEFAULT: at mean of long
#' @param proj proj4 character string or CRS object to project to.
#'             DEFAULT: UTM projection at \code{zone}
#' @param plot Logical: Should map be plotted and points added? DEFAULT: TRUE
#' @param add Logical: add points to existing map? DEFAULT: FALSE
#' @param pargs List of arguments passed to \code{\link{points}}.
#'              E.g. pargs=list(pch=NA) to suppress points. DEFAULT: NULL
#' @param scale Logical: add \code{\link{scaleBar}}? DEFAULT: TRUE
#' @param \dots Further arguments passed to \code{\link[OpenStreetMap]{openmap}}
#'
pointsMap <- function(
data,
x="long",
y="lat",
fx=0.05,
fy=fx,
type="osm",
map=NULL,
utm=FALSE,
zone=mean(long)%/%6+31,
proj=paste0("+proj=utm +zone=",zone,"+ellps=WGS84 +datum=WGS84"),
plot=TRUE,
add=FALSE,
pargs=NULL,
scale=TRUE,
...
)
{
# Input processing:
long <- data[,x]
lat  <- data[,y]
# Data checks:
if(is.null(long) | all(is.na(long)) ) stop("long could not be extracted from data")
if(is.null(lat)  | all(is.na(lat))  ) stop("lat could not be extracted from data")
if(any(long < -180)) stop("long values must be larger than -180")
if(any(long >  180)) stop("long values must be lesser than 180")
if(any(lat  <  -90))  stop("lat values must be larger than -90")
if(any(lat  >   90))  stop("lat values must be lesser than 90")
# bounding box:
bbox <- c(extendrange(long, f=fx), extendrange(lat, f=fy))
# actual map download:
if(is.null(map)) map <- OpenStreetMap::openmap(upperLeft=bbox[c(4,1)],
                                       lowerRight=bbox[c(3,2)], type=type, ...)
#
# optionally, projection
if(utm) map <- OpenStreetMap::openproj(map, projection=proj)
# optionally, plotting:
if(plot)
{
if(!add) plot(map, removeMargin=FALSE) # plot.OpenStreetMap -> plot.osmtile -> rasterImage
###crs <- if(utm) sp::CRS(proj) else OpenStreetMap::osm()
crs <- map$tiles[[1]]$projection
pts <- projectPoints(lat,long, crs=crs)
do.call(points, owa(list(x=pts[,"x"], y=pts[,"y"], pch=3, lwd=3), pargs))
if(scale) scaleBar(map)
}
# output:
return(invisible(map))
}
