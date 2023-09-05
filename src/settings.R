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

SWAGGER_SETTINGS <- list(
  docs = TRUE,
  title = "Clincial Pharmacy DDI API",
  summary = "A closed API to check for DDIs",
  description = "An API to check for Drug-Drug-Interaction querying the ABDATA database",
  contact = list(
    name = "Dominik Selzer",
    url = "https://www.uni-saarland.de/lehrstuhl/lehr/",
    email = "dominik.selzer@uni-saarland.de"
  )
)

SETTINGS <- list(
  debug_mode = FALSE,
  version = "0.1.0",
  secrets_file = "./secrets.json",
  validation = list(
    validate_pzn_checksums = TRUE
  ),
  logging = list(
    log_device = "cmdline", # cmdline, db, cmdline-db, disabled
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
    max_ids = 200
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
