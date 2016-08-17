#' lat-long coordinate check
#'
#' check lat-long coordinates for plausibility
#'
#' @return Nothing. Used to stop a function.
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016
#' @seealso \code{\link{pointsMap}}, \code{\link{putm}},
#'          \code{berryFunctions::\link[berryFunctions]{checkFile}}
#' @importFrom utils capture.output
#' @export
#' @examples
#' checkLL(lat=52, long=130)
#' checkLL(130, 52, fun=message)
#' checkLL(85:95, fun=message)
#'
#' \dontrun{
#' checkLL(,200) # throws an informative error
#' checkLL(85:95, trace=FALSE)
#' checkLL(,100:200) # can handle vectors
#' }
#' mustfail <- function(expr) stopifnot(berryFunctions::is.error(expr))
#' mustfail( checkLL(100)         )
#' mustfail( checkLL(100, 200)    )
#' mustfail( checkLL(-100, 200)   )
#' mustfail( checkLL(90.000001)   )
#'
#' @param lat,long lat or long values. DEFAULT: NA
#' @param fun One of the functions \code{\link{stop}}, \code{\link{warning}}, or \code{\link{message}}. DEFAULT: stop
#' @param trace Logical: Add function call stack to the message? DEFAULT: TRUE
#' @param \dots Further arguments passed to \code{fun}
#'
checkLL <- function(
lat=0,
long=0,
fun=stop,
trace=TRUE,
...
)
{
# tracing the calling function(s):
if(trace)
{
  dummy <- capture.output(tb <- traceback(6) )
  tb <- lapply(tb, "[", 1) # function(x) if(length(x)>1) c(x[1]," ...TRUNCATED by checkLL!") else x)
  tb <- lapply(tb, function(x) if(substr(x,1,7)=="do.call")
               sub(",", "(", sub("(", " - ", x, fixed=TRUE), fixed=TRUE) else x)
  calltrace <- sapply(strsplit(unlist(tb), "(", fixed=TRUE), "[", 1)
  calltrace <- paste(rev(calltrace[-1]), collapse=" -> ")
}
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
Text <- paste(c(errortext[error], "You may have swapped lat and long somewhere."), collapse="\n")
if(trace) Text <- paste(calltrace, Text, sep="\n")
# return message, if file nonexistent:
if(any(error)) fun(Text, ...)
return(invisible(error))
}
