% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calcVoPcrops.R
\name{calcVoPcrops}
\alias{calcVoPcrops}
\title{calcVoPcrops}
\usage{
calcVoPcrops(output = "absolute", fillGaps = FALSE)
}
\arguments{
\item{output}{defines if output should be given as an "absolute" value or
as a "fraction" of the overall value of production.}

\item{fillGaps}{boolean: should gaps be filled using production * prices (where production data is available)?}
}
\value{
magpie object. in mio. USD05 MER or fraction
}
\description{
Calculates the value of production of individual production items or
its fraction compared to overall Value of Production (Agriculture,Fish,Forestry).
}
\examples{
\dontrun{
a <- calcOutput("VoPcrops")
}

}
\seealso{
\code{\link[=calcOutput]{calcOutput()}}
}
\author{
Edna J. Molina Bacca, Debbora Leip
}
