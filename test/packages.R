# *******************************************************************
# Project: ABDATA API Client
# Script purpose: Package loader
# Date: 07-15-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

packages <- function() {
  c("jsonlite", "httr", "dplyr", "tictoc", "yaml", "glue")
}

init_packages <- function() {
  suppressPackageStartupMessages({
    lapply(packages(), library, character.only = TRUE)
  })
  invisible()
}
