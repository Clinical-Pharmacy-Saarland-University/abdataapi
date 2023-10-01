# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Valiators and error messages
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

safe_json_validate <- safely(json_validate)

# NULL on valid, else the error msg
.validate_json_schema <- function(json_str, schema) {
  res <- json_validate(json_str, schema, engine = "ajv", verbose = TRUE)
  if (res) {
    return(NULL)
  }

  return(attr(res, "errors"))
}


# list(result, error)
read_json_body <- function(json_str, schema, ...) {
  # test for empty
  if (is.null(json_str) || json_str == "") {
    stop_for_bad_request("JSON request is empty.")
  }

  # test for schema
  schema <- glue(schema, ..., .open = "(", .close = ")")
  validation_error <- .validate_json_schema(json_str, schema)
  if (!is.null(validation_error)) {
    stop_for_bad_request("JSON request has invalid schema.")
  }

  fromJSON(json_str, simplifyVector = FALSE)
}

# T/F
# input must be a string
validate_pzn <- function(pzn, validate_checksum = SETTINGS$validation$validate_pzn_checksums) {
  # Check if PZN is 8 digits long
  if (nchar(pzn) != 8 || !grepl("^\\d{8}$", pzn)) {
    return(FALSE)
  }

  if (!validate_checksum) {
    return(TRUE)
  }

  # Calculate the weighted sum of the first 7 digits
  digits <- as.numeric(strsplit(as.character(pzn), split = "")[[1]])
  weights <- 1:7
  weighted_sum <- sum(digits[1:7] * weights)

  # Calculate the remainder
  remainder <- weighted_sum %% 11

  # Check if remainder is 10 (invalid) or if it matches the 8th digit
  if (remainder == 10 || remainder != digits[8]) {
    return(FALSE)
  }

  # PZN is valid
  return(TRUE)
}

# T/F
# input must be one atc code
validate_atc <- function(atc) {
  # Regular expression to match ATC pattern
  pattern <- "^[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}$"

  # Check if ATC matches the pattern
  if (grepl(pattern, atc)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}


# Endpoint validator ----
# *******************************************************************

# returns result
.validate_compounds_get <- function(cmps) {

  if (missing(cmps) || is.null(cmps) || cmps == "") {
    stop_for_bad_request("Compounds parameter is required.")
  }

  cmps <- unlist(strsplit(cmps, split = ","))
  cmps <- trimws(cmps)

  # limits test
  if (length(cmps) > SETTINGS$limits$max_compounds) {
    stop_for_bad_request(
      glue("Maximum number ({SETTINGS$limits$max_compounds}) of allowed compounds exceeded ({length(cmps)}).")
    )
  }

  # unique pzns test
  if (!is_unique(cmps)) {
    stop_for_bad_request("Compounds must be unique.")
  }

  return(cmps)
}


.validate_pzn_get <- function(pzns) {
  if (missing(pzns) || is.null(pzns) || pzns == "") {
    stop_for_bad_request("PZNs parameter is required.")
  }

  pzns <- unlist(strsplit(pzns, split = ","))
  pzns <- trimws(pzns)

  # limits test
  if (length(pzns) > SETTINGS$limits$max_pzns) {
    stop_for_bad_request(
      glue("Maximum number ({SETTINGS$limits$max_pzns}) of allowed PZNs exceeded ({length(pzns)}).")
    )
  }

  # unique pzns test
  if (!is_unique(pzns)) {
    stop_for_bad_request("PZNs must be unique.")
  }

  # check if pzns are valid
  pzns_ok <- map_lgl(pzns, validate_pzn)
  if (any(!pzns_ok)) {
    stop_for_bad_request("Some PZNs are invalid.", invalid_pzns = pzns[which(!pzns_ok)])
  }

  return(pzns)
}


.validate_atc_get <- function(atcs) {
  if (missing(atcs) || atcs == "") {
    stop_for_bad_request("ATCs parameter is required.")
  }

  atcs <- unlist(strsplit(atcs, split = ","))
  atcs <- trimws(atcs) |> toupper()

  # limits test
  if (length(atcs) > SETTINGS$limits$max_atcs) {
    stop_for_bad_request("Maximum number ({SETTINGS$limits$max_atcs}) of allowed ATCs exceeded ({length(atcs)}).")
  }

  # unique pzns test
  if (!is_unique(atcs)) {
    stop_for_bad_request("ATCs must be unique.")
  }

  # check if pzns are valid
  atcs_ok <- map_lgl(atcs, validate_atc)
  if (any(!atcs_ok)) {
    stop_for_bad_request("Some ATCs are invalid.", invalid_atcs = atcs[which(!atcs_ok)])
  }

  return(atcs)
}
