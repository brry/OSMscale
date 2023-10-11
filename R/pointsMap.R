#' Get map for lat-long points
#' 
#' Download and plot map with the extend of a dataset with lat-long coordinates.
#' 
#' @return Map returned by \code{OpenStreetMap::\link{openmap}}
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{projectPoints}}, \code{OpenStreetMap::\link[OpenStreetMap]{openmap}}
#' @keywords hplot spatial
#' @importFrom grDevices extendrange
#' @importFrom berryFunctions owa getColumn
#' @importFrom OpenStreetMap openmap openproj osm
#' @importFrom graphics points par plot
#' @importFrom utils flush.console
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
#' map <- pointsMap(lat, long, data=d)
#' axis(1, line=-2); axis(2, line=-2) # in whatever unit
#' map_utm <- pointsMap(lat, long, d, map=map, proj=putm(d$long))
#' axis(1, line=-2); axis(2, line=-2) # now in meters
#' projectPoints(d$lat, d$long)
#' scaleBar(map_utm, x=0.2, y=0.8, unit="mi", type="line", col="red", length=0.25)
#' pointsMap(lat, long, d[1:2,], map=map_utm, add=TRUE, col="red", pch=3, pargs=list(lwd=3))
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
#' @param type Tile server in \code{OpenStreetMap::\link[OpenStreetMap]{openmap}}.
#'             For an overview, see \url{http://blog.fellstat.com/?p=356} and
#'             \code{\link{mapComp}}. DEFAULT: "osm"
#' @param zoom,minNumTiles,mergeTiles Arguments passed to \code{\link[OpenStreetMap]{openmap}}
#' @param map Optional map object. If given, it is not downloaded again.
#'            Useful to project maps in a second step. DEFAULT: NULL
#' @param proj If you want to reproject the map (Consumes some extra time), the
#'             proj4 character string or CRS object to project to, e.g. \code{\link{putm}(long=long)}.
#'             DEFAULT: NA (no conversion)
#' @param plot Logical: Should map be plotted and points added? Plotting happens with
#'             \code{OpenStreetMap::\link[OpenStreetMap]{plot.OpenStreetMap}(map,
#'             removeMargin=FALSE)}. DEFAULT: TRUE
#' @param mar Margins to be set first (and left unchanged). DEFAULT: c(0,0,0,0)
#' @param add Logical: add points to existing map? DEFAULT: FALSE
#' @param scale Logical: should \code{\link{scaleBar}} be added? DEFAULT: TRUE
#' @param quiet Logical: suppress progress messages and non-df warning in 
#'              \code{\link[berryFunctions]{getColumn}}? DEFAULT: FALSE
#' @param pch,col,cex,bg Arguments passed to \code{\link{points}},
#'              see \code{pargs} for more. DEFAULT: pch=3, col="red", cex=1, bg=NA
#' @param pargs List of arguments passed to \code{\link{points}} like lwd, type, cex, ...
#' @param titleargs List of arguments passed to \code{\link{title}} (if not NULL). DEFAULT: NULL
#' @param \dots Further arguments passed to \code{\link{scaleBar}} like abslen, ndiv, ...
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
proj=NA,
plot=TRUE,
mar=c(0,0,0,0),
add=FALSE,
scale=TRUE,
quiet=FALSE,
pch=3,
col="red",
cex=1,
bg=NA,
pargs=NULL,
titleargs=NULL,
...
)
{
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data, quiet=quiet)
  long <- getColumn(substitute(long), data, quiet=quiet)
  }
checkLL(lat, long)
# bounding box:
dr <- function(x)
  {
  # if only a single point is given, add ext in each direction
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
  map <- suppressCRSwarning(OpenStreetMap::openmap(upperLeft=bbox[c(4,1)], lowerRight=bbox[c(3,2)],
         type=type, zoom=zoom, minNumTiles=minNumTiles, mergeTiles=mergeTiles))
  }
# optionally, projection
if(!is.na(proj))
  {
  if(!quiet) message("Projecting map to ", proj, " ...")
  flush.console()
  map <- suppressCRSwarning(OpenStreetMap::openproj(map, projection=proj))
  }
# optionally, plotting:
if(plot)
{
if(!quiet) {message("Done. Now plotting..."); flush.console()}
par(mar=mar)
if(!add) plot(map, removeMargin=FALSE) # plot.OpenStreetMap -> plot.osmtile -> rasterImage
pts <- projectPoints(lat,long, to=pmap(map))
do.call(points, berryFunctions::owa(list(
        x=pts[,"x"], y=pts[,"y"], pch=pch, col=col, cex=cex, bg=bg), pargs))
if(scale) scaleBar(map=map, ...)
if(!is.null(titleargs)) do.call(title, titleargs)
par(mar=mar)
}
# output:
return(invisible(map))
}
