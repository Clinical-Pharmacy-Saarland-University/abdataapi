# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: General helper functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

is_unique <- function(v) {
  length(v) == length(unique(v))
}

catch_error <- function(code, otherwise = NULL, quiet = TRUE) {
  tryCatch(list(result = code, error = NULL), error = function(e) {
    if (!quiet) {
      message("Error: ", conditionMessage(e))
    }
    list(result = otherwise, error = e)
  })
}

tag_result <- function(res, details = NULL) {
  res$timestamp <- unbox(Sys.time())
  res$api_version <- unbox(SETTINGS$version)
  attr(res, "details") <- details
  res
}
