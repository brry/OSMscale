#' scalebar for OSM plots
#'
#' Add a scalebar to default or (UTM)-projected OpenStreetMap plots
#'
#' @details This uses a hack to get the right distance in the default mercator projected maps.
#' There, the axes are not in meters, but rather ca 0.7m units (for NW Germany area maps with 20km across).
#' Accordingly, other packages plot wrong bars:\cr
#' SDMTools::Scalebar(x=1442638,y=6893871,distance=10000)\cr
#' raster::scalebar(d=5000, xy=c(1442638,6893871))\cr
#' mapmisc::scaleBar(map$tiles[[1]]$projection, seg.len=10, pos="center", bg="transparent")\cr
#' I suppose this function works for other projections as well, but haven't tried yet.
#' You might need to specify abslen manually with other projections where the axes do not resemble meters at all.
#'
#' @return invisible: coordinates of scalebar and label
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jun 2016
#' @seealso \code{\link{pointsMap}}, \code{\link{projectPoints}}
#' @keywords aplot spatial
#' @importFrom graphics par rect segments strheight strwidth
#' @importFrom utils flush.console tail
#' @importFrom berryFunctions distance owa textField
#' @importFrom OpenStreetMap openmap openproj
#' @export
#' @examples
#' if(interactive()){
#' d <- data.frame(long=c(12.95, 12.98, 13.22, 13.11), lat=c(52.40,52.52, 52.36, 52.45))
#' map <- pointsMap(lat,long,d, scale=FALSE, zoom=9)
#' coord <- scaleBar(map)  ; coord
#' scaleBar(map, bg=berryFunctions::addAlpha("white", 0.7))
#' scaleBar(map, 0.3, 0.05, unit="m", length=0.45, type="line")
#' scaleBar(map, 0.3, 0.5, unit="km", abslen=5, col=4:5, lwd=3)
#' scaleBar(map, 0.3, 0.8, unit="mi", col="red", targ=list(col="blue", font=2), type="line")
#'
#' # I don't like subdivisions, but if you wanted them, you could use:
#' scaleBar(map, 0.12, 0.28, abslen=10, adj=c(0.5, -1.5)  )
#' scaleBar(map, 0.12, 0.28, abslen=4, adj=c(0.5, -1.5), targs=list(col="transparent"), label="" )
#' }
#'
#' \dontrun{ ## Too much downloading time, too error-prone
#' # Tests around the world
#' par(mfrow=c(1,2), mar=rep(1,4))
#' long <- runif(2, -180, 180) ;  lat <- runif(2, -90, 90)
#' map <- pointsMap(lat, long)
#' map2 <- pointsMap(lat, long, map=map, utm=TRUE)
#' }
#'
#' @param map Map object with map$tiles[[1]]$projection to get the projection from.
#' @param x,y Relative position of left end of scalebar. DEFAULT: 0.1, 0.9
#' @param length Approximate relative length of bar. DEFAULT: 0.2
#' @param abslen Absolute length in \code{unit}s. DEFAULT: NA (computed internally from \code{length})
#' @param unit Unit for computation and label.
#'             Possible are kilometer and meter as well as miles, feet and yards.
#'             Note that the returned absolute length is in m. DEFAULT: "km"
#' @param label Unit label in plot. DEFAULT: \code{unit}
#' @param type Scalebar type: simple \code{'line'} or classical black & white \code{'bar'}. DEFAULT: "bar"
#' @param ndiv Number of divisions if \code{type="bar"}. DEFAULT: NA (computed internally)
#'             Internal selection of \code{ndiv} is based on divisibility of abslen
#'             (modulo) with 1:6. For ties, preferation order is 5>4>3>2>6>1.
#'             For maps with abslen=4000, this means 5 will be chosen,
#'             even though 4 is more appealing. if \code{abslen} is also missing
#'             (or in a certain set), a better default is chosen.
#' @param field,fill,adj,cex Arguments passed to \code{\link[berryFunctions]{textField}}
#' @param col Vector of (possibly alternating) colors passed to
#'            \code{\link{segments}} or \code{\link{rect}}. DEFAULT: c("black","white")
#' @param targs List of further arguments passed to \code{\link[berryFunctions]{textField}}
#'                 like font, col (to differ from bar color), etc. DEFAULT: NULL
#' @param lwd,lend Line width and end style passed to \code{\link{segments}}.
#'                 DEFAULT: 5,1, which works well in pdf graphics.
#' @param bg Background color, e.g. \code{\link[berryFunctions]{addAlpha}(White)}.
#'           DEFAULT: \code{"transparent"} to suppress background.
#' @param mar Background margins approximately in letter width/height. DEFAULT: c(2,0.7,0.2,3)
#' @param \dots Further arguments passed to \code{\link{segments}} like lty.
#'              (Color for segments is the first value of \code{col}).
#'              Passed to \code{\link{rect}} if \code{type="bar"}, like lwd.
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
ndiv=NA,
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
# input checks and processing --------------------------------------------------
x <- x[1]; y <- y[1]
if(x<0) stop("x must be larger than 0, not ", x)
if(y<0) stop("y must be larger than 0, not ", y)
if(x>1) stop("x must be lesser than 1, not ", x)
if(y>1) stop("y must be lesser than 1, not ", y)
# map projection:
crs <- map$tiles[[1]]$projection
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
# Compute bar location ---------------------------------------------------------
# coordinate range:
### r <- par("usr") # makes length dependent on graphics window aspect ratio
r <- c(map$bbox$p1[1], map$bbox$p2[1], map$bbox$p2[2], map$bbox$p1[2])
# absolute usr (plot axis) locations of bars
x1 <- r[1] +      x*diff(r[1:2]) # starting point of scale bar
x2 <-   x1 + length*diff(r[1:2]) # APPROXIMATE (=desired) end point
y <- r[3]+y*diff(r[3:4])
#
#
# determine pretty absolute length of scale bar
# choice of length and ndiv possibilities for default automatic selection
xy_ll <- projectPoints(rep(y,2), c(x1,x2), to=pll(), from=crs)
xy_d <- earthDist(xy_ll$y, xy_ll$x, trace=FALSE)*1000/f # in units
cl <- c( 1,2,3,4,5,6,8,  c(10,15,20,25,30,40,50,60,80,100)*10^(floor(log10(xy_d))-1)  )
cn <- c( 1,2,3,4,5,6,4,     5, 3, 4, 5, 6, 4, 5, 3, 4,  5)
if(is.na(abslen))
  {
  csel <- which.min(abs(xy_d-cl)) # which/match is important to select first occurence
  abslen <- cl[csel]
  if(is.na(ndiv)) ndiv <- cn[csel]
  ## algorithm try that didn't work:
  ## p <- pretty(xy_d, n=5, high=0.3, u5=3)
  ## p[which.min(abs(xy_d-p))]
}
if(is.na(ndiv)) if(abslen %in% cl) ndiv <- cn[match(abslen,cl)]
# number of divisions (substraction to break ties) 1    2    3    4    5    6
if(is.na(ndiv)) ndiv <- which.min( abslen%%1:6 - c(0, 0.2, 0.3, 0.4, 0.5, 0.1) )
#
#
# DEFINITE end point:
x2 <- x1 + abslen*f # works for UTM with axis in m, but not for e.g. mercator projection
# Solution: many points along the graph, select the one closest to x1+abslen
if(substr(crs, 7, 9) != "utm")
  {
  xy_x <- seq(x1, 1.5*r[2], len=15000)
  xy_ll <- projectPoints(rep(y,15000), xy_x, to=pll(), from=crs)
  xy_d <- earthDist(xy_ll$y, xy_ll$x, trace=FALSE)*1000/f # in units
  x2 <- xy_x[which.min(abs(xy_d-abslen))]
  }
#
# draw scalebar ----------------------------------------------------------------
type <- type[1]
# background:
y2 <- y
if(type=="bar") y2 <- y+strheight("m")*lwd/7
if(type=="line" & missing(mar)) mar[c(2,4)] <- 0.2
# actually draw it:
rect(  xleft=x1-mar[2]*strwidth("m"), xright=x2+mar[4]*strwidth("m"),
     ybottom= y-mar[1]*strheight("m"),  ytop=y2+mar[3]*strheight("m"),
       col=bg, border=NA)
# bar type dependent actual drawing:
if(type=="line")
  {
  # draw line segment:
  segments(x0=x1, x1=x2, y0=y, lwd=lwd, lend=lend, col=col[1], ...)
  # label scale bar:
  xl <- mean(c(x1,x2)) # ==x1+0.5*abslen*f if UTM
  do.call(textField, owa(list(x=xl, y=y, labels=paste(abslen, label), field=field,
                              fill=fill, adj=adj, cex=cex, col=col[1], quiet=TRUE), targs))
  } else
if(type=="bar")
  {
  # label + bar part positions. ndiv has been set above, if it was NA.
  xl <- x1 + seq(0,1,length.out=ndiv+1)*(x2-x1)
  col <- rep(col, length.out=ndiv)
  # actual bar segments
  for(i in seq_len(ndiv)) rect(xleft=xl[i],xright=xl[i+1], ybottom=y, ytop=y2,
                               col=col[i], border=col[1], ...)
  # labels:
  labs <- round( seq(0,1,length.out=ndiv+1)*abslen, 2)
  do.call(textField, owa(list(x=xl, y=y, labels=labs, field=field,
                              fill=fill, adj=adj, cex=cex, col=col[1], quiet=TRUE), targs))
  do.call(textField, owa(list(x=x2+mean(strwidth(c(tail(labs,1), "mm"))), y=y,
                              labels=label, field=field,
                              fill=fill, adj=adj, cex=cex, col=col[1], quiet=TRUE), targs))
  } else
stop("type ", type, " is not implemented. Please use 'bar' or 'line'.")
#
# return absolute coordinates
return(invisible(c(x1=x1, x2=x2, y=y, abslen=abslen, label=xl))) # , unit=unit
}
