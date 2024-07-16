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
  res$timestamp <- jsonlite::unbox(Sys.time())
  res$api_version <- jsonlite::unbox(SETTINGS$version)
  attr(res, "details") <- details
  res
}

# iterates over parsed items, validates input and queries the database using provided functions
process_items_post <- function(parse_res, item = c("pzns", "compounds"), validate_fn, query_fn, con) {
  item <- match.arg(item)

  sum <- 0
  ret <- lapply(parse_res, \(x) {
    items <- unlist(x[[item]])
    items_ok <- map_lgl(items, validate_fn)

    if (any(!items_ok) && item == "pzns") {
      stop_for_bad_request("Some PZNs are invalid.", invalid_pzns = pzns[which(!pzns_ok)])
    } else if (any(!items_ok) && item == "compounds") {
      stop_for_bad_request("Some Compounds are invalid.", invalid_compounds = cmpts[which(!cmpts_ok)])
    }

    sum <<- sum + length(items)
    res <- query_fn(items, con)
    if (is.null(res)) {
      stop_for_internal_server_error("Database connection error.")
    }

    res$id <- unbox(x$id)
    res[[item]] <- items
    res
  })
  return(ret)
}
