#' CRS of various PROJ.4 projections
#'
#' coordinate reference system (CRS) Object for several proj4 character strings.
#' \code{posm} and \code{pll} are taken directly from
#' \code{OpenStreetMap::\link[OpenStreetMap]{osm}} and
#' \code{\link[OpenStreetMap]{longlat}}.\cr
#' \code{pmap} gets the projection string from map objects as returned by \code{\link{pointsMap}}.
#'
#' @name proj
#' @aliases posm pll putm pmap
#'
#' @return \code{sp::\link[sp]{CRS}} objects for one of: \cr
#'         - UTM projection with given zone\cr
#'         - Open street map (and google) mercator projection\cr
#'         - Latitude Longitude projection\cr

#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016
#' @seealso \code{\link{projectPoints}}, \code{\link{degree}}
#' @keywords spatial
#' @importFrom sp CRS
#' @export
#' @examples
#' posm()
#' str(posm())
#' posm()@projargs
#' pll()
#' putm(5:14) # Germany
#' putm(zone=33) # Berlin
#'
#' map <- list(tiles=list(dummy=list(projection=pll())),
#'             bbox=list(p1=par("usr")[c(1,4)], p2=par("usr")[2:3]) )
#' pmap(map)
#'
#' @param long Vector of decimal longitude coordinates (East/West values).
#'             Not needed of \code{zone} is given.
#' @param zone UTM (Universal Transverse Mercator) zone, see e.g.
#'             \url{https://upload.wikimedia.org/wikipedia/commons/e/ed/Utm-zones.jpg}.
#'             DEFAULT: UTM zone at \link{mean} of \code{long}
#' @param map  for pmap: map object as returned by \code{\link{pointsMap}}
#'
putm <- function
(
  long,
  zone=mean(long,na.rm=TRUE)%/%6+31
)
{
  if(!missing(long)) checkLL(long=long, lat=0)
  sp::CRS(paste0("+proj=utm +zone=",zone," +ellps=WGS84 +datum=WGS84"))
}
#' @export
#' @rdname proj
posm <- function() sp::CRS("+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs")
#' @export
#' @rdname proj
pll  <- function() sp::CRS("+proj=longlat +datum=WGS84")
#' @export
#' @rdname proj
pmap <- function(map)
{
name <- deparse(substitute(map))
prj <- map$tiles[[1]]$projection
if(is.null(prj)) stop("Projection could not be obtained from '",name,"'.",
                      "It seems there is no element $tiles[[1]]$projection.")
prj
}

