# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Valiators and error messages
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

safe_fromJson <- safely(fromJSON)

tag_result <- function(ret) {

  ret$timestamp <- unbox(Sys.time())
  ret$version <- unbox(SETTINGS$version)
  ret
}

is_unique <- function(v) {
  length(v) == length(unique(v))
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
  pattern <- "^[A-Z][0-9]{2}[A-Z][0-9]{2}$"

  # Check if ATC matches the pattern
  if (grepl(pattern, atc)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}



.status_translate <- function(status) {
  if (status == 400) {
    return("Bad Request")
  }
  if (status == 401) {
    return("Unauthorized")
  }
  if (status == 403) {
    return("Forbidden")
  }
  if (status == 404) {
    return("Not Found")
  }
  if (status == 405) {
    return("Method Not Allowed")
  }
  if (status == 406) {
    return("Not Acceptable")
  }
  if (status == 407) {
    return("Proxy Authentication Required")
  }
  if (status == 408) {
    return("Request Timeout")
  }

  if (status == 500) {
    return("Internal Server Error")
  }
  if (status == 501) {
    return("Not Implemented")
  }
  if (status == 502) {
    return("Bad Gateway")
  }
  if (status == 503) {
    return("Service Unavailable")
  }
  if (status == 504) {
    return("Gateway Timeout")
  }

  # If the status is not recognized
  return(paste("Unknown status:", status))
}

# create an api error message
api_error <- function(res, status, msg = NULL, details = NULL) {
  res$status <- status
  list(
    status = status,
    error = .status_translate(status),
    message = msg,
    details = details
  )
}


