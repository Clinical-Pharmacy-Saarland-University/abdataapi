# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Misc API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

api_formulation_list_get <- function(res) {

  ret <- sql_formulations()
  if (is.null(ret)) {
    return(api_error(res, 500))
  }
  ret <- tag_result(ret)
  return(ret)
}
