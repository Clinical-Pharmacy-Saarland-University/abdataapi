# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Priscus API functionality
# Date: 04-11-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
safe_fromJson <- safely(fromJSON)

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

api_compound_priscus_post <- function(body_data) {
  schema <- SETTINGS |>
    pluck("schemas") |>
    pluck("post-compounds")

  parse_res <- read_json_body(body_data,
    schema = schema,
    max_compounds = SETTINGS$limits$max_compounds,
    max_ids = SETTINGS$limits$max_ids
  )
  con <- connectServer()
  on.exit(disconnect(con))

  # iterate over parsed items
  ret <- process_items_post(parse_res, "compounds", validate_compound, compound_priscus, con)

  result <- list(results = ret)
  result <- tag_result(result, list(
    ids = length(parse_res),
    items = length(ret)
  ))
  return(result)
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
  schema <- SETTINGS |>
    pluck("schemas") |>
    pluck("post-pzns")

  parse_res <- read_json_body(body_data,
    schema = schema,
    max_pzns = SETTINGS$limits$max_pzns,
    max_ids = SETTINGS$limits$max_ids
  )

  con <- connectServer()
  on.exit(disconnect(con))

  # iterate over parsed items
  ret <- process_items_post(parse_res, "pzns", validate_pzn, pzn_priscus, con)

  result <- list(results = ret)
  result <- tag_result(result, list(
    ids = length(parse_res),
    items = length(ret)
  ))

  return(result)
}
