# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Interaction API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
safe_fromJson <- safely(fromJSON)


# API functions ----
# *******************************************************************

api_compound_interactions_get <- function(compounds, res) {
  compounds <- .validate_compounds_get(compounds, res)

  if (is.null(compounds$result))
    return(compounds$error)

  compounds <- compounds$result
  # check interactions
  ret <- compound_interactions(compounds)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }
  ret <- tag_result(ret)
  ret$compounds <- compounds
  return(ret)

}
