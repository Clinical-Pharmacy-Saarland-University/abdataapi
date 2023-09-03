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
