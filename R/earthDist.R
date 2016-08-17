#' distance between lat-long coordinates
#'
#' Great-circle distance between points at lat-long coordinates.
#' (The shortest distance over the earth's surface).
#'
#' @return Vector with distance(s) in km
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016.
#'         Angle formula from Diercke Weltatlas 1996, Page 245
#' @seealso \code{\link{degree}} for pre-formatting,
#'          \url{http://www.movable-type.co.uk/scripts/latlong.html}
#' @keywords spatial
#' @export
#' @examples
#' d <- read.table(header=TRUE, sep=",", text="
#' lat, long
#' 52.514687, 13.350012   # Berlin
#' 35.685024, 139.753365  # Tokio
#' 51.503162, -0.131082") # London
#' earthDist(d) # 8922 and 928 km
#' map <- pointsMap(d, zoom=2)
#'
#' @param df Dataframe with lat and long columns.
#'           The distance of all the entries relative to the first row is computed.
#' @param r radius of the earth. Could be given in miles. DEFAULT: 6371 (km)
#'
earthDist <- function(
df,
r=6371
)
{
if(!"lat"  %in% colnames(df)) stop("Column 'lat' must be present in df.")
if(!"long" %in% colnames(df)) stop("Column 'long' must be present in df.")
# single coordinates:
y1 <- df[1,"lat"]
x1 <- df[1,"long"]
y2 <- df[-1,"lat"]
x2 <- df[-1,"long"]
# convert degree angles to radians
y1 <- y1*pi/180
y2 <- y2*pi/180
x1 <- x1*pi/180
x2 <- x2*pi/180
# angle between lines from earth center to coordinates:
angle <- acos( sin(y1)*sin(y2) + cos(y1)*cos(y2)*cos(x1-x2) )
# compute great-circle-distance:
r*angle
}
