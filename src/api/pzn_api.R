# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: PZN API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
safe_fromJson <- safely(fromJSON)

.validate_pzn_get <- function(pzns, res) {
  result <- list(result = NULL, error = NULL)

  if (missing(pzns) || is.null(pzns) || pzns == "") {
    error <- api_error(
      res, 400, "PZNs parameter is required.",
      list(list(field = "pzns", issue = "This field is required and cannot be empty."))
    )
    result$error <- error
    return(result)
  }

  pzns <- trimws(pzns)
  pzns <- unlist(strsplit(pzns, split = ",")) |> trimws()
  pzns <- trimws(pzns)

  # limits test
  if (length(pzns) > SETTINGS$limits$max_pzns) {
    error <- api_error(
      res, 400,
      glue("Maximum number ({SETTINGS$limits$max_pzns}) of allowed PZNs exceeded ({length(pzns)}).")
    )
    result$error <- error
    return(result)
  }

  # unique pzns test
  if (!is_unique(pzns)) {
    error <- api_error(res, 400, "PZNs must be unique.")
    result$error <- error
    return(result)
  }

  # check if pzns are valid
  pzns_ok <- map_lgl(pzns, validate_pzn)
  if (any(!pzns_ok)) {
    error <- api_error(
      res, 400, "Some provided PZNs are not valid.", list(invalid_pzns = pzns[which(!pzns_ok)])
    )
    result$error <- error
    return(result)
  }

  result$result <- pzns

  return(result)
}


# API functions ----
# *******************************************************************
api_pzn_interactions_get <- function(pzns, res) {
  pzns <- .validate_pzn_get(pzns, res)
  if (is.null(pzns$result))
    return(pzns$error)

  pzns <- pzns$result
  ret <- pzn_interactions(pzns)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  ret <- tag_result(ret)
  ret$pzns <- pzns
  return(ret)
}

api_pzn_atc_get <- function(pzns, res) {
  pzns <- .validate_pzn_get(pzns, res)
  if (is.null(pzns$result))
    return(pzns$error)

  pzns <- pzns$result
  # get atcs
  ret <- sql_atc_pzns(pzns)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  ret <- tag_result(ret)
  ret$pzns <- pzns
  return(ret)
}


api_pzn_interactions_post <- function(req, res) {
  body_data <- req
  if (is.null(body_data) || body_data == "") {
    error <- api_error(
      res, 400, "JSON request is empty.",
      list(errors = validation_error)
    )
    return(error)
  }

  # validate JSON schema
  schema <- '{
    "type": "array",
    "minItems": 1,
    "maxItems": (max_ids),
    "items": {
      "type": "object",
      "properties": {
        "id": {
          "type": "string"
        },
        "pzns": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "minItems": 1,
          "maxItems": (max_pzns),
          "uniqueItems": true,
        }
      },
      "required": ["id", "pzns"]
    }
  }'

  schema <- glue(schema,
    max_pzns = SETTINGS$limits$max_pzns,
    max_ids = SETTINGS$limits$max_ids, .open = "(", .close = ")"
  )

  validation_error <- validate_json_schema(body_data, schema)
  if (!is.null(validation_error)) {
    error <- api_error(
      res, 400, "Posted JSON has invalid schema.",
      list(errors = validation_error)
    )
    return(error)
  }

  list_data <- fromJSON(body_data, simplifyVector = FALSE)
  ret <- tryCatch(map(list_data, \(x) {
    pzns <- unlist(x$pzns)

    pzns_ok <- map_lgl(pzns, validate_pzn)
    if (any(!pzns_ok)) {
      error_json <- toJSON(list(id = x$id, invalid_pzns = pzns[which(!pzns_ok)]))
      stop(error_json)
    }

    res <- pzn_interactions(pzns)
    res$id <- unbox(x$id)
    res$pzns <- pzns
    res
  }), error = function(e) {
    error_list <- fromJSON(e$parent$message)
    error <- api_error(res, 400, "Some provided PZNs are not valid.", list(
      id = unbox(error_list$id),
      invalid_pzns = error_list$invalid_pzns
    ))
    return(error)
  })

  result <- list(results = ret)
  result <- tag_result(result)
  result
}
