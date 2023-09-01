# Clean the token to remove excess heading and trailing quotes
cleanup_token <- function(token) {
  if (!is.null(token)) {
    token <- token |>
      stringr::str_remove_all('\"')
  }
  return(token)
}

# Function to log requests to the server.
filter_logger <- function(req, path_prefix = "", token_salt = SETTINGS$token_salt) {
  token <- cleanup_token(req$HTTP_TOKEN)
  username <- username_from_jwt(token, token_salt)

  cat(as.character(Sys.time()), "-",
      ifelse(is.null(username), "UNKNOWN USER", username), "-",
      req$REQUEST_METHOD, paste0(path_prefix, req$PATH_INFO), "-",
      req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n")
  forward()
}

# Filter to check if a user is authorized to access a route.
filter_valid_token <- function(req, res, token_salt = SETTINGS$token_salt, debugging = FALSE) {
  if (debugging)
    forward()

  token <- cleanup_token(req$HTTP_TOKEN)

  # check if token is present
  if (is.null(token)) {
    error <- api_error(res, 401, msg = "No token provided")
    return(error)
  }

  # check if token is valid
  valid <- test_valid_jwt(token, token_salt)
  if (valid) {
    forward()
  } else {
    error <- api_error(res, 401, msg = "Invalid token provided")
    return(error)
  }
}
