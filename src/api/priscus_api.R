# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Priscus API functionality
# Date: 04-11-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
safe_fromJson <- safely(fromJSON)
pzn_priscus(c("04966751", "00054065", "04524289"))
compound_priscus(c("Sotalol", "Metoprolol", "Bisoprolol"))
### Compounds ----
# *******************************************************************
api_compound_priscus_get <- function(compounds) {
  compounds <- .validate_compounds_get(compounds)
  ret <- compound_priscus(compounds)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(compounds)))
  ret$compounds <- compounds
  return(ret)
}


### PZN ----
# *******************************************************************
api_pzn_priscus_get <- function(pzns) {
  pzns <- .validate_pzn_get(pzns)
  ret <- pzn_priscus(pzns)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(pzns)))
  ret$pzns <- pzns
  return(ret)
}

api_pzn_priscus_post <- function(body_data) {
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

  parse_res <- read_json_body(body_data, schema,
                              max_pzns = SETTINGS$limits$max_pzns,
                              max_ids = SETTINGS$limits$max_ids
  )

  con <- connectServer()
  on.exit(disconnect(con))
  sum_p <- 0
  ret <- lapply(parse_res, \(x) {
    pzns <- unlist(x$pzns)
    pzns_ok <- map_lgl(pzns, validate_pzn)

    if (any(!pzns_ok)) {
      stop_for_bad_request("Some PZNs are invalid.", invalid_pzns = pzns[which(!pzns_ok)])
    }

    sum_p <<- sum_p + length(pzns)
    res <- pzn_priscus(pzns, con)
    if (is.null(res)) {
      stop_for_internal_server_error("Database connection error.")
    }

    res$id <- unbox(x$id)
    res$pzns <- pzns
    res
  })

  result <- list(results = ret)
  result <- tag_result(result, list(
    ids = length(parse_res),
    items = length(sum_p)
  ))
  result
}
