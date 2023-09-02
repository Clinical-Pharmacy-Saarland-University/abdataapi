# Clean the token to remove excess heading and trailing quotes
cleanup_token <- function(token) {
  if (!is.null(token)) {
    token <- token |>
      stringr::str_remove_all('\"')
  }
  return(token)
}

# Filter to check if a user is authorized to access a route.
filter_valid_token <- function(req, res,
                               token_salt = SETTINGS$token$token_salt,
                               debugging = SETTINGS$debug_mode) {
  if (debugging) {
    forward()
  }

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
