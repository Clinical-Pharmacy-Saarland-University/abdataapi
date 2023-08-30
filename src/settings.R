# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: API Settings
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************


# Settings ----
# *******************************************************************
SETTINGS <- list(
  debug_mode = FALSE,
  docs = TRUE,
  version = "0.1.0",
  title = "UdS Clincial Pharamcy DDI API",
  description = "An API to check for Drug-Drug-Interaction querying the ABDATA database",
  limits = list(
    validate_pzn_checksums = TRUE
  ),
  server = list(
    host = "127.0.0.1",
    port = 8888
  ),
  sql = list(
    host = "",
    user = "",
    pwd = "",
    port = 3306,
    database = "abdata",
    use_pool = FALSE
  )
)
