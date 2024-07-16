# *******************************************************************
# Project:  ABDATA DDI API
# Script purpose: Plumber handlers
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

api_error_handler <- function(req, res, err) {
  # Force "unboxed" JSON and the Content-Type from RFC 7807.
  res$serializer <- serializer_unboxed_json(
    type = "application/json"
  )

  if (inherits(err, "http_problem_error")) {
    res$status <- err$status
    err$body$instance <- req$PATH_INFO
    return(err$body)
  }

  if (SETTINGS$debug_mode) {
    print(err)
  }

  res$status <- 500
  internal_server_error(err$message)
}
