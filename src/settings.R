# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: API Settings
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

source("helper/secret.R")

if (exists("SETTINGS$sql$pool")) {
  closePool(SETTINGS$sql$pool)
}

# Settings ----
# *******************************************************************

SETTINGS <- list(
  debug_mode = TRUE,
  version = "0.6.2",
  secrets_file = "./secrets.json",
  validation = list(
    validate_pzn_checksums = TRUE
  ),
  logging = list(
    log_device = "disabled", # cmdline, db, cmdline-db, disabled
    log_db = list(
      db = "",
      collection = "",
      url = ""
    )
  ),
  limits = list(
    max_pzns = 50,
    max_atcs = 50,
    max_compounds = 50,
    max_ids = 100
  ),
  server = list(
    multisession = TRUE,
    worker_threads = 5,
    host = "",
    port = 1111
  ),
  sql = list(
    host = "",
    user = "",
    pwd = "",
    port = 1111,
    database = "",
    use_pool = FALSE
  ),
  userdb = list(
    db = "",
    collection = "",
    url = ""
  ),
  token = list(
    token_salt = "",
    token_exp = 3600 # time in s)
  ),
  schemas = load_schemas("schemas")
)


# Patch secrets ----
# *******************************************************************
SECFILEEXISTS <- file.exists(SETTINGS$secrets_file)

if (!SECFILEEXISTS) {
  create_secret_file(SETTINGS$secrets_file)
  stop("SECRET FILE DOES NOT EXITS ... CREATED TEMPLATE", call. = FALSE)
} else {
  SETTINGS <<- patch_settings(SETTINGS)
}
