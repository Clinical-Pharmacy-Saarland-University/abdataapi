jwt_decode_hmac_safely <- safely(jwt_decode_hmac)
jwt_encode_hmac_safely <- safely(jwt_encode_hmac)
checkpw_safely <- safely(checkpw)

# log a user in
user_login <- function(username, password, token_salt, time) {
  if (is.null(username) || is.null(password) ||
    !is.character(username) || !is.character(password)) {
    stop_for_bad_request("Invalid JSON login format.")
  }

  con <- mongo_userdb()
  if (is.null(con)) {
    stop_for_internal_server_error("Database connection error.")
  }
  on.exit(disconnect_mongo(con))

  # check user exists and fetch password
  qry <- glue('{"username": "(username)"}', .open = "(", .close = ")", username = username)

  ret <- catch_error(con$find(qry))
  ret <- ret$result
  if (is.null(ret)) {
    stop_for_internal_server_error("Database connection error.")
  }

  if (nrow(ret) != 1) {
    stop_for_unauthorized("Username and/or password are invalid.")
  }

  # check password
  password_db <- ret |> pull(password)
  pw_ret <- checkpw_safely(password, password_db)
  if (!pw_ret$result) {
    stop_for_unauthorized("Username and/or password are invalid.")
  }

  ret <- generate_jwt(token_salt, time, username)
  if (is.null(ret$result)) {
    stop_for_internal_server_error()
  }

  return(ret$result)
}

# generate token
generate_jwt <- function(token_salt, time, username) {
  key <- charToRaw(token_salt)
  res <- generate_claim(time, username) |>
    jwt_encode_hmac_safely(secret = key)

  return(res)
}

# generate claim
generate_claim <- function(time, username) {
  claim <- jwt_claim(
    username = username,
    exp = Sys.time() + time
  )

  return(claim)
}

# test if token is valid or invalid (expired or faulty)
test_valid_jwt <- function(token, token_salt) {
  key <- charToRaw(token_salt)
  res <- jwt_decode_hmac_safely(token, secret = key)

  return(is.null(res$error))
}

# fetch username from token for logging
username_from_jwt <- function(token, token_salt) {
  if (is.null(token) || !test_valid_jwt(token, token_salt)) {
    return(NULL)
  }

  key <- charToRaw(token_salt)
  ret <- jwt_decode_hmac_safely(token, secret = key)
  res <- ret$result$username

  return(res)
}

# renew a session token
renew_jwt <- function(token, token_salt, time) {
  username <- username_from_jwt(token, token_salt)
  ret <- generate_jwt(token_salt, time, username)

  return(ret$result)
}
