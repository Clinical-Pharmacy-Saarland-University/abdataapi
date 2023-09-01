# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: API entry point
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Packages ----
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
source("api/pzn_api.R")
source("api/atc_api.R")
source("api/misc_api.R")
source("api/api_filters.R")

options(future.globals.onReference = "error")
plan(multisession, workers = 10)

# Pool ----
# *******************************************************************
if (SETTINGS$sql$use_pool) {
  SETTINGS$sql$pool <- createPool(SETTINGS$sql)
}

on.exit(function() {
  if (exists("SETTINGS$sql$pool")) {
    closePool(SETTINGS$sql$pool)
  }
})
