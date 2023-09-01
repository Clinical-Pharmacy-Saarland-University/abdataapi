# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Starting Script for the API
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Libs and Options ----
# *******************************************************************
source("helper/loadHelper.R")
ensureLib("plumber")
ensureLib("dplyr")
ensureLib("purrr")
ensureLib("tidyr")
ensureLib("glue")
ensureLib("jsonlite")
ensureLib("jsonvalidate")
ensureLib("DBI")
ensureLib("RMySQL")
ensureLib("pool")
ensureLib("loggit")
ensureLib("promises")
ensureLib("future")
ensureLib("bcrypt")
ensureLib("jose")
ensureLib("mongolite")

source("settings.R")
source("helper/pool.R")
source("helper/helper.R")
source("helper/translators.R")
source("helper/validators.R")
source("helper/user_handling.R")
source("sql/sql.R")
source("api/api_filters.R")
source("api/pzn_api.R")
source("api/atc_api.R")
source("api/misc_api.R")

options(future.globals.onReference = "error")
if (SETTINGS$server$multisession) {
  plan(multisession, workers = SETTINGS$server$worker_threads)
} else {
  plan(sequential)
}

if (SETTINGS$sql$use_pool) {
  SETTINGS$sql$pool <- createPool(SETTINGS$sql, SETTINGS$server$multisession)
}

# Authentication ----
# *******************************************************************
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

# Plumb ----
# *******************************************************************
router <- plumber::pr()
router <- router |>
  plumber::pr_set_api_spec(function(spec) {
    spec$info <- list(
      title = SETTINGS$swagger$title,
      description = SETTINGS$swagger$description,
      version = SETTINGS$swagger$version
    )
    spec
  }) |>
  plumber::pr_set_api_spec(add_auth) |>
  plumber::pr_mount("/api", plumber::Plumber$new("endpoints.R"))

router |>
  pr_hook("exit", function() {
    closePool(SETTINGS$sql$pool)
  }) |>
  plumber::pr_run(
    host = SETTINGS$server$host,
    port = SETTINGS$server$port,
    debug = SETTINGS$debug_mode,
    docs = SETTINGS$swagger$docs,
    quiet = !SETTINGS$debug_mode
  )
