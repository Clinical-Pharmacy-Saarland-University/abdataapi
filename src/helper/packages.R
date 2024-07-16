# *******************************************************************
# Project: ABDATA API
# Script purpose: Package loader
# Date: 07-15-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

packages <- function() {
  package_names <- c(
    "plumber",
    "dplyr",
    "purrr",
    "tidyr",
    "stringr",
    "glue",
    "jsonlite",
    "jsonvalidate",
    "DBI",
    "RMySQL",
    "pool",
    "promises",
    "mirai",
    "bcrypt",
    "jose",
    "mongolite",
    "httpproblems"
  )
  return(package_names)
}

init_packages <- function() {
  suppressPackageStartupMessages({
    lapply(packages(), library,
      character.only = TRUE, warn.conflicts = FALSE,
      verbose = FALSE, quietly = TRUE
    )
  })
  invisible()
}
