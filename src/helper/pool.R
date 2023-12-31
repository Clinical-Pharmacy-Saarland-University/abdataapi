# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Db Pooling code
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************


safe_dbPool <- safely(dbPool)
safe_poolClose <- safely(poolClose)

closePool <- function(pool) {
    if (!is.null(pool)) {
        safe_poolClose(pool)
    }
}

createPool <- function(settings = SETTINGS$sql, multisession) {
    if (!settings$use_pool || multisession) {
        return(NULL)
    }

    con <- safe_dbPool(RMySQL::MySQL(),
                       user = settings$user,
                       password = settings$pwd,
                       host = settings$host,
                       port = settings$port,
                       dbname = settings$database,
                       validateQuery = "SELECT 1"
    )
    con <- con$result
    return(con)
}

