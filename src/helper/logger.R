# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Logging functions
# Date: 09-02-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
.print_logger <- function(x) {
  x <- toJSON(x, auto_unbox = TRUE, pretty = TRUE)
  cat(paste0("\033[0;", 31, "m", x, "\033[0m", "\n"))
}

.diabled_logger <- function(x) {
}


# Log functions ----
# *******************************************************************

create_logger <- function(type = c("print", "db", "disabled")) {
  type <- match.arg(type)
  if (type == "print") {
    return(.print_logger)
  }

  if (type == "disabled")
    return(.diabled_logger)

  stop("NOT IMPLEMENTED")
}

req_info <- function(req, token_salt = SETTINGS$token$token_salt) {
  token <- cleanup_token(req$HTTP_TOKEN)
  user_name <- username_from_jwt(token, token_salt)
  user_name <- ifelse(is.null(user_name), "Unknown", username)

  list(
    timestamp = Sys.time(),
    request = req$REQUEST_METHOD,
    endpoint = req$PATH_INFO,
    user = list(
      name = user_name,
      ip = req$REMOTE_ADDR,
      agent = req$HTTP_USER_AGENT
    )
  )
}


with_logger <- function(logger, log_info, f) {
  tictoc::tic(quiet = TRUE)
  res <- f
  toc <- tictoc::toc(quiet = TRUE)
  log_info$exec_time <- toc$toc - toc$tic
  logger(log_info)
  res
}
