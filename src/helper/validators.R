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
read_json_body <- function(json_str, schema, res, ...) {
  result <- list(
    result = NULL,
    error = NULL
  )

  # test for empty
  if (is.null(json_str) || json_str == "") {
    result$error <- api_error(res, 400, "JSON request is empty.")
    return(result)
  }

  # test for schema
  schema <- glue(schema, ..., .open = "(", .close = ")")
  validation_error <- validate_json_schema(json_str, schema)
  if (!is.null(validation_error)) {
    result$error <- api_error(
      res, 400,
      "Posted JSON has invalid schema.", list(errors = validation_error)
    )
    return(result)
  }

  result$result <- fromJSON(json_str, simplifyVector = FALSE)
  return(result)
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

# returns list(result, error)
.validate_compounds_get <- function(cmps, res) {
  result <- list(result = NULL, error = NULL)

  if (missing(cmps) || is.null(cmps) || cmps == "") {
    error <- api_error(
      res, 400, "Compounds parameter is required.",
      list(list(field = "compounds", issue = "This field is required and cannot be empty."))
    )
    result$error <- error
    return(result)
  }

  cmps <- unlist(strsplit(cmps, split = ","))
  cmps <- trimws(cmps)

  # limits test
  if (length(cmps) > SETTINGS$limits$max_compounds) {
    error <- api_error(
      res, 400,
      glue("Maximum number ({SETTINGS$limits$max_compounds}) of allowed compounds exceeded ({length(cmps)}).")
    )
    result$error <- error
    return(result)
  }

  # unique pzns test
  if (!is_unique(cmps)) {
    error <- api_error(res, 400, "Compounds must be unique.")
    result$error <- error
    return(result)
  }

  result$result <- cmps
  return(result)
}


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

  pzns <- unlist(strsplit(pzns, split = ","))
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
