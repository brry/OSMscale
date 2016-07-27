#' Project lat-lon points
#'
#' Project long lat points to e.g. UTM projection.
#' Basically copied from OpenStreetMap::projectMercator
#'
#' @return data.frame with points in new projection
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{scaleBar}}, \code{\link[OpenStreetMap]{projectMercator}}, \url{http://gis.stackexchange.com/a/74723}
#' @keywords spatial
#' @importFrom OpenStreetMap osm projectMercator
#' @importFrom sp coordinates coordinates<- CRS proj4string proj4string<- spTransform
#' @export
#' @examples
#' library("OpenStreetMap")
#' lat <- runif(100, 6, 12)
#' lon <- runif(100, 48, 58)
#' plot(lat,lon)
#' plot(projectMercator(lat,lon), main="Mercator")
#' plot(projectPoints(lat,lon), main="UTM32")
#' stopifnot(all(projectPoints(lat,lon, to=osm())==projectMercator(lat,lon)))
#'
#' @param lat A vector of latitudes
#' @param long A vector of longitudes
#' @param from Original Projection (do not change for latlong-coordinates).
#'             DEFAULT: CRS("+proj=longlat +datum=WGS84")
#' @param to Coordinate Reference System Object.
#'           If given, overrides \code{proj}. DEFAULT: CRS(proj)
#' @param proj proj4 character string or CRS object to project to.
#'             DEFAULT: UTM projection at \code{zone}
#' @param zone UTM zone, see e.g. \url{https://upload.wikimedia.org/wikipedia/commons/e/ed/Utm-zones.jpg}.
#'             DEFAULT: \link{mean} of \code{long}
#' @param drop Drop to lowest dimension? DEFAULT: FALSE (unlike projectMercator)
#'
projectPoints <- function (
lat,
long,
from=sp::CRS("+proj=longlat +datum=WGS84"),
to=sp::CRS(proj),
proj=paste0("+proj=utm +zone=",zone,"+ellps=WGS84 +datum=WGS84"),
zone=mean(long)%/%6+31,
drop=FALSE
)
{
# Original points into object of class "SpatialPoints":
df <- data.frame(long = long, lat = lat)
coordinates(df) <- ~long + lat
proj4string(df) <- from
# Actual transformation:
df1 <- spTransform(df, to)
# Use only coordinates of result:
coords <- coordinates(df1)
colnames(coords) <- c("x", "y")
if (drop) coords <- drop(coords)
coords
}
