# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Secret file creation and reading
# Date: 09-01-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************
suppressPackageStartupMessages({
  library(jsonlite)
})

create_secret_file <- function(path) {
  if (file.exists(path)) {
    file.rename(path, paste0(path, "_bak"))
  }

  secrets <- list(
    sql = list(
      host = "host",
      user = "user",
      pwd = "pwd",
      port = 1111,
      database = "db"
    ),
    userdb = list(
      db = "db",
      collection = "collection",
      url = "mongodb://localhost:port"
    ),
    log_db = list(
      db = "db",
      collection = "collection",
      url = ""
    ),
    token = list(
      token_salt = "salt"
    ),
    server = list(
      host = "host",
      port = 1111
    )
  )

  json <- toJSON(secrets, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json, path, useBytes = TRUE)
}

patch_settings <- function(settings) {
  json <- read_json(settings$secrets_file, simplifyVector = TRUE)

  # sql
  settings$sql$host <- json$sql$host
  settings$sql$user <- json$sql$user
  settings$sql$pwd <- json$sql$pwd
  settings$sql$port <- json$sql$port
  settings$sql$database <- json$sql$database

  # user
  settings$userdb$collection <- json$userdb$collection
  settings$userdb$db <- json$userdb$db
  settings$userdb$url <- json$userdb$url

  # logging
  settings$logging$log_db$collection <- json$log_db$collection
  settings$logging$log_db$db <- json$log_db$db
  settings$logging$log_db$url <- json$log_db$url

  # token
  settings$token$token_salt <- json$token$token_salt

  # server
  settings$server$host <- json$server$host
  settings$server$port <- json$server$port

  return(settings)
}
