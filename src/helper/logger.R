# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Logging functions
# Date: 09-02-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Logger ----
# *******************************************************************
.cmdline_logger <- function(x) {
  x <- toJSON(x, auto_unbox = TRUE, pretty = TRUE)
  cat(paste0("\033[0;", 31, "m", x, "\033[0m", "\n"))
}

.db_logger <- function(x) {
  con <- mongo_logdb()
  if (!is.null(con)) {
    try(con$insert(x), silent = TRUE)
    disconnect_mongo(con)
  }
}

.combined_logger <- function(x) {
  .cmdline_logger(x)
  .db_logger(x)
}

.diabled_logger <- function(x) {
}


# Log functions ----
# *******************************************************************
create_logger <- function(type = c("cmdline", "db", "cmdline-db", "disabled")) {
  type <- match.arg(type)
  if (type == "cmdline") {
    return(.cmdline_logger)
  }

  if (type == "db") {
    return(.db_logger)
  }

  if (type == "db") {
    return(.db_logger)
  }

  if (type == "cmdline-db") {
    return(.combined_logger)
  }

  if (type == "disabled") {
    return(.diabled_logger)
  }

  stop("NOT IMPLEMENTED")
}

req_info <- function(req, token_salt = SETTINGS$token$token_salt, debug = SETTINGS$debug_mode) {
  if (debug) {
    user_name <- "debug"
  } else {
    token <- cleanup_token(req)
    user_name <- username_from_jwt(token, token_salt)
    user_name <- ifelse(is.null(user_name), "Unknown", user_name)
  }

  list(
    timestamp = format(Sys.time(), "%Y-%m-%dT%H:%M:%OSZ"),
    request = req$REQUEST_METHOD,
    endpoint = req$PATH_INFO,
    user = list(
      username = user_name,
      ip_adress = req$REMOTE_ADDR,
      user_agent = req$HTTP_USER_AGENT
    )
  )
}


with_logger <- function(logger, log_info, f) {
  tic <- proc.time()["elapsed"]
  res <- f
  toc <- proc.time()["elapsed"]
  log_info$execution_time_ms <- (toc - tic) * 1000

  log_info$status <- "success"
  log_info$details <- attr(res, "details")

  logger(log_info)
  res
}
