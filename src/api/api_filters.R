# Clean the token to remove excess heading and trailing quotes
cleanup_token <- function(token) {
  if (is.null(token)) {
    stop_for_unauthorized("No login token provided.")
  }

  token <- token |>
    stringr::str_split(" ", simplify = TRUE) |>
    trimws()

  if (length(token) != 2) {
    stop_for_unauthorized("Invalid token format provided.")
  }

  token[1] <- token[1] |> tolower()
  if (token[1] != "bearer") {
    stop_for_unauthorized("Invalid token format provided (expected 'Bearer').")
  }

  token <- token[2]
  token <- token |>
    stringr::str_remove_all('\"')

  return(token)
}

# Filter to check if a user is authorized to access a route.
filter_valid_token <- function(req,
                               token_salt = SETTINGS$token$token_salt,
                               debugging = SETTINGS$debug_mode) {
  if (!debugging) {
    token <- cleanup_token(req$HTTP_AUTHORIZATION)

    # check if token is valid
    valid <- test_valid_jwt(token, token_salt)
    if (!valid) {
      stop_for_unauthorized("Invalid token provided.")
    }
  }

  forward()
}
