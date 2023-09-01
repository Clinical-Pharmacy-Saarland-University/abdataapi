# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Starting Script for the API
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************
# authentication
add_auth <- function(x, paths = NULL) {
  # set authentication method for swagger UI/openapi
  x[["components"]] <- list(
    securitySchemes = list(
      ApiKeyAuth = list(
        type = "apiKey",
        `in` = "header",
        name = "TOKEN",
        description = "Authentication token provided to users that successfully logged in"
      )
    )
  )
  # add authentication requirement for all endpoints
  if (is.null(paths)) paths <- names(x$paths)
  for (path in paths) {
    nn <- names(x$paths[[path]])
    for (p in intersect(nn, c("get", "head", "post", "put", "delete"))) {
      x$paths[[path]][[p]] <- c(
        x$paths[[path]][[p]],
        list(security = list(list(ApiKeyAuth = vector())))
      )
    }
  }
  return(x)
}

router <- plumber::pr("api.R")
router <- router |>
  plumber::pr_set_api_spec(function(spec) {
    spec$info <- list(
      title = router$environment$SETTINGS$title,
      description = router$environment$SETTINGS$description,
      version = router$environment$SETTINGS$version
    )
    spec
  }) |>
  plumber::pr_set_api_spec(add_auth) |>
  plumber::pr_mount("/api", plumber::Plumber$new("endpoints.R"))

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
