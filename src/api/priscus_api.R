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
  sum_c <- 0
  ret <- lapply(parse_res, \(x) {
    cmpts <- unlist(x$compounds)
    sum_c <<- sum_c + length(cmpts)
    cmpts_ok <- map_lgl(cmpts, \(x) nchar(trimws(x)) > 0)
    if (any(!cmpts_ok)) {
      stop_for_bad_request("Some Compounds are invalid.", invalid_compounds = cmpts[which(!cmpts_ok)])
    }

    res <- compound_priscus(cmpts, con)
    if (is.null(res)) {
      stop_for_internal_server_error("Database connection error.")
    }

    res$id <- unbox(x$id)
    res$compounds <- cmpts
    res
  })

  result <- list(results = ret)
  result <- tag_result(result, list(
    ids = length(parse_res),
    items = length(sum_c)
  ))
  result
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
