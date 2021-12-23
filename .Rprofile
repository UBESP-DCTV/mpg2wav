source("renv/activate.R")


if (interactive()) {
  suppressPackageStartupMessages(suppressWarnings({
    library(devtools)
    library(lintr)
    library(spelling)
    library(testthat)
    library(usethis)
  }))
}


options(
  # Add warns for partial matching -------------------------------------

  warnPartialMatchDollar = TRUE,
  warnPartialMatchArgs   = TRUE,
  warnPartialMatchAttr   = TRUE,

  # Package repositories
  repos = c(
    RSPM = "https://packagemanager.rstudio.com/all/latest",
    CRAN = "https://cloud.r-project.org/"
  )

)
