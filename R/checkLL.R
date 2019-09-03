#' lat-long coordinate check
#' 
#' check lat-long coordinates for plausibility
#' 
#' @return Invisible T/F vector showing which of the coordinates is violated
#'         in the order: minlat, maxlat, minlong, maxlong.
#'         Only returned if check is passed or fun != stop
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016
#' @seealso \code{\link{pointsMap}}, \code{\link{putm}},
#'          \code{berryFunctions::\link[berryFunctions]{checkFile}}
#' @importFrom berryFunctions traceCall getColumn
#' @export
#' @examples
#' checkLL(lat=52, long=130)
#' checkLL(130, 52, fun=message)
#' checkLL(85:95, 0, fun=message)
#' 
#' d <- data.frame(x=0, y=0)
#' checkLL(y,x, d)
#' 
#' # informative errors:
#' library("berryFunctions")
#' is.error(   checkLL(85:95, 0, fun="message"),  tell=TRUE)
#' is.error(   checkLL(170,35),  tell=TRUE)
#' 
#' mustfail <- function(expr) stopifnot(berryFunctions::is.error(expr))
#' mustfail( checkLL(100)         )
#' mustfail( checkLL(100, 200)    )
#' mustfail( checkLL(-100, 200)   )
#' mustfail( checkLL(90.000001, 0)   )
#' 
#' @param lat,long Latitude (North/South) and longitude (East/West) coordinates in decimal degrees
#' @param data Optional: data.frame with the columns \code{lat} and \code{long}
#' @param fun One of the functions \code{\link{stop}}, \code{\link{warning}},
#'            or \code{\link{message}}. DEFAULT: stop
#' @param quiet    Logical: suppress non-df warning in \code{\link[berryFunctions]{getColumn}}? 
#'                 DEFAULT: FALSE
#' @param \dots Further arguments passed to \code{fun}
#' 
checkLL <- function(
lat,
long,
data,
fun=stop,
quiet=FALSE,
...
)
{
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data, quiet=quiet)
  long <- getColumn(substitute(long), data, quiet=quiet)
  }
if(is.character(fun)) stop("fun must be unquoted. Use fun=", fun, " instead of fun='", fun,"'.")
# tracing the calling function(s):
calltrace <- berryFunctions::traceCall()
# check coordinates:
minlat  <- min(lat, na.rm=TRUE)
maxlat  <- max(lat, na.rm=TRUE)
minlong <- min(long,na.rm=TRUE)
maxlong <- max(long,na.rm=TRUE)
error <- c(minlat < -90 , maxlat > 90, minlong < -180, maxlong > 180)
errortext <- paste0(rep(c("lat","long"),each=2), " values must be ",
                   rep(c("larger","lesser"),2), " than ", c(-90,90,-180,180),
                   ". Actual ", rep(c("min","max"),2), " is ",
                   c(minlat, maxlat, minlong, maxlong), ".")

# prepare message:
Text <- paste(errortext[error], collapse="\n")
if(max(abs(c(minlat, maxlat, minlong, maxlong))) < 180)
  Text <- paste(Text, "You may have swapped lat and long somewhere.", sep="\n")
Text <- paste(calltrace, Text)
# return message, if file nonexistent:
if(any(error)) fun(Text, ...)
return(invisible(error))
}
