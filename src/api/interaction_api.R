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

api_interaction_description <- function(res) {
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
api_compound_interactions_get <- function(compounds, res) {
  compounds <- .validate_compounds_get(compounds, res)

  if (is.null(compounds$result)) {
    return(compounds$error)
  }

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

api_compound_interactions_post <- function(body_data, res) {
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
        "compounds": {
          "type": "array",
          "items": {
            "type": "string"
          },
          "minItems": 1,
          "maxItems": (max_cmpts),
          "uniqueItems": true,
        }
      },
      "required": ["id", "cmpts"]
    }
  }'

  parse_res <- read_json_body(body_data, schema, res,
    max_cmpts = SETTINGS$limits$max_compounds,
    max_ids = SETTINGS$limits$max_ids
  )
  if (!is.null(parse_res$error)) {
    return(parse_res$error)
  }

  con <- connectServer()
  on.exit(disconnect(con))

  ret <- tryCatch(map(list_data, \(x) {
    cmpts <- unlist(x$compounds)
    cmpts_ok <- map_lgl(cmpts, \(x) nchar(trimws(x) > 0))
    if (any(!cmpts_ok)) {
      error_json <- toJSON(list(id = x$id, invalid_compounds = cmpts[which(!cmpts_ok)]))
      stop(error_json)
    }

    res <- compound_interactions(cmpts, con)
    res$id <- unbox(x$id)
    res$compounds <- cmpts
    res
  }), error = function(e) {
    error_list <- fromJSON(e$parent$message)
    error <- api_error(res, 400, "Some provided compounds are not valid.", list(
      id = unbox(error_list$id),
      invalid_compounds = error_list$invalid_pzns
    ))
    return(error)
  })

  result <- list(results = ret)
  result <- tag_result(result)
  result
}


### PZN ----
# *******************************************************************
api_pzn_interactions_get <- function(pzns, res) {
  pzns <- .validate_pzn_get(pzns, res)
  if (is.null(pzns$result)) {
    return(pzns$error)
  }

  pzns <- pzns$result
  ret <- pzn_interactions(pzns)
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  ret <- tag_result(ret)
  ret$pzns <- pzns
  return(ret)
}


api_pzn_interactions_post <- function(req, res) {
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
  if (!is.null(parse_res$error)) {
    return(parse_res$error)
  }

  con <- connectServer()
  on.exit(disconnect(con))

  ret <- tryCatch(map(list_data, \(x) {
    pzns <- unlist(x$pzns)
    pzns_ok <- map_lgl(pzns, validate_pzn)
    if (any(!pzns_ok)) {
      error_json <- toJSON(list(id = x$id, invalid_pzns = pzns[which(!pzns_ok)]))
      stop(error_json)
    }

    res <- pzn_interactions(pzns, con)
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
