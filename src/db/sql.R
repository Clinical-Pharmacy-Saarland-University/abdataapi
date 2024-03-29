# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Higher level SQL functions
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Misc queries ----
# *******************************************************************

# list or NULL on error
sql_formulations <- sql_atc_names <- function(con = NULL) {
  res <- sql_query("SELECT Key_DAR, Name FROM DAR_DB", .con = con)
  if (is.null(res)) {
    return(NULL)
  }

  colnames(res) <- c("formulation", "description")
  res <- list(
    formulations = res |> na.omit()
  )

  return(res)
}


# ATC queries ----
# *******************************************************************

# list or NULL on error
sql_atc_names <- function(atcs, con = NULL) {
  limit <- length(atcs)
  res <- sql_query(
    paste(
      "SELECT Key_ATC, Name_deutsch, Name_englisch FROM ATC_DB",
      "WHERE Key_ATC IN ({atcs*}) LIMIT {limit}"
    ),
    atcs = atcs, limit = limit, .con = con
  )

  if (is.null(res)) {
    return(NULL)
  }

  colnames(res) <- c("atc", "name_german", "name_english")

  unknown_atcs <- atcs[!tolower(atcs) %in% tolower(res$atc)]
  res <- list(
    names = res |> na.omit(),
    unknown_atcs = unknown_atcs
  )

  res
}


# PZN queries ----
# *******************************************************************

# list or NULL on error
sql_pzn_product <- function(pz_numbers, con = NULL) {
  if (length(pz_numbers) < 1) {
    res <- list(
      products = character(),
      unknown_pzns = character()
    )
    return(res)
  }

  if (is.null(con)) {
    con <- connectServer()
    on.exit(disconnect(con), add = TRUE)
  }


  limit <- length(pz_numbers)
  products_entries <- sql_query(
    paste(
      "SELECT PZN, Produktname, Key_ATC FROM PAE_DB LEFT JOIN FAM_DB ON ",
      "FAM_DB.Key_FAM = PAE_DB.Key_FAM WHERE PZN IN ({pz_numbers*}) LIMIT {limit}"
    ),
    pz_numbers = pz_numbers, limit = limit, .con = con
  )

  unknown_pzns <- pz_numbers[!pz_numbers %in% products_entries$PZN]
  if (nrow(products_entries) == 0) {
    res <- list(
      products = character(),
      unknown_pzns = unknown_pzns
    )
    return(res)
  }

  colnames(products_entries) <- c("pzn", "product", "atc")

  res <- list(
    products = products_entries,
    unknown_pzns = unknown_pzns
  )

  return(res)
}


# Interactions ----
# *******************************************************************
# list or NULL on error
pzn_interactions <- function(pz_numbers, explain = FALSE, con = NULL) {
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
  if (is.null(fam_keys)) {
    return(NULL)
  }

  unknown_pzns <- pz_numbers[!pz_numbers %in% fam_keys$PZN]
  if (nrow(fam_keys) == 0) {
    res <- list(
      interactions = character(),
      unknown_pzns = unknown_pzns
    )
    return(res)
  }

  match_df <- fam_keys |>
    group_by(Key_FAM) |>
    slice(1) |>
    ungroup()

  inter_tables <- match_df$Key_FAM |>
    sql_fam_keys_interactions(con = con)
  if (is.null(inter_tables)) {
    return(NULL)
  }

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
  if (is.null(inter_sheets)) {
    return(NULL)
  }

  pzn_infos <- left_join(min_inter_tab, fam_keys, by = "Key_FAM") |>
    select(Key_INT, Lokalisation, PZN) |>
    spread(Lokalisation, PZN) |>
    set_names("Key_INT", "Left_PZN", "Right_PZN")

  inter_sheets <- left_join(inter_sheets, pzn_infos, by = "Key_INT")
  inter_sheets <- inter_sheets |>
    set_names(c(
      "Key_INT", "plausibility", "relevance", "frequency",
      "credibility", "direction", "left_PZN", "right_PZN"
    )) |>
    translate_interaction_table()


  if (explain && !is.null(inter_sheets) && nrow(inter_sheets) > 0) {
    key_ints <- inter_sheets$Key_INT |> unique()
    inter_extra <- sql_inter_explain(key_ints, con = con)
    inter_sheets <- inter_sheets |>
      left_join(inter_extra, by = "Key_INT")
  }

  inter_sheets <- inter_sheets |> select(-Key_INT)

  res <- list(
    interactions = inter_sheets,
    unknown_pzns = unknown_pzns
  )

  return(res)
}

# list or NULL on error
compound_interactions <- function(compounds, explain = FALSE, con = NULL) {
  if (length(compounds) <= 1) {
    res <- list(
      interactions = character(),
      unknown_compounds = character()
    )
    return(res)
  }

  sto_entries <- sql_query("SELECT Key_STO, Name FROM SNA_DB WHERE Name IN ({compounds*})",
    compounds = compounds, .con = con
  )
  if (is.null(sto_entries)) {
    return(NULL)
  }

  unknown_compounds <- compounds[!tolower(compounds) %in% tolower(sto_entries$Name)]
  if (nrow(sto_entries) == 0) {
    res <- list(
      interactions = character(),
      unknown_pzns = unknown_pzns
    )
    return(res)
  }

  sto <- unique(sto_entries$Key_STO)
  interactions <- sql_query("SELECT * FROM SZI_C WHERE Key_STO IN ({sto*})", sto = sto, .con = con)
  if (is.null(interactions)) {
    return(NULL)
  }

  interactions <- interactions |>
    group_by(Key_INT) |>
    filter(dplyr::n() > 1) |>
    arrange(Key_INT) |>
    group_by(Key_INT, Lokalisation) |>
    slice(1) |>
    ungroup() |>
    group_by(Key_INT) |>
    filter(dplyr::n() > 1) |>
    ungroup() |>
    distinct(Key_INT, Lokalisation, Key_STO, .keep_all = TRUE) |>
    group_by(Key_INT) |>
    filter(dplyr::n() > 1) |>
    arrange(Key_INT)

  if (nrow(interactions) == 0) {
    res <- list(
      interactions = character(),
      unknown_compounds = unknown_compounds
    )
    return(res)
  }

  # sheets
  key_ints <- interactions$Key_INT |> unique()
  inter_sheets <- sql_interaction_sheets(key_ints, con = con)
  if (is.null(inter_sheets)) {
    return(NULL)
  }

  # get compound infos
  compound_meta <- sql_compound_desc_from_int(key_ints, sto, con = con)
  if (is.null(compound_meta)) {
    return(NULL)
  }

  compound_meta <- compound_meta |>
    mutate(dose = paste(Zahl, Einheit)) |>
    select(-Zahl, -Einheit)

  # join all infos
  compound_infos <- interactions |>
    left_join(sto_entries, by = "Key_STO") |>
    left_join(compound_meta, by = c("Key_INT", "Key_STO")) |>
    select(-Key_STO) |>
    pivot_wider(
      names_from = Lokalisation,
      values_from = c("Name", "Key_ATC", "Key_DAR", "Produktname", "dose")
    )


  # translate and fit tables
  inter_res <- inter_sheets |>
    left_join(compound_infos, by = "Key_INT") |>
    set_names(c(
      "Key_INT", "plausibility", "relevance", "frequency",
      "credibility", "direction", "left_compound", "right_compound",
      "left_atc", "right_atc",
      "left_formulation", "right_formulation",
      "left_medication", "right_medication",
      "left_dose", "right_dose"
    )) |>
    translate_interaction_table() |>
    distinct()


  if (explain && !is.null(inter_res) && nrow(inter_res) > 0) {
    key_ints <- inter_res$Key_INT |> unique()
    inter_extra <- sql_inter_explain(key_ints, con = con)
    inter_res <- inter_res |>
      left_join(inter_extra, by = "Key_INT")
  }

  inter_res <- inter_res |> select(-Key_INT)
  res <- list(
    interactions = inter_res,
    unknown_compounds = unknown_compounds
  )

  res
}
