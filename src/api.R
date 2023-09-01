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

source("settings.R")
source("helper/pool.R")
source("helper/helper.R")
source("helper/translators.R")
source("helper/validators.R")
source("sql/sql.R")
source("api/pzn_api.R")
source("api/atc_api.R")
source("api/misc_api.R")

options(future.globals.onReference = "error")
plan(multisession, workers = 10)

# Pool ----
# *******************************************************************
if (SETTINGS$sql$use_pool) {
  SETTINGS$sql$pool <- createPool(SETTINGS$sql)
}

# Endpoints Misc ----
# *******************************************************************

#* Formulation list with descriptions
#* @get /formulations
function(short = "", res) {
  api_formulation_list_get(res)
}

# Endpoints PZN ----
# *******************************************************************

#* ATC endpoint for PZN number input
#* @param pzns:[string] Comma-separated unique PZN-Numbers as strings
#* @get /pzn/atc
function(pzns, res) {
  future_promise({
    api_pzn_atc_get(pzns, res)
  })
}


#* Interaction endpoint for PZN number input
#* @param pzns:[string] Comma-separated unique PZN-Numbers as strings
#* @get /pzn/interactions
function(pzns, res) {
  future_promise({
    api_pzn_interactions_get(pzns, res)
  })
}

#* Interaction endpoint for PZN number input from JSON
#* @param .body The raw body content from the request
#* @post /pzn/interactions
function(req, res) {
  body <- req$postBody
  future_promise({
    api_pzn_interactions_post(body, res)
  })
}


# Endpoints ATC ----
# *******************************************************************
#* Naming endpoint for ATC input
#* @param atcs:[string] Comma-separated unique ATCs as strings
#* @get /atc/names
function(atcs, res) {
  api_atc_names_get(atcs, res)
}



##################### TO DO ####################################################

#* Interaction endpoint for ATC input
#* @param atcs:[string] Comma-separated unique ATCs as strings
#* @get /atc/interactions
function(atcs, res) {
  api_atc_interactions_get(atcs, res)
}
