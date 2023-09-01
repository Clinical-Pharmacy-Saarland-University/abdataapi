# Endpoint filters ----
# *******************************************************************
#* @filter logger
function(req, res) {
  filter_logger(req)
}

#* @filter authenticated
function(req, res) {
  filter_valid_token(req, res, token_salt = SETTINGS$token_salt, debugging = SETTINGS$debug_mode)
}

# Endpoints user handling ----
# *******************************************************************

#* Endpoint to log a user in
#* @tag user
#* @preempt authenticated
#* @serializer unboxedJSON list(na = NULL)
#* @param credentials:object
#* @post /login
function(req, res, credentials = list(username = "username", password = "password")) {
  user_login(req, res, token_salt = SETTINGS$token_salt, time = SETTINGS$token_exp)
}

#* Endpoint to log a user in
#* @tag user
#* @serializer unboxedJSON list(na = NULL)
#* @get /renew-token
function(req, res) {
  token <- cleanup_token(req$HTTP_TOKEN)
  renew_jwt(token = token, token_salt = SETTINGS$token_salt, time = SETTINGS$token_exp)
}

# Endpoints Misc ----
# *******************************************************************

#* Formulation list with descriptions
#* @tag formulation
#* @tag misc
#* @get /formulations
function(short = "", res) {
  api_formulation_list_get(res)
}

# Endpoints PZN ----
# *******************************************************************

#* ATC endpoint for PZN number input
#* @param pzns:[string] Comma-separated unique PZN-Numbers as strings
#* @tag pzn
#* @tag atc
#* @get /pzn/atc
function(pzns, res) {
  future_promise({
    api_pzn_atc_get(pzns, res)
  })
}


#* Interaction endpoint for PZN number input
#* @param pzns:[string] Comma-separated unique PZN-Numbers as strings
#* @tag pzn
#* @tag interaction
#* @get /pzn/interactions
function(pzns, res) {
  future_promise({
    api_pzn_interactions_get(pzns, res)
  })
}

#* Interaction endpoint for PZN number input from JSON
#* @param .body The raw body content from the request
#* @tag pzn
#* @tag interaction
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
#* @tag atc
#* @get /atc/names
function(atcs, res) {
  api_atc_names_get(atcs, res)
}



##################### TO DO ####################################################

#* Interaction endpoint for ATC input
#* @param atcs:[string] Comma-separated unique ATCs as strings
#* @tag atc
#* @tag interaction
#* @tag TODO
#* @get /atc/interactions
function(atcs, res) {
  api_atc_interactions_get(atcs, res)
}
