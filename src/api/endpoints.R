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
  token <- cleanup_token(req)
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
#* @param explain:[logical] Whether to explain the interaction details. Default is FALSE.
#* @tag interaction
#* @serializer unboxedJSON list(na = NULL)
#* @get /interactions/compounds
function(req, res) {
  log_info <- req_info(req)
  cmps <- req$args$compounds
  explain <- req$args$explain
  future_promise({
    with_logger(LOGGER, log_info, api_compound_interactions_get(cmps, explain))
  })
}

#* Interaction endpoint for  compound names from JSON
#* @param .body The raw body content from the request
#* @tag interaction
#* @serializer unboxedJSON list(na = NULL)
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
#* @param explain:[logical] Whether to explain the interaction details. Default is FALSE.
#* @tag interaction
#* @serializer unboxedJSON list(na = NULL)
#* @get /interactions/pzns
function(req, res) {
  log_info <- req_info(req)
  pzns <- req$args$pzns
  explain <- req$args$explain
  future_promise({
    with_logger(LOGGER, log_info, api_pzn_interactions_get(pzns, explain))
  })
}

#* Interaction endpoint for PZN input from JSON
#* @param .body The raw body content from the request
#* @tag interaction
#* @serializer unboxedJSON list(na = NULL)
#* @post /interactions/pzns
function(req, res) {
  log_info <- req_info(req)
  body <- req$postBody
  future_promise({
    with_logger(LOGGER, log_info, api_pzn_interactions_post(body))
  })
}


# Endpoints ATC  ----
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


# Endpoints PZN ----
# *******************************************************************

#* Product endpoint for PZN input
#* @param pzns:[string] Comma-separated unique PZNs as strings
#* @tag pzn
#* @get /pzns/products
function(req, res) {
  log_info <- req_info(req)
  pzns <- req$args$pzns
  future_promise({
    with_logger(LOGGER, log_info, api_pzn_product_get(pzns))
  })
}
