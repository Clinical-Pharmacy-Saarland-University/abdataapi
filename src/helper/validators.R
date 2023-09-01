# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Valiators and error messages
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

safe_json_validate <- safely(json_validate)

# NULL on valid, else the error msg
validate_json_schema <- function(json_str, schema) {

  res <- json_validate(json_str, schema, engine = "ajv", verbose = TRUE)
  if (res)
    return(NULL)

  return(attr(res, "errors"))
}


# T/F
# input must be a string
validate_pzn <- function(pzn, validate_checksum = SETTINGS$limits$validate_pzn_checksums) {
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

