#' distance between lat-long coordinates
#'
#' Great-circle distance between points at lat-long coordinates.
#' (The shortest distance over the earth's surface).
#' The distance of all the entries is computed relative to the \code{i}th one.
#'
#' @return Vector with distance(s) in km (or units of \code{r}, if \code{r} is changed)
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016 + Jan 2017.
#'         Angle formula from Diercke Weltatlas 1996, Page 245
#' @seealso \code{\link{degree}} for pre-formatting,
#'          \url{http://www.movable-type.co.uk/scripts/latlong.html}
#' @keywords spatial
#' @importFrom berryFunctions getColumn almost.equal
#' @export
#' @examples
#' d <- read.table(header=TRUE, sep=",", text="
#' lat, long
#' 52.514687,  13.350012   # Berlin
#' 51.503162,  -0.131082   # London
#' 35.685024, 139.753365") # Tokio
#' earthDist(lat, long, d)      # from Berlin to L and T: 928 and 8922 km
#' earthDist(lat, long, d, i=2) # from London to B and T: 928 and 9562 km
#'
#' # slightly different with other formulas:
#' # install.packages("geosphere")
#' # geosphere::distHaversine(as.matrix(d[1,2:1]), as.matrix(d[2,2:1])) / 1000
#'
#'
#' # compare with UTM distance
#' set.seed(42)
#' d <- data.frame(lat=runif(100, 47,54), long=runif(100, 6, 15))
#' d2 <- projectPoints(d$lat, d$long)
#' d_utm <- berryFunctions::distance(d2$x[-1],d2$y[-1], d2$x[1],d2$y[1])/1000
#' d_earth <- earthDist(lat,long, d)[-1]
#' plot(d_utm, d_earth) # distances in km
#' hist(d_utm-d_earth) # UTM distance slightly larger than earth distance
#' plot(d_earth, d_utm-d_earth) # correlates with distance
#' berryFunctions::colPoints(d2$x[-1], d2$y[-1], d_utm-d_earth, add=FALSE)
#' points(d2$x[1],d2$y[1], pch=3, cex=2, lwd=2)
#'
#'
#' @param lat,long Latitude (North/South) and longitude (East/West) coordinates in decimal degrees
#' @param data Optional: data.frame with the columns \code{lat} and \code{long}
#' @param r radius of the earth. Could be given in miles. DEFAULT: 6371 (km)
#' @param i Integer: Index element against which all coordinate pairs
#'          are computed. DEFAULT: 1
#' @param trace Logical: trace the coordinate check with \code{\link{checkLL}}?
#'        Should be set to FALSE in a \link{do.call} setting to avoid overhead
#'        computing time. DEFAULT: TRUE
#'
earthDist <- function(
lat,
long,
data,
r=6371,
i=1L,
trace=TRUE
)
{
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data, trace=trace)
  long <- getColumn(substitute(long), data, trace=trace)
  }
# coordinate control:
checkLL(lat, long, trace=trace)
# index control:
i <- as.integer(i[1])
# convert degree angles to radians
y1 <-  lat[i]*pi/180
x1 <- long[i]*pi/180
y2 <-  lat*pi/180
x2 <- long*pi/180
# angle preparation (numerical inaccuracies may lead to 1.0000000000000002):
cosinusangle <- sin(y1)*sin(y2) + cos(y1)*cos(y2)*cos(x1-x2)
cosinusangle <- replace(cosinusangle, cosinusangle>1, 1)
# angle between lines from earth center to coordinates:
angle <- acos( cosinusangle )
samepoint <- almost.equal(x2, x1) & almost.equal(y2, y1) # berryFunctions::almost.equal
angle[samepoint] <- 0 # again, to compensate numerical inaccuracies
# compute great-circle-distance:
r*angle
}
