# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: MongoDb functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
future_safe_mongo <- function (collection = "test", db = "test", url = "mongodb://localhost",
                               verbose = FALSE, options = ssl_options())
{

  params <- c(list(uri = url), options)
  client <- do.call(mongolite:::mongo_client_new, params)
  if (missing(db) || is.null(db)) {
    url_db <- mongolite:::mongo_get_default_database(client)
    if (length(url_db) && nchar(url_db))
      db <- url_db
  }

  col <- mongolite:::mongo_collection_new(client, collection, db)
  mongolite:::mongo_collection_command_simple(col, "{\"ping\":1}")
  orig <- list(name = tryCatch(mongolite:::mongo_collection_name(col),
                               error = function(e) {
                                 collection
                               }), db = db, url = url, options = options)

  if (length(options$pem_file) && file.exists(options$pem_file))
    attr(orig, "pemdata") <- readLines(options$pem_file)

  rm(client)
  mongolite:::mongo_object(col, verbose = verbose, orig)
}

mongo_safely <- safely(mongo)
future_safe_mongo_safely <- safely(future_safe_mongo)


# Client functionality ----
# *******************************************************************
mongo_userdb <- function(settings = SETTINGS$userdb) {
  con <- mongo_safely(collection = settings$collection,
                      db = settings$db,
                      url = settings$url)
  con <- con$result
  return(con)
}

mongo_logdb <- function(settings = SETTINGS$logging$log_db) {
  con <- future_safe_mongo_safely(collection = settings$collection,
                      db = settings$db,
                      url = settings$url)
  con <- con$result
  return(con)
}

# returns always T
disconnect_mongo <- function(con) {
  if (!is.null(con)) {
    try(con$disconnect())
  }
  return(TRUE)
}










