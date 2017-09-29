#' maximum distance between set of points
#' 
#' Maximum great-circle distance between points at lat-long coordinates.
#' This is not computationally efficient.
#' For large datasets, consider pages like \url{http://stackoverflow.com/a/16870359}.
#' 
#' @return Single number
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jan 2017
#' @seealso \code{\link{earthDist}}
#' @keywords spatial
#' @export
#' @examples
#' 
#' d <- read.table(header=TRUE, text="
#'     x     y
#' 14.9 53.73
#' 1.12 53.12
#' 6.55 58.13
#' 7.71 71.44
#' ")
#' 
#' plot(d, asp=1, pch=as.character(1:4), xlab="lon", ylab="lat")
#' for(i in 1:4) segments(d$x[-i], d$y[-i], d$x[i], d$y[i], col=2)
#' text(x=c(7,10,11), y=c(53,56,64), round(earthDist(y,x,d    )[-1]),  col=2)
#' text(x=c(4,4),     y=c(56,61),    round(earthDist(y,x,d,i=2)[3:4]), col=2)
#' text(x=7,          y=64,          round(earthDist(y,x,d,i=4)[3]),   col=2)
#' 
#' round(  earthDist(y,x,d, i=2)   )
#' round(  earthDist(y,x,d, i=3)   )
#' 
#' round(  maxEarthDist(y,x,d)              )
#' round(  maxEarthDist(y,x,d, each=FALSE)  )
#' round(  maxEarthDist(y,x,d, fun=min)     )
#' 
#' maxEarthDist(y,x, d[1:2,] )
#' 
#' @param lat,long,data Coordinates for \code{\link{earthDist}}
#' @param r     Earth Radius for \code{\link{earthDist}}
#' @param fun   Function to be applied. DEFAULT: \code{\link{max}}
#' @param each  Logical: give max dist to all other points for each point separately?
#'              If FALSE, will return the maximum of the complete distance matrix,
#'              as if \code{max(maxEarthDist(y,x))}. DEFAULT: TRUE
#' @param \dots Further arguments passed to fun, like na.rm=TRUE
#' 
maxEarthDist <- function(
lat,
long,
data,
r=6371,
fun=max,
each=TRUE,
...
)
{
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data)
  long <- getColumn(substitute(long), data)
  }
d <- sapply(seq_along(lat), function(i) earthDist(lat,long,r=r,i=i)[-i] )
if(!each) return(  fun(d, ...)  )   # d[upper.tri(d)]

if(NCOL(d)==1) return(unlist(d)) # if only one or two points are compared
apply(d, 2, fun, ...)
}




