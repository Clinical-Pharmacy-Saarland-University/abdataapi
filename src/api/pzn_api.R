# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: PZN API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
safe_fromJson <- safely(fromJSON)


# API functions ----
# *******************************************************************
api_pzn_interactions_get <- function(pzns, res) {
  if (missing(pzns) || pzns == "") {
    error <- api_error(
      res, 400, "PZNs parameter is required.",
      list(list(field = "pzns", issue = "This field is required and cannot be empty."))
    )
    return(error)
  }

  pzns <- trimws(pzns)

  # check if unique
  pzns <- unlist(strsplit(pzns, split = ",")) |> trimws()
  if (!is_unique(pzns)) {
    error <- api_error(res, 400, "PZN numbers must be unique.")
    return(error)
  }

  # check if pzns are valid
  pzns_ok <- map_lgl(pzns, validate_pzn)
  if (any(!pzns_ok)) {
    error <- api_error(
      res, 400, "Some provided PZNs are not valid.", list(invalid_pzns = pzns[which(!pzns_ok)])
    )
    return(error)
  }

  # check interactions
  ret <- pzn_interactions(pzns)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }
  ret <- tag_result(ret)
  ret$pzns <- pzns
  return(ret)
}


api_pzn_interactions_post <- function(req, res) {
  body_data <- req$postBody

  # validate JSON schema
  schema <- '{
    "type": "array",
    "items": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "pzns": {
          "type": "array",
          "items": {
            "anyOf": [
              {"type": "string"},
              {"type": "number"}
            ]
          },
          "minItems": 1,
          "uniqueItems": true,
        }
      },
      "required": ["id", "pzns"]
    }
  }'

  validation_error <- validate_json_schema(body_data, schema)
  if (!is.null(validation_error)) {
    error <- api_error(
      res, 400, "Posted JSON has invalid schema.",
      list(errors = validation_error)
    )
    return(error)
  }

  list_data <- fromJSON(body_data, simplifyVector = FALSE)
  map(list_data, \(x) pzn_interactions(unlist(x$pzns)))
}
