jwt_decode_hmac_safely <- safely(jwt_decode_hmac)
jwt_encode_hmac_safely <- safely(jwt_encode_hmac)
checkpw_safely <- safely(checkpw)

# log a user in
user_login <- function(req, res, token_salt, time) {
  con <- mongoCon()
  error <- NULL

  username <- req$body$credentials$username
  password <- req$body$credentials$password

  # check user exists and fetch password
  qry <- glue('{"username": "(username)"}',
    .open = "(",
    .close = ")",
    username = username
  )

  ret <- con$find(qry)
  l <- ret |>
    nrow()

  if (l == 0) {
    error <- api_error(res, status = 400, msg = paste0("Invalid username: ", username))
  } else if (l > 1) {
    error <- api_error(res, status = 400, msg = paste0("Ambiguous username: ", username))
  }

  if (length(error) > 0) {
    return(error)
  }

  password_db <- ret |>
    pull(password)

  # check password
  pw_ret <- checkpw_safely(password, password_db)
  if (!pw_ret$result) {
    error <- api_error(res, status = 400, msg = paste0(
      "Invalid password provided for username: ",
      username
    ))
    return(error)
  }

  if (length(ret$error) <= 0) {
    # generate token
    ret <- generate_jwt(token_salt, time, username)
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
  if (!test_valid_jwt(token, token_salt) || is.null(token)) {
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
