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
#' 9.19 45.73
#' 1.12 53.12
#' 6.55 58.13
#' 7.71 71.44
#' ")
#'
#' plot(d, asp=1, pch=as.character(1:4))
#' earthDist(y,x,d, i=2)
#' earthDist(y,x,d, i=3)
#'
#' maxEarthDist(y,x,d, each=FALSE)
#' maxEarthDist(y,x,d)
#' maxEarthDist(y,x,d, fun=min)
#'
#' @param lat,long,data Coordinates for \code{\link{earthDist}}
#' @param r     Earth Radius for \code{\link{earthDist}}
#' @param fun   Function to be applied. DEFAULT: \code{\link{max}}
#' @param each  Logical: give max dist to all other points for each point?
#'              If FALSE, will return the maximum of the complete distance matrix.
#'              DEFAULT: TRUE
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
apply(d, 2, fun, ...)
}




