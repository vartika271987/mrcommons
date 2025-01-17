#' @title readLUH2v2
#' @description read LUH inputs
#'
#' @param subtype switch between different inputs
#'
#' @return List of magpie objects with results on cellular level, weight, unit and description
#' @author Florian Humpenoeder, Stephen Wirth, Kristine Karstens, Felicitas Beier, Jan Philipp Dietrich
#'
#' @importFrom ncdf4 nc_open
#' @importFrom raster raster extent brick subset aggregate projectRaster extent<- as.matrix extract
#' @importFrom magclass as.magpie mbind
#' @importFrom stringr str_match str_count

readLUH2v2 <- function(subtype) {

  # basic settings
  timeSel   <- seq(1901, 2015, by = 1)
  offset     <- 849  # year 850=1, year 1900=1051, year 2015=1166
  # grep years to set other than default years, if subtypes ends with '_850to1901' like time span expression
  timeSpan <- str_match(subtype, "_(\\d+)to(\\d+)")[2:3]
  if (all(!is.na(timeSpan))) {
    timeSel  <- seq(timeSpan[1], timeSpan[2], by = 1)
    subtype   <- gsub("_(\\d+)to(\\d+)", "", subtype)
  }

  # File to process
  fStates <- "states.nc"
  fMan    <- "management.nc"
  fTrans  <- "transitions.nc"

  ### Define dimensions
  map      <- toolGetMappingCoord2Country(pretty = TRUE)

  if (grepl("states", subtype)) {

    # Open file and process information
    ncFile <- nc_open(fStates)
    data    <- setdiff(names(ncFile$var), c("secma", "secmb", "lat_bounds", "lon_bounds"))
    # Land area
    carea         <- raster("staticData_quarterdeg.nc", varname = "carea")
    extent(carea) <- c(-180, 180, -90, 90)

    x  <- NULL
    for (item in data) {
      shr <- subset(brick(fStates, varname = item), timeSel - offset)
      mag <- aggregate(shr * carea, fact = 2, fun = sum)
      mag <- as.magpie(extract(mag, map[c("lon", "lat")]), spatial = 1, temporal = 2)
      getNames(mag) <- item
      getCells(mag) <- paste(map$coords, map$iso, sep = ".")
      getYears(mag) <- timeSel
      getSets(mag)  <- c("x.y.iso", "t", "data")
      x <- mbind(x, mag)
    }

    # Convert from km^2 to Mha
    x <- x / 10000

  } else  if (grepl("transition", subtype)) {

    # Open file and process information
    ncFile <- nc_open(fTrans)
    luTrans <- setdiff(names(ncFile$var), c("secma", "secmb", "lat_bounds", "lon_bounds"))
    luTrans <- grep("to", luTrans, value = TRUE)
    luTrans <- luTrans[str_count(luTrans, "c[3/4]") == 1]
    fromCrop <- grep("^c", luTrans, value = TRUE)
    toCrop   <- setdiff(luTrans, fromCrop)

    # Land area
    carea         <- raster("staticData_quarterdeg.nc", varname = "carea")
    extent(carea) <- c(-180, 180, -90, 90)

    lucToCrop   <- new.magpie(fill = 0)
    lucFromCrop <- new.magpie(fill = 0)

    for (item in toCrop) {
      shr <- subset(brick(fTrans, varname = item), timeSel - offset - 1)
      mag <- aggregate(shr * carea, fact = 2, fun = sum)
      mag <- as.magpie(extract(mag, map[c("lon", "lat")]), spatial = 1, temporal = 2)
      getNames(mag) <- item
      getCells(mag) <- paste(map$coords, map$iso, sep = ".")
      getYears(mag) <- timeSel
      getSets(mag)  <- c("x.y.iso", "t", "data")
      lucToCrop     <- collapseNames(lucToCrop + mag)
    }

    for (item in fromCrop) {
      # This attributes LUC to the year resulting from it
      shr <- subset(brick(fTrans, varname = item), timeSel - offset - 1)
      mag <- aggregate(shr * carea, fact = 2, fun = sum)
      mag <- as.magpie(extract(mag, map[c("lon", "lat")]), spatial = 1, temporal = 2)
      getNames(mag) <- item
      getCells(mag) <- paste(map$coords, map$iso, sep = ".")
      getYears(mag) <- timeSel
      getSets(mag)  <- c("x.y.iso", "t", "data")
      lucFromCrop   <- collapseNames(lucFromCrop + mag)
    }

    x <- mbind(setNames(lucFromCrop, "from_crop"),
               setNames(lucToCrop,   "to_crop"))

    # Convert from km^2 to Mha
    x <- x / 10000

  } else if (grepl("irrigation", subtype)) {

    # Mapping between states and management_irrigation
    dataMan    <- c("irrig_c3ann", "irrig_c3per", "irrig_c4ann", "irrig_c4per", "irrig_c3nfx", "flood")
    dataStates <- c("c3ann", "c3per", "c4ann", "c4per", "c3nfx", "c3ann")
    data        <- matrix(data = c(dataMan, dataStates), ncol = 2)

    # Land area
    carea         <- raster("staticData_quarterdeg.nc", varname = "carea")
    extent(carea) <- c(-180, 180, -90, 90)

    x  <- NULL
    for (item in dataMan) {
      shr    <- subset(brick(fStates, varname = data[data[, 1] == item, 2]), timeSel - offset)
      irShr <- subset(brick(fMan,    varname = item), timeSel - offset)
      # grid cell fraction of crop area x grid cell area x irrigated fraction of crop area
      mag <- aggregate(shr * carea * irShr, fact = 2, fun = sum)
      mag <- as.magpie(extract(mag, map[c("lon", "lat")]), spatial = 1, temporal = 2)
      getNames(mag) <- item
      getYears(mag) <- timeSel
      getCells(mag) <- paste(map$coords, map$iso, sep = ".")
      getSets(mag)  <- c("x.y.iso", "t", "data")
      x <- mbind(x, mag)
    }

    # Convert from km^2 to Mha
    x <- x / 10000

  } else if (grepl("ccode", subtype)) {

    # Load raster data on 0.25° and extend to full grid
    ccode25         <- raster("staticData_quarterdeg.nc", varname = "ccode")
    extent(ccode25) <- c(-180, 180, -90, 90)

    # Create new raster object on 0.5° and re-project 0.25°-raster on 0.5°-raster
    r50     <- raster(res = 0.5)
    ccode50 <- projectRaster(ccode25, r50, over = TRUE, method = "ngb") # re-project to regular grid

    x <- as.magpie(extract(ccode50, map[c("lon", "lat")]), spatial = 1)
    getYears(x) <- 2000
    getNames(x) <- "ccode"
    getCells(x) <- paste(map$coords, map$iso, sep = ".")
    getSets(x)  <- c("x.y.iso", "t", "ccode")
  }

  return(clean_magpie(x))
}
