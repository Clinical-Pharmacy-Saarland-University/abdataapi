# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: ADR API functionality
# Date: 05-17-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de),
#  & Simeon Ruedesheim
# *******************************************************************

### PZN ----
# *******************************************************************

# Get ADRs for a list of PZNs
api_pzn_adrs_get <- function(pzns, lang = c("english", "german-simple", "german")) {
  lang <- match.arg(lang)

  pzns <- .validate_pzn_get(pzns)
  ret <- pzn_adrs(pzns, lang = lang)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(pzns)))
  ret$pzns <- pzns
  return(ret)
}

# Get ADRs for a list of PZNs
api_pzn_adrs_post <- function(body_data) {
  schema <- SETTINGS |>
    pluck("schemas") |>
    pluck("post-pzns-adrs")

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
    lang <- validate_language(
      x$lang, "english",
      "'lang' parameter must be one of 'english', 'german-simple', 'german'"
    )


    res <- pzn_adrs(pzns, lang = lang, con)
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
