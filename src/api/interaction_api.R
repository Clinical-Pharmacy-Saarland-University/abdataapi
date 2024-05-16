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

api_interaction_description <- function() {
  plausability <- data.frame(ABDATA_code = c(10, 20, 30, NA))
  plausability <- plausability |> mutate(
    api_text =
      purrr::map_vec(ABDATA_code, ~ .translate_plausability(.))
  )
  plausability$description <- c(
    "Effects have only been observed (interaction is suspected), but there is no plausible mechanism.",
    "The observed interaction effects can be theoretically explained by compound properties.",
    "There exists an explainable and proven mechanism.",
    "Plausability is not documented in the database."
  )

  relevance <- data.frame(ABDATA_code = c(0, 10, 20, 30, 40, 50, 60, NA))
  relevance <- relevance |> mutate(
    api_text =
      purrr::map_vec(ABDATA_code, ~ .translate_relevance(.))
  )
  relevance$description <- c(
    "No assessment from the literature available.",
    "The literature provides indications that no interaction occurs, or no interactions are expected based on the structure/pharmacokinetics/dynamics.",
    "There are only specific warnings from a pharmaceutical company, usually from the product information.",
    "The interaction does not necessarily have therapeutic consequences but should be monitored under certain circumstances.",
    "The interaction can lead to therapeutically relevant consequences for the patient.",
    "The interaction can potentially be life-threatening or lead to serious, possibly irreversible consequences for the patient.",
    "The interacting agents must not be combined.",
    "Clinical relevance is not documented in the database."
  )

  frequency <- data.frame(ABDATA_code = c(1, 2, 3, 4, 5, 6, NA))
  frequency <- frequency |> mutate(
    api_text =
      purrr::map_vec(ABDATA_code, ~ .translate_frequency(.))
  )
  frequency$description <- c(
    "Frequency of DDI >=10%",
    "Frequency of DDI >=1% and <10%",
    "Frequency of DDI >=0.1% and <1%",
    "Frequency of DDI >=0.01% and <0.1%",
    "Frequency of DDI <0.001%",
    "Frequency of DDI is unknown.",
    "Frequency is not documented in the database."
  )

  credebility <- data.frame(ABDATA_code = c(10, 20, 30, 40, 50, NA))
  credebility <- credebility |> mutate(
    api_text =
      purrr::map_vec(ABDATA_code, ~ .translate_credebility(.))
  )
  credebility$description <- c(
    "Evidence for interaction is not known from the evaluated literature.",
    "Evidence for interaction is insufficient from the evaluated literature.",
    "Evidence for interaction is weak from the evaluated literature.",
    "Evidence for interaction is sufficient from the evaluated literature.",
    "Evidence for interaction is high from the evaluated literature.",
    "Evidence is not documented in the database."
  )

  direction <- data.frame(ABDATA_code = c(0, 1, 2, NA))
  direction <- direction |> mutate(
    api_text =
      purrr::map_vec(ABDATA_code, ~ .translate_direction(.))
  )
  direction$description <- c(
    "Primarily concerns substances that mutually intensify each other's side effects.",
    "There is a perpetrator drug (right position) and a victim drug (left position).",
    "The interacting substances are both triggering the interaction and are both affected by their effect.",
    "Interaction direction is not documented in the database."
  )

  ret <- list(
    descriptions = list(
      plausability = plausability,
      relevance = relevance,
      frequency = frequency,
      credebility = credebility,
      direction = direction
    )
  )

  ret <- tag_result(ret)
  ret
}

### Compounds ----
# *******************************************************************
api_compound_interactions_get <- function(compounds, explain) {
  compounds <- .validate_compounds_get(compounds)
  explain <- validate_logical(
    explain, FALSE,
    "'explain' parameter must be logical (T/F/TRUE/FALSE)"
  )

  # check interactions
  ret <- compound_interactions(compounds, explain)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(compounds)))
  ret$compounds <- compounds
  return(ret)
}

api_compound_interactions_post <- function(body_data) {
  schema <- SETTINGS |>
    pluck("schemas") |>
    pluck("post-compounds-interaction")

  parse_res <- read_json_body(body_data,
    schema = schema,
    max_cmpts = SETTINGS$limits$max_compounds,
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

    explain <- validate_logical(
      x$explain, FALSE,
      "'explain' parameter must be logical (T/F/TRUE/FALSE)"
    )

    res <- compound_interactions(cmpts, explain, con)
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
api_pzn_interactions_get <- function(pzns, explain) {
  pzns <- .validate_pzn_get(pzns)
  explain <- validate_logical(
    explain, FALSE,
    "'explain' parameter must be logical (T/F/TRUE/FALSE)"
  )

  ret <- pzn_interactions(pzns, explain)
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  ret <- tag_result(ret, list(ids = 1, items = length(pzns)))
  ret$pzns <- pzns
  return(ret)
}


api_pzn_interactions_post <- function(body_data) {
  schema <- SETTINGS |>
    pluck("schemas") |>
    pluck("post-pzns-interaction")

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
    explain <- validate_logical(
      x$explain, FALSE,
      "'explain' parameter must be logical (T/F/TRUE/FALSE)"
    )
    res <- pzn_interactions(pzns, explain, con)
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
