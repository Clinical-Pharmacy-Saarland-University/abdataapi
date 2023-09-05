# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: PZN API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************


# API functions ----
# *******************************************************************
api_pzn_atc_get <- function(pzns, res) {
  pzns <- .validate_pzn_get(pzns, res)
  if (is.null(pzns$result)) {
    return(pzns$error)
  }

  pzns <- pzns$result
  ret <- sql_atc_pzns(pzns)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  ret <- tag_result(ret, list(ids = 1, items = length(pzns)))
  ret$pzns <- pzns
  return(ret)
}
