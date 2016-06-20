#' scalebar for OSM plots
#'
#' Add a scalebar to default OpenStreetMap plots
#'
#' @details This is a starting version and might be expanded heavily in customization options
#'
#' @return invisible: coordinates of scalebar and label
#' @section Warning: Only works correctly for UTM maps, not for the Mercator projection!
#'                   Has not been extensively tested yet, please report bugs.
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{projectPoints}}
#' @keywords aplot spatial
#' @importFrom graphics par segments
#' @importFrom berryFunctions owa textField
#' @importFrom OpenStreetMap openmap openproj
#' @export
#' @examples
#' library("OpenStreetMap")
#' d <- data.frame(long=c(12.95, 12.98, 13.22, 13.11), lat=c(52.40,52.52, 52.36, 52.45))
#' map <- pointsMap(d, utm=TRUE)
#' coord <- scaleBarOSM()  ; coord
#' scaleBarOSM(0.3, 0.05, unit="m")
#' scaleBarOSM(0.3, 0.5, unit="km", length=0.1)
#' scaleBarOSM(0.12, 0.28, abslen=20000)
#' scaleBarOSM(0.6, 0.8, unit="mi", col="red", targ=list(col="red"))
#'
#' \dontrun{ ## Development stuff for mercator projection
#'
#' map <- pointsMap(d)
#' scaleBarOSM(abslen=5000) # wrong for mercator projection. 5km is longer
#' SDMTools::Scalebar(x=1442638,y=6893871,distance=10000) # wrong as well
#' raster::scalebar(d=5000, xy=c(1442638,6893871)) # also wrong
#' raster::pointDistance ?
#'
#' map2 <- pointsMap(d, map=map, utm=TRUE, pargs=list(pch=NA))
#' par(mfrow=c(1,2))
#' plot(map2, removeMargin=T)
#' scaleBarOSM(x=0.33, y=0.48, abslen=5000)
#' plot(map, removeMargin=T)
#' mapmisc::scaleBar(map$tiles[[1]]$projection, seg.len=10, pos="center", bg="transparent")
#' # Well that's fairly good in some circumstances, but weird for others
#' }
#'
#' @param x,y Relative position of left end of scalebar. DEFAULT: 0.1, 0.9
#' @param length Approximate relative length of bar. DEFAULT: 0.1
#' @param abslen Absolute length in \code{unit}s. DEFAULT: NA (computed internally from length)
#' @param unit Unit for computation and label. kilometer and meter as well as
#'             miles, feet and yards are possible.
#'             Note that the returned absolute length is in m. DEFAULT: "km"
#' @param field,fill,adj Arguments passed to \code{\link{textField}}
#' @param targs List of further arguments passed to \code{\link{textField}}
#'                 like cex, col, etc. DEFAULT: NULL
#' @param lwd,lend Line width and end style passed to \code{\link{segments}}. DEFAULT: 5,1
#' @param \dots Further arguments passed to \code{\link{segments}} like col
#'
scaleBarOSM <- function(
x=0.1,
y=0.9,
length=0.2,
abslen=NA,
unit=c("km","m","mi","ft","yd"),
field="rect",
fill=NA,
adj=c(0.5, 1.5),
targs=NULL,
lwd=5,
lend=1,
...
)
{
# input checks:
x <- x[1]; y <- y[1]
if(x<0) stop("x must be larger than 0, not ", x)
if(y<0) stop("y must be larger than 0, not ", y)
if(x>1) stop("x must be lesser than 1, not ", x)
if(y>1) stop("y must be lesser than 1, not ", y)
# factor:
unit <- unit[1]
if(!is.character(unit)) stop("unit must be a character string, not a ", class(unit))
f <- switch(unit, # switch is around 4 times faster than nested ifelse ;-)
  m=1,
  km=1000,
  mi=1609.34,
  ft=0.3048,
  yd=0.9144,
  message("unit '", unit,"' not (yet) supported.")
  )
# coordinate range:
r <- par("usr")
# get absolute coordinates (abslen in m):
if(is.na(abslen)) abslen <- pretty(diff(r[1:2])/f*length)[2]*f
x <- r[1]+x*diff(r[1:2])
y <- r[3]+y*diff(r[3:4])
# draw segment:
segments(x0=x, x1=x+abslen, y0=y, lwd=lwd, lend=lend, ...)
# label scale bar:
xl <- x+0.5*abslen
do.call(textField, owa(list(x=xl, y=y, labels=paste(abslen/f, unit), field=field,
                            fill=fill, adj=adj), targs))
# return absolute coordinates
return(invisible(c(x=x, y=y, abslen=abslen, label=xl)))
}
