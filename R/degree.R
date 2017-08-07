#' decimal degree coordinate conversion
#' 
#' Convert latitude-longitude coordinates
#' between decimal representation and degree-minute-second notation
#' 
#' @return data.frame with x and y as character strings or numerical values,
#'         depending on conversion direction
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Aug 2016
#' @seealso \code{\link{earthDist}}, \code{\link{projectPoints}} for geographical reprojection,
#'          \code{sp::\link[sp]{char2dms}}
#' @keywords spatial character
#' @importFrom berryFunctions l2df getColumn
#' @export
#' @examples
#' # DECIMAL to DMS notation: --------------------------------------------------
#' degree(52.366360, 13.024181)
#' degree(c(52.366360, -32.599203), c(13.024181,-55.809601))
#' degree(52.366360, 13.024181, drop=TRUE) # vector
#' degree(47.001, -13.325731, digits=5)
#' 
#' # Use table with values instead of single vectors:
#' d <- read.table(header=TRUE, sep=",", text="
#' lat, long
#'  52.366360,  13.024181
#' -32.599203, -55.809601")
#' degree(lat, long, data=d)
#' 
#' # DMS to DECIMAL notation: --------------------------------------------------
#' # You can use the degree symbol and escaped quotation mark (\") as well.
#' degree("52'21'58.9'N", "13'1'27.1'E")
#' print(degree("52'21'58.9'N", "13'1'27.1'E"), digits=15)
#' 
#' d2 <- read.table(header=TRUE, stringsAsFactors=FALSE, text="
#' lat long
#' 52'21'58.9'N 13'01'27.1'E
#' 32'35'57.1'S 55'48'34.6'W") # columns cannot be comma-separated!
#' degree(lat, long, data=d2)
#' 
#' # Rounding error checks: ----------------------------------------------------
#' oo <- options(digits=15)
#' d
#' degree(lat, long, data=degree(lat, long, d))
#' degree(lat, long, data=degree(lat, long, d, digits=3))
#' options(oo)
#' stopifnot(all(degree(lat,long,data=degree(lat,long,d, digits=3))==d))
#' 
#' @param lat,long Latitude (North/South) and longitude (East/West) coordinates in decimal degrees
#' @param data Optional: data.frame with the columns \code{lat} and \code{long}
#' @param todms Logical specifying direction of conversion.
#'              If FALSE, converts to decimal degree notation, splitting coordinates
#'              at the symbols for degree, minute and second (\\U00B0, ', ").
#'              DEFAULT: !is.character(lat)
#' @param digits Number of digits the seconds are \code{\link{round}ed} to. DEFAULT: 1
#' @param drop Drop to lowest dimension? DEFAULT: FALSE
#' 
degree <- function(
lat,
long,
data,
todms=!is.character(lat),
digits=1,
drop=FALSE
)
{
# Input coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data)
  long <- getColumn(substitute(long), data)
  }
# decimal to DMS
if(todms)
{
checkLL(lat, long, fun=warning)
dec2deg <- function(dec)
  {
  d <- floor(dec)
  decm <- (dec-d)*60
  m <- floor(decm)
  s <- round((decm-m)*60, digits=digits)
  s <- ifelse(s<10, paste0(0,as.character(s)), s)
  paste0(d,"\U00B0",formatC(m, width=2, flag="0"),"'",s,"\"")
  }
x <- dec2deg(abs(long))
x <- paste0(x,ifelse(long>0, "E", "W"))
y <- dec2deg(abs(lat))
y <- paste0(y,ifelse(lat>0, "N", "S"))
out <- data.frame(lat=y,long=x, stringsAsFactors=FALSE)
if(drop) out <- drop(as.matrix(out))
return(out)
}
else # DMS to decimal
# https://stackoverflow.com/questions/14404596/converting-geo-coordinates-from-degree-to-decimal
{
x <- berryFunctions::l2df(strsplit(long, "[\U00B0'\"]+", perl=TRUE))
y <- berryFunctions::l2df(strsplit(lat , "[\U00B0'\"]+", perl=TRUE))
x2 <- as.numeric(x[,1]) + as.numeric(x[,2])/60 + as.numeric(x[,3])/3600
y2 <- as.numeric(y[,1]) + as.numeric(y[,2])/60 + as.numeric(y[,3])/3600
x2 <- x2*ifelse(toupper(x[,4])=="W", -1, 1)
y2 <- y2*ifelse(toupper(y[,4])=="S", -1, 1)
checkLL(y2, x2, fun=warning)
if(missing(digits)) digits <- 6
out <- data.frame(lat=round(y2,digits), long=round(x2, digits) )
if(drop) out <- drop(as.matrix(out))
return(out)
}
}
