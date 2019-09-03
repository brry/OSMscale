#' @title Compare map tiles
#' @description Compare map tiles
#' @return List of maps, writes to a pdf
#' @author Berry Boessenkool, \email{berry-b@@gmx.de}, Jul 2017
#' @seealso \code{\link{pointsMap}}
#' @keywords spatial
#' @importFrom berryFunctions newFilename owa getColumn
#' @importFrom pbapply pblapply
#' @importFrom grDevices pdf dev.off
#' @importFrom graphics title
#' @export
#' @examples
#' \dontrun{ # Exclude from CRAN checks because of download time
#' maps <- mapComp(c(52.39,52.46), c(12.99,13.06),
#'                 pargs=list(width=8.27, height=11.96), overwrite=TRUE)
#' 
#' # still need to suppress output to console:
#' https://stackoverflow.com/questions/45041762/suppress-rjava-error-output-in-console
#' 
#' unlink("mapComp.pdf")
#' }
#' 
#' @param lat,long,data Coordinates as in \code{\link{pointsMap}}
#' @param types    Character string vector, types for
#'                 \code{OpenStreetMap::\link[OpenStreetMap]{openmap}}
#'                 DEFAULT: NA (all current types)
#' @param progress Display progress bar? DEFAULT: TRUE
#' @param file     PDF filename. Will not be overwritten. DEFAULT: "mapComp.pdf"
#' @param overwrite Overwrite pdf file? DEFAULT: FALSE
#' @param pargs    List of arguments passed to \code{\link{pdf}}. DEFAULT:NULL
#' @param quiet    Logical: suppress non-df warning in \code{\link[berryFunctions]{getColumn}}? 
#'                 DEFAULT: FALSE
#' @param \dots    Further arguments passed to \code{\link{pointsMap}}
#' 
mapComp <- function(
lat,
long,
data,
types=NA,
progress=TRUE,
file="mapComp.pdf",
overwrite=FALSE,
pargs=NULL,
quiet=FALSE,
...
)
{
# select types:
if(all(is.na(types))) types <- c("osm", "osm-bw", "maptoolkit-topo", "waze",
                                 "bing", "stamen-toner", "stamen-terrain",
  "stamen-watercolor", "osm-german", "osm-wanderreitkarte", "mapbox", "esri",
  "esri-topo", "nps", "apple-iphoto", "skobbler", "hillshade", "opencyclemap",
  "osm-transport", "osm-public-transport", "osm-bbike", "osm-bbike-german")

# coordinates:
if(!missing(data)) # get lat and long from data.frame
  {
  lat  <- getColumn(substitute(lat) , data, quiet=quiet)
  long <- getColumn(substitute(long), data, quiet=quiet)
  }
checkLL(lat, long)

# Display progress bar?
if(progress) lapply <- pbapply::pblapply
if(!overwrite) file <- newFilename(file)
# open and close pdf device:
do.call(pdf, owa(list(file=file), pargs))
on.exit(dev.off())
# actually do the work:
pmtype <- function(ty)
  {
  pmap <- try(pointsMap(lat=lat, long=long, type=ty, quiet=TRUE, ...), silent=TRUE)
  if(!inherits(pmap, "try-error")) title(main=ty, line=-1)
  pmap
  }
out <- lapply(types, pmtype)
# check output:
names(out) <- types
errors <- sapply(out, inherits, "try-error")
if(any(errors)) message("The following ",sum(errors)," types failed to download: ",
                        toString(types[errors]))
# return output:
return(invisible(out))
}
