#' distance between lat-long coordinates
#'
#' Great-circle distance between points at lat-long coordinates.
#' (The shortest distance over the earth's surface).
#' The distance of all the entries relative to the first one is computed.
#'
#' @return Vector with distance(s) in km
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016.
#'         Angle formula from Diercke Weltatlas 1996, Page 245
#' @seealso \code{\link{degree}} for pre-formatting,
#'          \url{http://www.movable-type.co.uk/scripts/latlong.html}
#' @keywords spatial
#' @importFrom berryFunctions getColumn
#' @export
#' @examples
#' d <- read.table(header=TRUE, sep=",", text="
#' lat, long
#' 52.514687, 13.350012   # Berlin
#' 35.685024, 139.753365  # Tokio
#' 51.503162, -0.131082") # London
#' earthDist(lat, long, d) # 8922 and 928 km
#' map <- pointsMap(lat, long, d, zoom=2, scale=list(ndiv=4, y=0.7))
#' scaleBar(map, y=0.5, ndiv=4)   # in mercator projections, scale bars are not
#' scaleBar(map, y=0.3, ndiv=4)   # transferable to other latitudes
#'
#' # compare with UTM distance
#' set.seed(42)
#' d <- data.frame(lat=runif(100, 47,54), long=runif(100, 6, 15))
#' d2 <- projectPoints(d$lat, d$long)
#' d_utm <- berryFunctions::distance(d2$x[-1],d2$y[-1], d2$x[1],d2$y[1])/1000
#' d_earth <- earthDist(lat,long, d)
#' plot(d_utm, d_earth) # distances in km
#' hist(d_utm-d_earth) # UTM distance slightly larger than earth distance
#' plot(d_earth, d_utm-d_earth) # correlates with distance
#' berryFunctions::colPoints(d2$x[-1], d2$y[-1], d_utm-d_earth, add=FALSE)
#' points(d2$x[1],d2$y[1], pch=3, cex=2, lwd=2)
#'
#' @param lat,long Latitude (North/South) and longitude (East/West) coordinates in decimal degrees
#' @param data Optional: data.frame with the columns \code{lat} and \code{long}
#' @param r radius of the earth. Could be given in miles. DEFAULT: 6371 (km)
#' @param trace Logical: trace the coordinate check with \code{\link{checkLL}}?
#'        Should be set to FALSE in a \link{do.call} setting to avoid overhead
#'        computing time. DEFAULT: TRUE
#'
earthDist <- function(
lat,
long,
data,
r=6371,
trace=TRUE
)
{
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(lat , data, trace=trace)
  long <- getColumn(long, data, trace=trace)
  }
# coordinate control:
checkLL(lat, long, trace=trace)
# convert degree angles to radians
y1 <-  lat[1]*pi/180
x1 <- long[1]*pi/180
y2 <-  lat[-1]*pi/180
x2 <- long[-1]*pi/180
# angle between lines from earth center to coordinates:
angle <- acos( sin(y1)*sin(y2) + cos(y1)*cos(y2)*cos(x1-x2) )
# compute great-circle-distance:
r*angle
}
