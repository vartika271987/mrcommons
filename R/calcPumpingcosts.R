#' @title calcPumpingcosts
#' @description provides costs of pumping irrigation water
#' @cells Only works for magpiecells currently
#' @irrigation Only works when irrigation = FALSE
#' @return A magpie object for all magpiecells for all years with information on pumping costs
#' @author Vartika Singh
#' @examples
#' 
#' \dontrun{ 
#' calcOutput("Pumpingcosts")
#' }
#' 
  
  calcPumpingcosts <- function(cells = "magpiecell", irrigation = FALSE) {
  
    LUHcroparea       <- toolCell2isoCell(calcOutput("LUH2v2", landuse_types = "LUH2v2",
                                                     cells = cells, aggregate = FALSE, irrigation = irrigation,
                                                     cellular = TRUE, selectyears = "past"),
                                          cells = cells)
    
    pumpingcost <- new.magpie(cells_and_regions = getCells(LUHcroparea),
                           years = getYears(LUHcroparea),
                           names = "pumpingcost", fill = 2000)
  
  return(list(x            = pumpingcost,
              weight       = NULL,
              unit         = "USD per million cubic meters",
              description  = "costs of pumping irrigation water from Cornish et.al., 2014"))
  
  }