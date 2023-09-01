# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Starting Script for the API
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

router <- plumber::pr("api.R")
router <- router |>
  plumber::pr_set_api_spec(function(spec) {
    spec$info <- list(
      title = router$environment$SETTINGS$title,
      description = router$environment$SETTINGS$description,
      version = router$environment$SETTINGS$version
    )
    spec
  })

router |>
  pr_hook("exit", function() {
    closePool(router$environment$SETTINGS$sql$pool)
  }) |>
  plumber::pr_run(
    host = SETTINGS$server$host,
    port = SETTINGS$server$port,
    debug = SETTINGS$debug_mode,
    docs = SETTINGS$docs,
    quiet = !SETTINGS$debug_mode
  )
