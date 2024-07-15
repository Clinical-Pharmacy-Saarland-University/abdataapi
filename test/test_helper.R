# *******************************************************************
# Project: ABDATA API Client
# Script purpose: Helper functions
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************
is_server_online <- function(url) {
  response <- try(GET(url), silent = TRUE)
  if (inherits(response, "try-error")) {
    return(FALSE)
  }
  return(status_code(response) == 200)
}

.bearer <- function(token) {
  paste("Bearer", token)
}

api_login <- function(host, user, pwd) {
  creds <- list(credentials = list(username = user, password = pwd))

  addr <- paste0(host, "/api/login")
  response <- POST(addr,
    body = creds, encode = "json",
    add_headers(.headers = c("Content-Type" = "application/json"))
  )

  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Login failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  res
}


api_renew_token <- function(host, token) {
  addr <- paste0(host, "/api/renew-token")
  response <- GET(addr, add_headers(Authorization = .bearer(token)))


  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Renew token failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  res
}

api_get <- function(host, endpoint, token) {
  addr <- paste0(host, "/", endpoint)

  tic()
  response <- GET(addr, add_headers(Authorization = .bearer(token)))
  time <- toc(quiet = TRUE)

  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Get failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  data <- list(time = time$callback_msg, data = res)
  return(data)
}

api_post <- function(host, endpoint, payload, token) {
  addr <- paste0(host, "/", endpoint)

  tic()
  response <- POST(addr,
    body = payload, encode = "json",
    add_headers(
      Authorization = .bearer(token), encode = "json",
      .headers = c("Content-Type" = "application/json")
    )
  )
  time <- toc(quiet = TRUE)

  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Post failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  data <- list(time = time$callback_msg, data = res)
  return(data)
}


api_test <- function(log_table, method, endpoint, description, call) {
  error_msg <- ""
  response <- tryCatch(call, error = function(e) {
    error_msg <<- e$message
    return(NULL)
  })

  time <- if (is.null(response)) "?" else response$time

  result <- data.frame(
    Endpoint = endpoint,
    Method = method,
    Description = description,
    Success = !is.null(response),
    Time = time,
    Error = error_msg
  )
  log_table <- log_table |>
    rbind(result)
  log_table
}
