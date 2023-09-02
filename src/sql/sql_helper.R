# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Lower level SQL functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
.isPool <- function(con) {
  "Pool" %in% class(con)
}

# Safe sql functions ----
# *******************************************************************
safe_dbConnect <- safely(dbConnect)
safe_dbGetQuery <- safely(dbGetQuery)
safe_dbExecute <- safely(dbExecute)
safe_dbDisconnect <- safely(dbDisconnect)


# Connections and query helper ----
# *******************************************************************

# con or NULL on error
connectServer <- function(settings = SETTINGS$sql) {
  if (settings$use_pool) {
    pool <- settings$pool
    if (!is.null(pool) && pool$valid) {
      return(pool)
    }
  }

  con <- safe_dbConnect(RMySQL::MySQL(),
    user = settings$user,
    password = settings$pwd,
    host = settings$host,
    port = settings$port,
    dbname = settings$database
  )

  if (SETTINGS$debug_mode && !is.null(con$error)) {
    stop(con$error$message)
  }

  con$result
}

# returns always T
disconnect <- function(con) {
  if (!is.null(con) && !.isPool(con)) {
    safe_dbDisconnect(con)
  }
  return(TRUE)
}

sql_query <- function(query_str, ..., .con = NULL) {
  if (is.null(.con)) {
    .con <- connectServer()
    on.exit(disconnect(.con), add = TRUE)
  }

  if (is.null(.con)) {
    return(NULL)
  }

  args <- list(...)
  args <- c(query_str, args, .con = .con)

  query <- do.call(glue_sql, args)
  res <- safe_dbGetQuery(.con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }

  res$result
}

# Lower level functions ----
# *******************************************************************

# df or NULL on error
sql_famkeys_pzn <- function(pzns, con = NULL) {
  limit <- length(pzns)
  res <- sql_query("SELECT PZN, Key_FAM FROM PAE_DB WHERE PZN IN ({pzns*}) LIMIT {limit}",
    pzns = pzns, limit = limit,
    .con = con
  )

  res
}

# df or NULL on error
sql_famkeys_atc <- function(atcs, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT Key_ATC, FAM_DB.Key_FAM, Einheit, Zahl, Key_DAR, SNA_DB.Name, Produktname  ",
      "FROM FAM_DB LEFT JOIN FAI_DB ON FAM_DB.Key_FAM = FAI_DB.Key_FAM ",
      "LEFT JOIN SNA_DB ON FAI_DB.Key_STO = SNA_DB.Key_STO ",
      "WHERE Veterinaerpraeparat = 0 AND Stofftyp = 1 AND Herkunft LIKE '%Ph.Eur.%' AND Key_ATC IN ({atcs*})"
    ),
    atcs = atcs,
    .con = con
  )

  res
}

# df or NULL on error
sql_interaction_sheets <- function(int_keys, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT Key_INT, Plausibilitaet, Relevanz, Haeufigkeit, Quellenbewertung,",
      "Richtung FROM INT_C WHERE Key_INT IN ({int_keys*}) AND AMTS_individuell != 0"
    ),
    int_keys = int_keys,
    .con = con
  )

  res
}

# df or NULL on error
sql_fam_keys_interactions <- function(fam_keys, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT FZI_C.Key_FAM, FZI_C.Key_INT, SZI_C.Lokalisation ",
      "FROM FZI_C lEFT JOIN ",
      "SZI_C ON FZI_C.Key_INT = SZI_C.Key_INT AND ",
      "FZI_C.Key_STO = SZI_C.Key_STO WHERE ",
      "FZI_C.Key_FAM IN ({fam_keys*})"
    ),
    fam_keys = fam_keys,
    .con = con
  )

  res
}
