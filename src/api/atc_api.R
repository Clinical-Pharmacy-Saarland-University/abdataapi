# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: ATC API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
safe_fromJson <- safely(fromJSON)

.validate_atc_get <- function(atcs, res) {
  result <- list(result = NULL, error = NULL)

  if (missing(atcs) || atcs == "") {
    error <- api_error(
      res, 400, "ATCs parameter is required.",
      list(list(field = "atcs", issue = "This field is required and cannot be empty."))
    )
    result$error <- error
    return(result)
  }

  atcs <- trimws(atcs)
  atcs <- unlist(strsplit(atcs, split = ",")) |> trimws()
  atcs <- trimws(atcs) |> toupper()

  # limits test
  if (length(atcs) > SETTINGS$limits$max_atcs) {
    error <- api_error(
      res, 400,
      glue("Maximum number ({SETTINGS$limits$max_atcs}) of allowed ATCs exceeded ({length(atcs)}).")
    )
    result$error <- error
    return(result)
  }

  # unique pzns test
  if (!is_unique(atcs)) {
    error <- api_error(res, 400, "ATCs must be unique.")
    result$error <- error
    return(result)
  }

  # check if pzns are valid
  atcs_ok <- map_lgl(atcs, validate_atc)
  if (any(!atcs_ok)) {
    error <- api_error(
      res, 400, "Some provided ATCs are not valid.", list(invalid_atcs = atcs[which(!atcs_ok)])
    )
    result$error <- error
    return(result)
  }

  result$result <- atcs

  return(result)
}


# API functions ----
# *******************************************************************
api_atc_names_get <- function(atcs, res) {
  atcs <- .validate_atc_get(atcs, res)
  if (is.null(atcs$result))
    return(atcs$error)

  atcs <- atcs$result

  ret <- sql_atc_names(atcs)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  ret <- tag_result(ret)
  ret$atcs <- atcs
  return(ret)
}
