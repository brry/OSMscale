#' Project latlon points
#'
#' Project long lat points to e.g. UTM projection.
#' Basically copied from OpenStreetMap::projectMercator
#'
#' @return data.frame with points in new projection
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{scaleBarOSM}}, \code{\link[OpenStreetMap]{projectMercator}}, \url{http://gis.stackexchange.com/a/74723}
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
#' stopifnot(all(projectPoints(lat,lon, crs=osm())==projectMercator(lat,lon)))
#'
#' @param lat A vector of latitudes
#' @param long A vector of longitudes
#' @param drop Drop to lowest dimension? DEFAULT: FALSE (unlike projectMercator)
#' @param zone UTM zone, see e.g. \url{https://upload.wikimedia.org/wikipedia/commons/e/ed/Utm-zones.jpg}. DEFAULT: at mean of long
#' @param proj proj4 character string or CRS object to project to. DEFAULT: UTM projection at \code{zone}
#' @param crs Coordinate Reference System Object. If given, overrides \code{proj}. DEFAULT: CRS(proj)
#'

projectPoints <- function (
lat,
long,
drop=FALSE,
zone=mean(long)%/%6+31,
proj=paste0("+proj=utm +zone=",zone,"+ellps=WGS84 +datum=WGS84"),
crs=CRS(proj)
)
{
df <- data.frame(long = long, lat = lat)
coordinates(df) <- ~long + lat
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")
df1 <- spTransform(df, crs)
coords <- coordinates(df1)
colnames(coords) <- c("x", "y")
if (drop) coords <- drop(coords)
coords
}
