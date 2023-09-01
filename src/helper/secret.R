# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Secret file creation and reading
# Date: 09-01-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************


create_secret_file <- function(path) {
  secrets <- list(
    sql = list(
      host = "host",
      user = "user",
      pwd = "pwd",
      port = 1111,
      database = "db"
    ),
    userdb = list(
      collection = "collection",
      db = "db",
      url = "mongodb://localhost:port"
    ),
    token = list(
      token_salt = "salt"
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

  # mongo
  settings$userdb$collection <- json$userdb$collection
  settings$userdb$db <- json$userdb$db
  settings$userdb$url <- json$userdb$url

  # token
  settings$token$token_salt = json$token$token_salt

  return(settings)
}
