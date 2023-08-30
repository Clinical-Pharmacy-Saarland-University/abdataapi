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
  # check for missing parameter
  if (missing(pzns) || pzns == "") {
    ret <- api_error(
      res, 400, "PZNs parameter is required.",
      list(list(field = "pzns", issue = "This field is required and cannot be empty."))
    )
    return(ret)
  }

  # check if unique
  pzns <- unlist(strsplit(pzns, split = ",")) |> trimws()
  if (!is_unique(pzns)) {
    ret <- api_error(res, 400, "PZN numbers must be unique.")
    return(ret)
  }

  # check if pzns are valid
  pzns_ok <- map_lgl(pzns, validate_pzn)
  if (any(!pzns_ok)) {
    ret <- api_error(
      res,
      400, "Some provided PZNs are not valid.",
      list(invalid_pzns = pzns[which(!pzns_ok)])
    )
    return(ret)
  }

  ret <- api_pzn_interactions(pzns)

  # check for internal error
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  return(ret)
}


#* Interaction endpoint for PZN number input from JSON
#* @param .body The raw body content from the request
#* @post /pzn/interactions
function(req) {
  # Extract the body content from the request
  body <- req$postBody



  # Process the data as necessary
  # For this example, let's assume the JSON contains a name and age.
  # We'll just return a modified version of the data.
  list(
    message = paste("Hello,", data$name, "! You are", data$age, "years old.")
  )
}
