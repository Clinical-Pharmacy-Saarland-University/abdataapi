#  Logger ----
# *******************************************************************
LOGGER <- create_logger(SETTINGS$logging$log_device)

# Endpoint Filters ----
# *******************************************************************
#* @filter authenticated
function(req, res) {
  filter_valid_token(req, token_salt = SETTINGS$token$token_salt, debugging = SETTINGS$debug_mode)
}

# Endpoints User Handling ----
# *******************************************************************

#* Endpoint to log a user in
#* @tag user
#* @preempt authenticated
#* @serializer unboxedJSON list(na = NULL)
#* @param credentials:object
#* @post /login
function(req, res, credentials = list(username = "username", password = "password")) {
  username <- catch_error(req$body$credentials$username)$result
  password <- catch_error(req$body$credentials$password)$result

  user_login(username, password,
    token_salt = SETTINGS$token$token_salt,
    time = SETTINGS$token$token_exp
  )
}

#* Endpoint to log a user in
#* @tag user
#* @serializer unboxedJSON list(na = NULL)
#* @get /renew-token
function(req, res) {
  token <- cleanup_token(req$HTTP_TOKEN)
  renew_jwt(
    token = token, token_salt = SETTINGS$token$token_salt,
    time = SETTINGS$token$token_exp
  )
}

# Endpoints Misc ----
# *******************************************************************

#* Formulation list with descriptions
#* @tag information
#* @get /formulations
function(req, res) {
  log_info <- req_info(req)
  future_promise({
    with_logger(LOGGER, log_info, api_formulation_list_get())
  })
}

#* Request limits of the server
#* @tag information
#* @get /limits
function(req, res) {
  log_info <- req_info(req)
  future_promise({
    with_logger(LOGGER, log_info, api_limits_get())
  })
}

#* Description of the interaction table
#* @tag information
#* @get /interactions/description
function(req, res) {
  log_info <- req_info(req)
  future_promise({
    with_logger(LOGGER, log_info, api_interaction_description())
  })
}

# Endpoints Interactions ----
# *******************************************************************
#* Interaction endpoint for compound names input
#* @param compounds:[string] Comma-separated unique compound names as string
#* @tag interaction
#* @get /interactions/compounds
function(req, res) {
  log_info <- req_info(req)
  cmps <- req$args$compounds
  future_promise({
    with_logger(LOGGER, log_info, api_compound_interactions_get(cmps))
  })
}

#* Interaction endpoint for  compound names from JSON
#* @param .body The raw body content from the request
#* @tag interaction
#* @post /interactions/compounds
function(req, res) {
  log_info <- req_info(req)
  body <- req$postBody
  future_promise({
    with_logger(LOGGER, log_info, api_compound_interactions_post(body))
  })
}

#* Interaction endpoint for PZN input
#* @param pzns:[string] Comma-separated unique PZNs as strings
#* @tag interaction
#* @get /interactions/pzns
function(req, res) {
  log_info <- req_info(req)
  pzns <- req$args$pzns
  future_promise({
    with_logger(LOGGER, log_info, api_pzn_interactions_get(pzns))
  })
}

#* Interaction endpoint for PZN input from JSON
#* @param .body The raw body content from the request
#* @tag interaction
#* @post /interactions/pzns
function(req, res) {
  log_info <- req_info(req)
  body <- req$postBody
  future_promise({
    with_logger(LOGGER, log_info, api_pzn_interactions_post(body))
  })
}


# ATC ENDPOINTS ----
# *******************************************************************

#* Drug endpoint for ATC input
#* @param atcs:[string] Comma-separated unique ATCs as strings
#* @tag atc
#* @get /atcs/drugs
function(req, res) {
  log_info <- req_info(req)
  atcs <- req$args$atcs
  future_promise({
    with_logger(LOGGER, log_info, api_atc_names_get(atcs))
  })
}

#
# # Naming endpoint for ATC input
# # @param atcs:[string] Comma-separated unique ATCs as strings
# # @tag TODO
# # @get /atc/names
# function(atcs, res) {
#   api_atc_names_get(atcs, res)
# }
#
# # Interaction endpoint for ATC input
# # @param atcs:[string] Comma-separated unique ATCs as strings
# # @tag TODO
# # @get /atc/interactions
# function(atcs, res) {
#   api_atc_interactions_get(atcs, res)
# }
