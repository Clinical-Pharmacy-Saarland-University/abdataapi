# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Starting Script for the API
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

source("settings.R")

router <- plumber::pr("api.R") |>
  plumber::pr_set_api_spec(function(spec) {
    spec$info <- list(
      title = SETTINGS$title,
      description = SETTINGS$description,
      version = SETTINGS$version
    )
    spec
  })

plumber::pr_run(router,
  host = SETTINGS$server$host,
  port = SETTINGS$server$port,
  debug = SETTINGS$debug_mode,
  docs = SETTINGS$docs,
  quiet = !SETTINGS$debug_mode
)
