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
#' 6.55 58.13
#' 7.71 71.44")
#'
#' plot(d, asp=1, pch=as.character(1:3))
#' earthDist(y,x,d, i=2)
#' earthDist(y,x,d, i=3)
#'
#' maxEarthDist(y,x,d)
#'
#' @param lat,long,data Coordinates for \code{\link{earthDist}}
#' @param r,trace radius and tracing option for \code{\link{earthDist}}
#'
maxEarthDist <- function(
lat,
long,
data,
r=6371,
trace=FALSE
)
{
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data, trace=trace)
  long <- getColumn(substitute(long), data, trace=trace)
  }
d <- sapply(seq_along(lat), function(i) earthDist(lat,long,r=r,i=i,trace=trace) )
max(d, na.rm=TRUE)
}




