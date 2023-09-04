# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: MongoDb functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

mongo_safely <- safely(mongo)

mongoCon <- function(settings = SETTINGS$userdb) {
  con <- mongo_safely(collection = SETTINGS$userdb$collection,
                      db = SETTINGS$userdb$db,
                      url = SETTINGS$userdb$url)

  con <- con$result
  return(con)
}

if (exists("SETTINGS$sql$pool")) {
  closePool(SETTINGS$sql$pool)
}
