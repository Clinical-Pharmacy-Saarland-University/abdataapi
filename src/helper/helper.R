# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: General helper functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

tag_result <- function(ret) {

  ret$timestamp <- unbox(Sys.time())
  ret$version <- unbox(SETTINGS$version)
  ret
}

is_unique <- function(v) {
  length(v) == length(unique(v))
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
  error <- list(
    status = unbox(status),
    error = unbox(.status_translate(status)),
    message = unbox(msg),
    details = details
  )
  return(error)
}
