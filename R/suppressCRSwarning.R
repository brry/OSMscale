#' @title suppress CRS warnings
#' @description suppress CRS warnings
#' @return The original warning if it is not a CRS warning, otherwise NULL, invisibly
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jul 2020
#' @export
#' @examples
#' 
#' 
#' myfun1 <- function(x)
#'  {
#'  warning("Dude, this is a warning.")
#'  x
#'  }
#' myfun2 <- function(x)
#'  {
#'  warning("Discarded ellps WGS 84 in CRS definition")
#'  x
#'  }
#'    
#' k1 <-                    myfun1(11)  ; k1 # warning but works
#' k2 <- suppressCRSwarning(myfun1(22)) ; k2 # ditto
#' k3 <-                    myfun2(33)  ; k3 # ditto with fun2
#' k4 <- suppressCRSwarning(myfun2(44)) ; k4 # no warning
#'                    myfun1(  )  # error + warning
#' suppressCRSwarning(myfun1(  )) # error + empty warning
#' 
#' 
#' oop <- options(warn=2)
#'                    myfun1(55)  # warning to error
#' suppressCRSwarning(myfun1(66)) # ditto
#'                    myfun2(77)  # ditto
#' suppressCRSwarning(myfun2(88)) # works fine
#'                    myfun1(  )  # warning to error
#' suppressCRSwarning(myfun1(  )) # ditto
#' options(oop)
#' 
#'  
#' # checks
#' stopifnot(k2==22)
#' stopifnot(k4==44) 
#'
#' @param w \code{\link{warning}} output
#'
suppressCRSwarning <- function(expr) 
 {
 toignore <- c("Discarded ellps WGS 84 in CRS definition", 
               "Discarded datum WGS_1984 in CRS definition")
 withCallingHandlers(expr, warning=function(w)
 if(any(sapply(toignore, grepl, x=w$message))) invokeRestart("muffleWarning"))
 }


