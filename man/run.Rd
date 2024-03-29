% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run.R
\name{run}
\alias{run}
\title{Run conversion}
\usage{
run(videos, exclude_done = TRUE)
}
\arguments{
\item{videos}{(chr) paths to videos}
}
\value{
a list with one element per video. Each element has two
fields: "result", which stores the output wav's path or \code{NULL} if
some error occurred, and "error", which stores the possible error
message the process for the corresponding video returned an error,
or \code{NULL} otherwise
}
\description{
Run conversion
}
\examples{
\dontrun{
  with_progress({
    res <- run(videos[1:5])
  }, delay_terminal = FALSE)
}


}
\keyword{internal}
