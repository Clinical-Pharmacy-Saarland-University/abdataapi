# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: PZN API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************


# API functions ----
# *******************************************************************

api_pzn_product_get <- function(pzns) {
  pzns <- .validate_pzn_get(pzns)
  ret <- sql_pzn_product(pzns)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(pzns)))
  ret$pzns <- pzns
  return(ret)
}
