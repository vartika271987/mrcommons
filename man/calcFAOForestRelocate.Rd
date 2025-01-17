% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcFAOForestRelocate.R
\name{calcFAOForestRelocate}
\alias{calcFAOForestRelocate}
\title{calcFAOForestRelocate}
\usage{
calcFAOForestRelocate(
  selectyears = "past",
  nclasses = "seven",
  cells = "magpiecell"
)
}
\arguments{
\item{selectyears}{default on "past"}

\item{nclasses}{options are either "six", "seven" or "nine".
\itemize{
\item "six" includes the original land use classes "crop", "past", "forestry", "forest", "urban" and "other"
\item "seven" separates primary and secondary forest and includes "crop", "past", "forestry", "primforest",
"secdforest", "urban" and "other"
\item "nine" adds the separation of pasture and rangelands, as well as a differentiation of primary and
secondary non-forest vegetation and therefore returns "crop", "past", "range", "forestry", "primforest",
"secdforest", "urban", "primother" and "secdother"
}}

\item{cells}{if cellular is TRUE: "magpiecell" for 59199 cells or "lpjcell" for 67420 cells}
}
\value{
List of magpie object with results on cellular level, weight on cellular level, unit and description.
}
\description{
Calculates the cellular MAgPIE forest and other land area correction based on FAO forestry data
and LUH2v2.
}
\examples{
\dontrun{
calcOutput("FAOForestRelocate")
}
}
\author{
Kristine Karstens, Felicitas Beier, Patrick v. Jeetze
}
