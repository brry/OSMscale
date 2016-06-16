#' Project latlon points
#'
#' Project long lat points to e.g. UTM projection.
#' Basically copied from OpenStreetMap::projectMercator
#'
#' @return data.frame with points in new projection
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{scaleBarOSM}}, \code{\link{help}}
#' @keywords spatial
#' @export
#' @examples
#' # see scaleBarOSM
#' \dontrun{## Not run because of OpenStreetMap dependency
#' library("OpenStreetMap")
#' lat <- runif(100, 6, 12)
#' lon <- runif(100, 48, 58)
#' plot(lat,lon)
#' plot(projectMercator(lat,lon), main="Mercator")
#' plot(projectPoints(lat,lon), main="UTM32")
#' }
#'
#' @param lat A vector of latitudes
#' @param long A vector of longitudes
#' @param drop Drop to lowest dimension? DEFAULT: FALSE (unlike projectMercator)
#' @param zone UTM zone, see e.g. \url{https://upload.wikimedia.org/wikipedia/commons/e/ed/Utm-zones.jpg}. DEFAULT: 32
#' @param proj Projection string to preject to. DEFAULT: UTM zone 32 (center Germany)
#'

projectPoints <- function (
lat, 
long, 
drop=FALSE, 
zone=32,
proj=paste0("+proj=utm +zone=",zone,"+ellps=WGS84 +datum=WGS84")
) 
{
df <- data.frame(long = long, lat = lat)
coordinates(df) <- ~long + lat
proj4string(df) <- CRS("+proj=longlat +datum=WGS84")
df1 <- spTransform(df, CRS(proj))
coords <- coordinates(df1)
colnames(coords) <- c("x", "y")
if (drop) coords <- drop(coords)
coords
}
