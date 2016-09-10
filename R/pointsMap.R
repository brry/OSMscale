#' Get map for lat-long points
#'
#' Download and plot map with the extend of a dataset with lat-long coordinates
#'
#' @return Map returned by \code{\link{openmap}}
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{projectPoints}}, \code{OpenStreetMap::\link[OpenStreetMap]{openmap}}
#' @keywords hplot spatial
#' @importFrom grDevices extendrange
#' @importFrom berryFunctions owa getColumn
#' @importFrom OpenStreetMap openmap openproj osm
#' @importFrom sp CRS
#' @importFrom graphics points
#' @export
#' @examples
#' if(interactive()){
#' d <- read.table(sep=",", header=TRUE, text=
#' "lat, long # could e.g. be copied from googleMaps, rightclick on What's here?
#' 43.221028, -123.382998
#' 43.215348, -123.353804
#' 43.227785, -123.368694
#' 43.232649, -123.355895")
#'
#' map <- pointsMap(lat, long, d, scale=list(ndiv=5), col="orange", pch=3, lwd=3)
#' map_utm <- pointsMap(d, map=map, utm=TRUE)
#' axis(1); axis(2) # now in meters
#' projectPoints(d$lat, d$long)
#' scaleBar(map_utm, x=0.2, y=0.8, unit="mi", type="line", col="red", length=0.25)
#' pointsMap(d[1:2,], map=map_utm, add=TRUE, col="red", pch=3, lwd=3)
#'
#' d <- data.frame(long=c(12.95, 12.98, 13.22, 13.11), lat=c(52.40,52.52, 52.36, 52.45))
#' map <- pointsMap(lat,long,d, type="bing") # aerial map
#' }
#'
#' @param lat,long Latitude (North/South) and longitude (East/West) coordinates in decimal degrees
#' @param data Optional: data.frame with the columns \code{lat} and \code{long}
#' @param ext Extension added in each direction if a single coordinate is given. DEFAULT: 0.07
#' @param fx,fy Extend factors (additional map space around actual points)
#'              passed to custom version of \code{\link{extendrange}}. DEFAULT: 0.05
#' @param type Tile server in \code{\link[OpenStreetMap]{openmap}}
#' @param zoom,minNumTiles,mergeTiles Arguments passed to \code{\link[OpenStreetMap]{openmap}}
#' @param map Optional map object. If given, it is not downloaded again.
#'            Useful to project maps in a second step. DEFAULT: NULL
#' @param utm Logical: Convert map to UTM (or other \code{proj})?
#'            Consumes some extra time. DEFAULT: FALSE
#' @param proj proj4 character string or CRS object to project to.
#'             Only used if utm=TRUE. DEFAULT: \code{\link{putm}(long=long)}
#' @param plot Logical: Should map be plotted and points added? DEFAULT: TRUE
#' @param add Logical: add points to existing map? DEFAULT: FALSE
#' @param scale FALSE to suppress scaleBar drawing, else:
#'              List of arguments passed to \code{\link{scaleBar}}. DEFAULT: NULL
#' @param quiet Logical: suppress progress messages? DEFAULT: FALSE
#' @param pch,col Arguments passed to \code{\link{points}}. DEFAULT: 3, "red
#' @param \dots Further arguments passed to \code{\link{points}} like lwd, type, cex...
#'
pointsMap <- function(
lat,
long,
data,
ext=0.07,
fx=0.05,
fy=fx,
type="osm",
zoom=NULL,
minNumTiles=9L,
mergeTiles=TRUE,
map=NULL,
utm=FALSE,
proj=putm(long=long),
plot=TRUE,
add=FALSE,
scale=NULL,
quiet=FALSE,
pch=3,
col="red",
...
)
{
# Input processing:
if(isTRUE(scale)) scale <- NULL
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(lat , data)
  long <- getColumn(long, data)
}
checkLL(lat, long)
# bounding box:
dr <- function(x)
  {
  # if only a single point is given, extend by ext in each direction
  if(length(x)==1) x <- x + c(-1,1)*ext
  diff(range(x, na.rm=TRUE))
  }
extendrange2 <- function(x,f) range(x, na.rm=TRUE) + c(-f,f) * max(dr(lat),dr(long))
bbox <- c(extendrange2(long, f=fx), extendrange2(lat, f=fy))
#
# actual map download:
if(is.null(map))
  {
  if(!quiet)
    {
    message("Downloading map with extend ", toString(round(bbox,6)), " ...")
    flush.console()
    }
  map <- OpenStreetMap::openmap(upperLeft=bbox[c(4,1)], lowerRight=bbox[c(3,2)],
         type=type, zoom=zoom, minNumTiles=minNumTiles, mergeTiles=mergeTiles)
  }
# optionally, projection
if(utm & !quiet)
  {
  message("Projecting map to ", proj, " ...")
  flush.console()
  }
if(utm) map <- OpenStreetMap::openproj(map, projection=proj)
# optionally, plotting:
if(plot)
{
if(!quiet) {message("Done. Now plotting..."); flush.console()}
if(!add) plot(map, removeMargin=FALSE) # plot.OpenStreetMap -> plot.osmtile -> rasterImage
pts <- projectPoints(lat,long, to=map$tiles[[1]]$projection)
points(x=pts[,"x"], y=pts[,"y"], pch=pch, col=col, ...)
if(is.null(scale)|is.list(scale)) do.call(scaleBar, berryFunctions::owa(list(map=map), scale))
}
# output:
return(invisible(map))
}
