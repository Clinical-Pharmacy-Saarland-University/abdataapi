# *******************************************************************
# Project: ABDATA API Client
# Script purpose: Helper functions
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

library(jsonlite)
library(httr)
library(dplyr)
library(tictoc)

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
  response <- GET(addr, add_headers(TOKEN = token))

  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Renew token failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  res
}

api_get <- function(host, endpoint, token, time = TRUE) {
  addr <- paste0(host, "/", endpoint)

  if (time) {
    tic()
    on.exit(toc())
  }

  if (is.null(token)) {
    response <- GET(addr)
  } else {
    response <- GET(addr, add_headers(TOKEN = token))
  }
  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Get failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  res
}

api_post <- function(host, endpoint, payload, token, time = TRUE) {
  addr <- paste0(host, "/", endpoint)

  if (time) {
    tic()
    on.exit(toc())
  }

  response <- POST(addr,
    body = payload, encode = "json",
    add_headers(
      TOKEN = token, encode = "json", .headers = c("Content-Type" = "application/json")
    )
  )

  res <- content(response, "text", encoding = "UTF-8") |>
    fromJSON()

  if (response$status_code != 200) {
    stop(paste("Post failed with:\n", toJSON(res, pretty = TRUE, auto_unbox = TRUE)))
  }

  res
}


api_test <- function(log_table, method, endpoint, description, call) {
  response <- tryCatch(call, error = function(e) {
    return(NULL)
  })
  result <- NULL
  result <- data.frame(
    endpoint = endpoint, method = method,
    description = description, success = !is.null(response)
  )
  log_table <- log_table |> rbind(result)
  log_table
}
