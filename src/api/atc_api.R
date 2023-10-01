# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: ATC API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# API functions ----
# *******************************************************************
api_atc_names_get <- function(atcs) {
  atcs <- .validate_atc_get(atcs)

  ret <- sql_atc_names(atcs)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(atcs)))
  ret$atcs <- atcs
  return(ret)
}
