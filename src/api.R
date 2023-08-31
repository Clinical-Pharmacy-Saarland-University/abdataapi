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
ensureLib("jsonlite")
ensureLib("jsonvalidate")
ensureLib("DBI")
ensureLib("RMySQL")
ensureLib("pool")

source("settings.R")
source("helper/pool.R")
source("helper/helper.R")
source("helper/translators.R")
source("helper/validators.R")
source("sql/sql.R")
source("api/pzn_api.R")

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

# Endpoints ----
# *******************************************************************

#* Interaction endpoint for PZN number input
#* @param pzns:[string] Comma-separated unique PZN-Numbers as strings
#* @get /pzn/interactions
function(pzns, res) {
  api_pzn_interactions_get(pzns, res)
}


#* Interaction endpoint for PZN number input from JSON
#* @param .body The raw body content from the request
#* @post /pzn/interactions
function(req, res) {
  api_pzn_interactions_post(req, res)
}
