#' Project lat-lon points
#' 
#' Project long lat points to e.g. UTM projection.
#' Basics copied from \code{OpenStreetMap::\link[OpenStreetMap]{projectMercator}}
#' 
#' @return data.frame (or matrix, if \code{dfout=FALSE})  with points in new projection
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{scaleBar}}, \code{OpenStreetMap::\link[OpenStreetMap]{projectMercator}},
#'          \url{http://gis.stackexchange.com/a/74723}, \url{http://spatialreference.org} on proj4strings
#' @keywords spatial
#' @importFrom OpenStreetMap osm projectMercator
#' @importFrom sf st_as_sf st_transform st_coordinates
#' @importFrom berryFunctions getColumn
#' @export
#' @examples
#' library("OpenStreetMap")
#' lat <- runif(100, 6, 12)
#' lon <- runif(100, 48, 58)
#' plot(lat,lon, main="flat earth unprojected")
#' plot(projectMercator(lat,lon), main="Mercator")
#' plot(projectPoints(lat,lon), main="UTM32")
#' stopifnot(all( projectPoints(lat,lon, to=posm()) == projectMercator(lat,lon) ))
#' 
#' projectPoints(c(52.4,NA),      c(13.6,12.9))
#' projectPoints(c(52.4,NA),      c(13.6,12.9), quiet=TRUE)
#' projectPoints(c(52.4,52.3,NA), c(13.6,12.9,13.1))
#' projectPoints(c(52.4,52.3,NA), c(13.6,NA  ,13.1))
#' projectPoints(c(52.4,52.3,NA), c(NA  ,12.9,13.1))
#' 
#' # Reference system ETRS89 with GRS80-Ellipsoid (common in Germany)
#' set.seed(42)
#' d <- data.frame(N=runif(50,5734000,6115000), E=runif(50, 33189000,33458000))
#' d$VALUES <- berryFunctions::rescale(d$N, 20,40) + rnorm(50, sd=5)
#' head(d)
#' c1 <- projectPoints(lat=d$N, long=d$E-33e6, to=pll(),
#'           from=sf::st_crs("+proj=utm +zone=33 +ellps=GRS80 +units=m +no_defs") )
#' c2 <- projectPoints(y, x, data=c1, to=posm() )
#' head(c1)
#' head(c2)
#' 
#' \dontrun{ # not checked on CRAN because of file opening
#' map <- pointsMap(y,x, c1, plot=FALSE)
#' pdf("ETRS89.pdf")
#' par(mar=c(0,0,0,0))
#' plot(map)
#' rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4],
#'      col=berryFunctions::addAlpha("white", 0.7))
#' scaleBar(map, y=0.2, abslen=100)
#' points(c2)
#' berryFunctions::colPoints(c2$x, c2$y, d$VALUE )
#' dev.off()
#' berryFunctions::openFile("ETRS89.pdf")
#' #unlink("ETRS89.pdf")
#' }
#' 
#' @param lat,long Latitude (North/South) and longitude (East/West) coordinates in decimal degrees
#' @param data Optional: data.frame with the columns \code{lat} and \code{long}
#' @param from Original Projection CRS (do not change for latlong-coordinates).
#'             DEFAULT: \code{\link{pll}()} = sf::st_crs("+proj=longlat +datum=WGS84")
#' @param to target projection CRS (Coordinate Reference System) Object.
#'           Other projections can be specified as \code{sf::\link[sf]{st_crs}("your_proj4_character_string")}.
#'           DEFAULT: \code{\link{putm}(long=long)}
#' @param dfout Convert output to data.frame to allow easier indexing? DEFAULT: TRUE
#' @param drop Drop to lowest dimension? DEFAULT: FALSE (unlike \code{\link[OpenStreetMap]{projectMercator}})
#' @param quiet Suppress warning about NA coordinates and non-df warning in 
#'              \code{\link[berryFunctions]{getColumn}}? DEFAULT: FALSE
#' 
projectPoints <- function (
lat,
long,
data,
from=pll(),
to=putm(long=long),
spout=FALSE,
dfout=TRUE,
drop=FALSE,
quiet=FALSE
)
{
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data, quiet=quiet)
  long <- getColumn(substitute(long), data, quiet=quiet)
  }
# NA management
nas <- is.na(lat)|is.na(long)
if(any(nas) & !quiet) warning("there are ", sum(nas), " NAs in coordinates.")
lat <- lat[!nas] ; long <- long[!nas]
# Actual transformation:
dsf <- sf::st_as_sf(data.frame(long=long, lat=lat), coords=c("long", "lat"), crs=from)
df1 <- sf::st_transform(dsf, to)
# Use only coordinates of result:
coords <- sf::st_coordinates(df1)
# Post processing, NA management:
out <- matrix(NA, nrow=length(nas), ncol=2)
colnames(out) <- c("x", "y")
out[!nas,] <- coords
# formatting
if(dfout) out <- as.data.frame(out)
if(drop) out <- drop(out)
out
}
