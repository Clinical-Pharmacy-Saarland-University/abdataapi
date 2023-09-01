# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: SQL functions
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

  con$result
}

# returns always T
disconnect <- function(con) {
  if (!is.null(con) && !.isPool(con)) {
    safe_dbDisconnect(con)
  }
  return(TRUE)
}

# Misc queries ----
# *******************************************************************
sql_formulations <- sql_atc_names <- function(con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  query <- glue_sql("SELECT Key_DAR, Name FROM DAR_DB", .con = con)

  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }
  res <- res$result
  colnames(res) <- c("formulation", "description")

  res <- list(
    formulations = res |> na.omit(),
  )

  res
}



# ATC queries ----
# *******************************************************************
sql_atc_names <- function(atcs, con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  limit <- length(atcs)
  query <- glue_sql("SELECT Key_ATC, Name_deutsch, Name_englisch FROM ATC_DB WHERE Key_ATC IN ({atcs*}) LIMIT {limit}",
    .con = con
  )
  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }
  res <- res$result
  colnames(res) <- c("atc", "name_german", "name_english")

  unknown_atcs <- atcs[!atcs %in% res$ATC]
  res <- list(
    names = res |> na.omit(),
    unknown_atcs = unknown_atcs
  )

  res
}


# PZN queries ----
# *******************************************************************

# df or NULL on error
# Function takes only at least one pzn
sql_famkeys_pzn <- function(pzns, con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  limit <- length(pzns)
  query <- glue_sql("SELECT PZN, Key_FAM FROM PAE_DB WHERE PZN IN ({pzns*}) LIMIT {limit}",
    .con = con
  )
  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }
  res <- res$result
  res
}

# df or NULL on error
# Function takes only at least one atc
sql_famkeys_atc <- function(atcs, con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  query <- glue_sql("SELECT Key_ATC, FAM_DB.Key_FAM, Einheit, Zahl, Key_DAR, SNA_DB.Name, Produktname  ",
    "FROM FAM_DB LEFT JOIN FAI_DB ON FAM_DB.Key_FAM = FAI_DB.Key_FAM ",
    "LEFT JOIN SNA_DB ON FAI_DB.Key_STO = SNA_DB.Key_STO ",
    "WHERE Veterinaerpraeparat = 0 AND Stofftyp = 1 AND Herkunft LIKE '%Ph.Eur.%' AND Key_ATC IN ({atcs*})",
    .con = con
  )
  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }

  res <- res$result
  res
}

# list or NULL on error
# Function takes only at least one pzn
sql_atc_pzns <- function(pzns, con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  query <- glue_sql("SELECT PZN, Key_ATC FROM FAM_DB LEFT JOIN PAE_DB ON  PAE_DB.Key_FAM = FAM_DB.Key_FAM ",
    "WHERE Veterinaerpraeparat = 0 AND PZN IN ({pzns*})",
    .con = con
  )
  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }
  res <- res$result
  colnames(res) <- c("pzn", "atc")

  unknown_pzns <- pzns[!pzns %in% res$PZN]
  res <- list(
    atcs = res |> na.omit(),
    unknown_pzns = unknown_pzns
  )

  res
}

# df or NULL on error
# Function takes only at least one fam_key
sql_interactions <- function(fam_keys, con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  query <- glue_sql("SELECT FZI_C.Key_FAM, FZI_C.Key_INT, SZI_C.Lokalisation ",
    "FROM FZI_C lEFT JOIN ",
    "SZI_C ON FZI_C.Key_INT = SZI_C.Key_INT AND ",
    "FZI_C.Key_STO = SZI_C.Key_STO WHERE ",
    "FZI_C.Key_FAM IN ({fam_keys*})",
    .con = con
  )

  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }
  res <- res$result
  res
}

# df or NULL on error
# Function takes at least one Key_INT
sql_interaction_sheets <- function(int_keys, con = NULL) {
  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }

  query <- glue_sql("SELECT Key_INT, Plausibilitaet, Relevanz, Haeufigkeit, Quellenbewertung, ",
    "Richtung FROM INT_C WHERE Key_INT IN ({int_keys*}) AND AMTS_individuell != 0",
    .con = con
  )

  res <- safe_dbGetQuery(con, query) |> suppressWarnings()
  if (!is.null(res$error)) {
    return(NULL)
  }
  res <- res$result
  res
}


# Complex queries ----
# *******************************************************************
# list or NA if no interactions or with just one PZN or NULL on error
pzn_interactions <- function(pz_numbers, con = NULL) {
  if (length(pz_numbers) <= 1) {
    res <- list(
      interactions = character(),
      unknown_pzns = character()
    )
    return(res)
  }

  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }

  if (is.null(con)) {
    return(NULL)
  }
  # fam and inter key fetching
  fam_keys <- sql_famkeys_pzn(pz_numbers, con)
  unknown_pzns <- pz_numbers[!pz_numbers %in% fam_keys$PZN]
  match_df <- fam_keys |>
    group_by(Key_FAM) |>
    slice(1) |>
    ungroup()

  inter_tables <- match_df$Key_FAM |>
    sql_interactions(con = con)

  # find real interactions
  min_inter_tab <- inter_tables |>
    group_by(Key_INT) |>
    filter(dplyr::n() > 1) |>
    arrange(Key_INT) |>
    group_by(Key_INT, Lokalisation) |>
    slice(1) |>
    ungroup() |>
    group_by(Key_INT) |>
    filter(dplyr::n() > 1) |>
    ungroup() |>
    distinct(Key_INT, Lokalisation, Key_FAM, .keep_all = TRUE) |>
    group_by(Key_INT) |>
    filter(dplyr::n() > 1) |>
    arrange(Key_INT)

  if (nrow(min_inter_tab) == 0) {
    res <- list(
      interactions = character(),
      unknown_pzns = unknown_pzns
    )
    return(res)
  }

  key_ints <- min_inter_tab$Key_INT |> unique()
  inter_sheets <- sql_interaction_sheets(key_ints, con)

  pzn_infos <- left_join(min_inter_tab, fam_keys, by = "Key_FAM") |>
    select(Key_INT, Lokalisation, PZN) |>
    spread(Lokalisation, PZN) |>
    set_names("Key_INT", "Left_PZN", "Right_PZN")

  inter_sheets <- left_join(inter_sheets, pzn_infos, by = "Key_INT")
  inter_sheets <- inter_sheets |>
    select(-Key_INT) |>
    set_names(c(
      "plausibility", "relevance", "frequency",
      "credibility", "direction", "left_PZN", "right_PZN"
    )) |>
    translate_interaction_table()


  res <- list(
    interactions = inter_sheets,
    unknown_pzns = unknown_pzns
  )

  return(res)
}
