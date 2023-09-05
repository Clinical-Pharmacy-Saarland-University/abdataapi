# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: MongoDb functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

mongo_safely <- safely(mongo)

.mongo_connect <- function(cfg) {
  con <- mongo_safely(collection = cfg$collection,
                      db = cfg$db,
                      url = cfg$url)
  con <- con$result
  return(con)
}

mongo_userdb <- function(settings = SETTINGS$userdb) {
  .mongo_connect(settings)
}

mongo_logdb <- function(settings = SETTINGS$logging$log_db) {
  .mongo_connect(settings)
}



