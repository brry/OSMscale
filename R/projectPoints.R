#' Project lat-lon points
#'
#' Project long lat points to e.g. UTM projection.
#' Basically copied from OpenStreetMap::projectMercator
#'
#' @return data.frame with points in new projection
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{scaleBar}}, \code{\link[OpenStreetMap]{projectMercator}},
#'          \url{http://gis.stackexchange.com/a/74723}, \url{http://spatialreference.org} on proj4strings
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
#' # ETRS89
#' set.seed(42)
#' d <- data.frame(N=runif(50,5734000,6115000), E=runif(50, 33189000,33458000))
#' d$VALUES <- berryFunctions::rescale(d$N, 20,40) + rnorm(50, sd=5)
#' c1 <- projectPoints(lat=d$N, long=d$E-33e6, to=longlat(),
#'           from=sp::CRS("+proj=utm +zone=33 +ellps=GRS80 +units=m +no_defs") )
#' c2 <- projectPoints(c1$y, c1$x, to=osm() )
#' head(d)
#' head(c1)
#' head(c2)
#'
#' \dontrun{
#' map <- pointsMap(c1, "x", "y", plot=FALSE)
#' pdf("ETRS89.pdf")
#' par(mar=c(0,0,0,0))
#' plot(map)
#' rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col=addAlpha("white", 0.7))
#' scaleBar(map, y=0.2)
#' points(c2)
#' berryFunctions::colPoints(c2$x, c2$y, d$VALUE )
#' dev.off()
#' }
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
#' @param dfout Convert output to data.frame to allow easier indexing? DEFAULT: TRUE
#'
projectPoints <- function (
lat,
long,
from=sp::CRS("+proj=longlat +datum=WGS84"),
to=sp::CRS(proj),
proj=paste0("+proj=utm +zone=",zone,"+ellps=WGS84 +datum=WGS84"),
zone=mean(long)%/%6+31,
drop=FALSE,
dfout=TRUE
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
if(dfout) return(as.data.frame(coords))
coords
}
