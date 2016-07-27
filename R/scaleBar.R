#' scalebar for OSM plots
#'
#' Add a scalebar to default or UTM-projected OpenStreetMap plots
#'
#' @details This uses a hack to get the right distance in the default mercator projected maps.
#' There, the axes are not in meters, but rather ca 0.7m units (for NW Germany area maps with 20km across).
#' Accordingly, other packages plot wrong bars:\cr
#' SDMTools::Scalebar(x=1442638,y=6893871,distance=10000)\cr
#' raster::scalebar(d=5000, xy=c(1442638,6893871))\cr
#' mapmisc::scaleBar(map$tiles[[1]]$projection, seg.len=10, pos="center", bg="transparent")\cr
#' I suppose this function works for other projections as well, but haven't tried yet.
#' You might need to specify abslen manually with other projections where the axes do not resemble meters.
#'
#' @return invisible: coordinates of scalebar and label
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{pointsMap}}, \code{\link{projectPoints}}
#' @keywords aplot spatial
#' @importFrom graphics par rect segments strheight strwidth
#' @importFrom utils flush.console
#' @importFrom berryFunctions distance owa textField
#' @importFrom OpenStreetMap longlat openmap openproj
#' @export
#' @examples
#' d <- data.frame(long=c(12.95, 12.98, 13.22, 13.11), lat=c(52.40,52.52, 52.36, 52.45))
#' map <- pointsMap(d, scale=FALSE)
#' coord <- scaleBar(map)  ; coord
#' scaleBar(map, bg=berryFunctions::addAlpha("white", 0.7))
#' scaleBar(map, 0.3, 0.05, unit="m", type="line")
#' scaleBar(map, 0.3, 0.5, unit="km", length=0.1, ndiv=4, col=4:5, lwd=3)
#' scaleBar(map, 0.12, 0.28, abslen=15000, adj=c(0.5, -1.5)  )
#' scaleBar(map, 0.3, 0.8, unit="mi", col="red", targ=list(col="blue"), type="line")
#'
#' \dontrun{ ## Too much downloading time, too error-prone
#' # Tests around the world
#' par(mfrow=c(1,2), mar=rep(1,4))
#' long <- runif(1, -180, 180) ; long <- c(long,long+runif(1,0,4))
#' lat <- runif(1, -90, 90) ; lat <- c(lat,lat+runif(1,0,4))
#' # long <- c(5,15) ; lat=c(45,60)
#' map <- pointsMap(data.frame(long,lat))
#' map2 <- pointsMap(data.frame(long,lat), map=map, utm=TRUE)
#' }
#'
#' @param map Map object with map$tiles[[1]]$projection to get the projection from.
#' @param x,y Relative position of left end of scalebar. DEFAULT: 0.1, 0.9
#' @param length Approximate relative length of bar. DEFAULT: 0.2
#' @param abslen Absolute length in \code{unit}s. DEFAULT: NA (computed internally from length)
#' @param unit Unit for computation and label. kilometer and meter as well as
#'             miles, feet and yards are possible.
#'             Note that the returned absolute length is in m. DEFAULT: "km"
#' @param label Unit label in plot. DEFAULT: unit
#' @param type Scalebar type: simple 'line' or classical black & white 'bar'. DEFAULT: "line"
#' @param ndiv Number of divisions if type="bar". DEFAULT: NULL (computed internally)
#' @param field,fill,adj,cex,col Arguments passed to \code{\link[berryFunctions]{textField}}
#' @param targs List of further arguments passed to \code{\link[berryFunctions]{textField}}
#'                 like font, col (to differ from bar color), etc. DEFAULT: NULL
#' @param lwd,lend Line width and end style passed to \code{\link{segments}}. DEFAULT: 5,1
#' @param bg Background color. NA or "transparent" to suppress. DEFAULT: "white"
#' @param mar Background margins approximately in letter width/height. DEFAULT: c(1,0.2,0.2,3)
#' @param \dots Further arguments passed to \code{\link{segments}} like lty.
#'              (Color for segments is the first value of \code{col}).
#'              Passed to \code{\link{rect}} if type="bar", like lwd.
#'
scaleBar <- function(
map,
x=0.1,
y=0.9,
length=0.2,
abslen=NA,
unit=c("km","m","mi","ft","yd"),
label=unit,
type=c("bar","line"),
ndiv=NULL,
field="rect",
fill=NA,
adj=c(0.5, 1.5),
cex=par("cex"),
col=c("black","white"),
targs=NULL,
lwd=7,
lend=1,
bg="transparent",
mar=c(2,0.7,0.2,3),
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
# get absolute coordinates (abslen in m):                       # only in m in UTM!
if(is.na(abslen)) abslen <- pretty(diff(r[1:2])/f*length)[2]*f
x <- r[1]+x*diff(r[1:2])
y <- r[3]+y*diff(r[3:4])
end <- x+abslen # works for UTM, but not for mercator projection
crs <- map$tiles[[1]]$projection
if(substr(crs, 7, 9) != "utm")
  {
  pts_x <- seq(x, x+2*abslen, len=5000)
  pts_ll <- projectPoints(rep(y,5000), pts_x, to=OpenStreetMap::longlat(), from=crs)
  pts_utm <- projectPoints(pts_ll[,"y"], pts_ll[,"x"])
  pts_d <- distance(pts_utm[,"x"],pts_utm[,"y"],  pts_utm[1,"x"],pts_utm[1,"y"])
  end <- pts_x[which.min(abs(pts_d-abslen))]
  }
# Actually draw scalebar:
type <- type[1]
if(type=="line")
  {
  # background:
  if(missing(mar)) mar[c(2,4)] <- 0.2
  rect(  xleft=x-mar[2]*strwidth("m"),  xright=end+mar[4]*strwidth("m"),
       ybottom=y-mar[1]*strheight("m"),   ytop=y  +mar[3]*strheight("m"),
       col=bg, border=NA)
  # draw line segment:
  segments(x0=x, x1=end, y0=y, lwd=lwd, lend=lend, col=col[1], ...)
  # label scale bar:
  xl <- mean(c(x,end)) # ==x+0.5*abslen if UTM
  do.call(textField, owa(list(x=xl, y=y, labels=paste(abslen/f, label), field=field,
                              fill=fill, adj=adj, cex=cex, col=col[1]), targs))
  } else
if(type=="bar")
  {
  # label + subbar positions
  # number of divisions (substraction to break ties)     # 1   2   3    4    5    6
  if(is.null(ndiv)) ndiv <- which.min( (abslen/f)%%1:6 - c(0,0.2,0.3, 0.4, 0.5, 0.1) )
  xl <- x + seq(0,1, length.out=ndiv+1)*(end-x)
  col <- rep(col, length.out=ndiv)
  ytop <- y+strheight("m")*lwd/7
  # background:
  rect(  xleft=x-mar[2]*strwidth("m"),  xright=end +mar[4]*strwidth("m"),
       ybottom=y-mar[1]*strheight("m"),   ytop=ytop+mar[3]*strheight("m"),
       col=bg, border=NA)
  # actual bar segments
  for(i in seq_len(ndiv)) rect(xleft=xl[i],xright=xl[i+1], ybottom=y, ytop=ytop,
                               col=col[i], border=col[1], ...)
  # labels:
  labs <- round( seq(0,1, length.out=ndiv+1)*abslen/f, 2)
  #labs[ndiv+1] <- paste(labs[ndiv+1], label)
  do.call(textField, owa(list(x=xl, y=y, labels=labs, field=field,
                              fill=fill, adj=adj, cex=cex, col=col[1]), targs))
  do.call(textField, owa(list(x=end+strwidth("mm"), y=y, labels=label, field=field,
                              fill=fill, adj=adj, cex=cex, col=col[1]), targs))
  } else
stop("type ", type, " is not implemented. Please use 'bar' or 'line'.")
#
# return absolute coordinates
return(invisible(c(x=x, end=end, y=y, abslen_meter=abslen, label=xl)))
}
