# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: API Settings
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

source("helper/secret.R")

# Settings ----
# *******************************************************************
SETTINGS <- list(
  debug_mode = FALSE,
  secrets_file = "./secrets.json",
  swagger = list(
    docs = TRUE,
    version = "0.1.0",
    title = "UdS Clincial Pharmacy DDI API",
    description = "An API to check for Drug-Drug-Interaction querying the ABDATA database"
  ),
  validation = list(
    validate_pzn_checksums = TRUE
  ),
  limits = list(
    max_pzns = 50,
    max_atcs = 50,
    max_compounds = 50,
    max_ids = 10
  ),
  server = list(
    multisession = TRUE,
    worker_threads = 10,
    host = "127.0.0.1",
    port = 8888
  ),
  sql = list(
    host = "",
    user = "",
    pwd = "",
    port = 111,
    database = "",
    use_pool = FALSE
  ),
  userdb = list(
    collection = "",
    db = "",
    url = ""
  ),
  token = list(
    token_salt = "test",
    token_exp = 3600 # time in s)
  )
)


# Patch secrets ----
# *******************************************************************
{
  SEC_FILE_EXISTS <- file.exists(SETTINGS$secrets_file)

  if (!SEC_FILE_EXISTS) {
    create_secret_file(SETTINGS$secrets_file)
    stop("SECRET FILE DOES NOT EXITS ... CREATED TEMPLATE", call. = FALSE)
  } else {
    SETTINGS <<- patch_settings(SETTINGS)
  }
}
