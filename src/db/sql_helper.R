# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Lower level SQL functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Helper ----
# *******************************************************************
isPool <- function(con) {
  "Pool" %in% class(con)
}

# Safe sql functions ----
# *******************************************************************
safeDbConnect <- safely(dbConnect)
safeDbgetQuery <- safely(dbGetQuery)
safeDbExecute <- safely(dbExecute)
safeDbDisconnect <- safely(dbDisconnect)


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

  con <- safeDbConnect(RMySQL::MySQL(),
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
  if (!is.null(con) && !isPool(con)) {
    safeDbDisconnect(con)
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

  query <- do.call(glue::glue_sql, args)
  res <- safeDbgetQuery(.con, query) |> suppressWarnings()
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
    pzns = pzns, limit = limit, .con = con
  )

  res
}


# df or NULL on error
sql_interaction_sheets <- function(int_keys, con = NULL) {
  l <- length(int_keys)
  res <- sql_query(
    paste(
      "SELECT Key_INT, Plausibilitaet, Relevanz, Haeufigkeit, Quellenbewertung,",
      "Richtung FROM INT_C WHERE Key_INT IN ({int_keys*}) AND AMTS_individuell != 0 LIMIT {l}"
    ),
    int_keys = int_keys, l = l, .con = con
  )

  res
}

# df or NULL on error
sql_priscus_fam <- function(fam_keys, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT Key_FAM, FAI_DB.Key_STO FROM FAI_DB LEFT JOIN SZG_DB ON FAI_DB.Key_STO = SZG_DB.Key_STO",
      "WHERE Key_FAM IN ({fam_keys*}) AND  Key_SGR = 10084520"
    ),
    fam_keys = fam_keys, .con = con
  )

  res
}

# df or NULL on error
sql_qtc_fam <- function(fam_keys, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT Key_FAM, FAI_DB.Key_STO, SZG_DB.Key_SGR FROM FAI_DB LEFT JOIN SZG_DB ON",
      "FAI_DB.Key_STO = SZG_DB.Key_STO WHERE Key_FAM IN ({fam_keys*}) AND Key_SGR",
      "IN (10079780, 10079781, 10079782)"
    ),
    fam_keys = fam_keys, .con = con
  )

  res
}


# df or NULL on error
sql_adrs_fam <- function(fam_keys, lang = c("german", "german-simple", "english"), con = NULL) {
  lang <- match.arg(lang)

  lang_add <- case_when(
    lang == "german" ~ "AND Sprache = 1",
    lang == "german-simple" ~ "AND Vorzugsbezeichnung_L = 1",
    lang == "english" ~ "AND Sprache = 2"
  )

  res <- sql_query(
    paste(
      "SELECT NEB_C.Key_FAM, NEB_C.Key_MIV, NEB_C.Haeufigkeit, MIN_C.Name",
      "FROM NEB_C JOIN MIN_C ON NEB_C.Key_MIV = MIN_C.Key_MIV",
      "WHERE NEB_C.Key_FAM IN ({fam_keys*})",
      "AND MIN_C.Key_MIV = NEB_C.Key_MIV", # ADRS
      lang_add
    ),
    fam_keys = fam_keys, .con = con
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
    fam_keys = fam_keys, .con = con
  )

  res
}

# df or NULL on error
sql_inter_explain <- function(int_keys, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT Key_INT, Textfeld, Text FROM INT_C RIGHT JOIN ITX_C ON",
      "INT_C.Textverweis = ITX_C.Textverweis WHERE Key_INT IN ({int_keys*}) AND",
      "Textfeld IN (50, 360, 350, 330, 270, 280, 290, 300, 310)"
    ),
    int_keys = int_keys, .con = con
  )

  if (!is.null(res)) {
    res <- res |>
      mutate(Text_Name = case_when(
        Textfeld == 50 ~ "pharm_effect",
        Textfeld == 360 ~ "adr",
        Textfeld == 350 ~ "risk_factors",
        Textfeld == 270 ~ "risk_factors_add",
        Textfeld == 330 ~ "possible_symptoms",
        Textfeld == 280 ~ "measures_intake",
        Textfeld == 290 ~ "measures_interval",
        Textfeld == 300 ~ "measures_other",
        Textfeld == 310 ~ "measures_short_term",
        TRUE ~ as.character(Textfeld)
      )) |>
      select(-Textfeld) |>
      pivot_wider(
        names_from = Text_Name,
        values_from = Text,
        values_fill = list(Text = NA),
        names_prefix = ""
      )

    # List of all expected columns after pivot
    expected_columns <- c(
      "pharm_effect", "adr", "risk_factors", "risk_factors_add", "possible_symptoms",
      "measures_intake", "measures_interval", "measures_other", "measures_short_term"
    )

    # Adding missing columns with NA values
    missing_columns <- setdiff(expected_columns, names(res))
    for (col in missing_columns) {
      res[[col]] <- NA_character_
    }
  }

  res
}

# df or NULL on error
sql_compound_desc_from_int <- function(key_ints, key_sto, con = NULL) {
  res <- sql_query(
    paste(
      "SELECT t.Key_INT, t.Key_STO, Key_ATC, Key_DAR, Produktname, Einheit, Zahl FROM",
      "(SELECT *, ROW_NUMBER() OVER (PARTITION BY Key_INT, Key_STO ORDER BY Key_FAM)",
      "AS row_number FROM FZI_C) t",
      "LEFT JOIN FAM_DB ON t.Key_FAM = FAM_DB.Key_FAM",
      "LEFT JOIN FAI_DB ON t.Key_FAM = FAI_DB.Key_FAM AND t.Key_STO = FAI_DB.Key_STO",
      "WHERE t.Key_INT IN ({key_ints*}) AND t.row_number = 1 AND t.Key_STO IN ({key_sto*})"
    ),
    key_ints = key_ints, key_sto = key_sto, .con = con
  )

  res
}
