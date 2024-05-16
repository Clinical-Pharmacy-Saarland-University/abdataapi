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
ensureLib("stringr")
ensureLib("glue")
ensureLib("jsonlite")
ensureLib("jsonvalidate")
ensureLib("DBI")
ensureLib("RMySQL")
ensureLib("pool")
ensureLib("promises")
ensureLib("future")
ensureLib("bcrypt")
ensureLib("jose")
ensureLib("mongolite")
ensureLib("httpproblems")

source("helper/schemas.R")
source("settings.R")
source("helper/pool.R")
source("helper/helper.R")
source("db/sql_helper.R")
source("db/sql.R")
source("db/mongo.R")
source("helper/logger.R")
source("helper/translators.R")
source("helper/validators.R")
source("helper/user_handling.R")
source("api/api_filters.R")
source("api/pzn_api.R")
source("api/atc_api.R")
source("api/misc_api.R")
source("api/interaction_api.R")
source("api/priscus_api.R")
source("setup/swagger.R")
source("setup/handlers.R")

options(future.globals.onReference = "error")
options(future.rng.onMisuse = "ignore")

if (SETTINGS$server$multisession) {
  plan(multisession, workers = SETTINGS$server$worker_threads)
} else {
  plan(sequential)
}

if (SETTINGS$sql$use_pool) {
  SETTINGS$sql$pool <- createPool(SETTINGS$sql, SETTINGS$server$multisession)
}

# Plumb ----
# *******************************************************************
endpoints <- Plumber$new("api/endpoints.R") |>
  pr_set_error(api_error_handler)

router <- pr() |>
  pr_set_api_spec(api_spec) |>
  pr_mount("/api", endpoints) |>
  pr_static("/", "./www") |>
  pr_hook("exit", function() {
    closePool(SETTINGS$sql$pool)
  })

# Run ----
# *******************************************************************
pr_run(router,
  host = SETTINGS$server$host,
  port = SETTINGS$server$port,
  debug = SETTINGS$debug_mode,
  docs = SWAGGER_SETTINGS$docs,
  quiet = !SETTINGS$debug_mode
)
