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

limits_get <- function(res) {

  ret <- list(limits = list(max_pzns = SETTINGS$limits$max_pzns,
                               max_atc = SETTINGS$limits$max_atcs,
                               max_ids = SETTINGS$limits$max_ids,
                               max_compounds = ETTINGS$limits$max_compounds))
  ret <- tag_result(ret)
}
