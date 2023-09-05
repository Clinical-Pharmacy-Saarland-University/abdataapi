jwt_decode_hmac_safely <- safely(jwt_decode_hmac)
jwt_encode_hmac_safely <- safely(jwt_encode_hmac)
checkpw_safely <- safely(checkpw)

# log a user in
user_login <- function(username, password, res, token_salt, time) {
  if (is.null(username) || is.null(password) ||
    !is.character(username) || !is.character(password)) {

    error <- api_error(res, status = 400, msg = "Invalid JSON login format.")
    return(error)
  }

  con <- mongo_userdb()
  if (is.null(con)) {
    return(api_error(res, 500))
  }
  on.exit(disconnect_mongo(con))

  # check user exists and fetch password
  qry <- glue('{"username": "(username)"}', .open = "(", .close = ")", username = username)

  ret <- catch_error(con$find(qry))
  ret <- ret$result
  if (is.null(ret)) {
    return(api_error(res, 500))
  }

  if (nrow(ret) != 1) {
    error <- api_error(res, status = 401, msg = "Username and/or password are invalid.")
    return(error)
  }

  password_db <- ret |>
    pull(password)

  # check password
  pw_ret <- checkpw_safely(password, password_db)
  if (!pw_ret$result) {
    error <- api_error(res, status = 401, msg = "Username and/or password are invalid.")
    return(error)
  }

  ret <- generate_jwt(token_salt, time, username)
  if (is.null(ret$result)) {
    return(api_error(res, 500))
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
