# *******************************************************************
# Project: ABDATA API Client
# Script purpose: Client tests
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

options(warn = -1)
source("packages.R")
source("test_helper.R")
init_packages()

if (!exists("dev_mode")) {
  dev_mode <- TRUE
}

if (dev_mode) {
  cred <- read_yaml("dev_credentials.yaml")
} else {
  cred <- read_yaml("prod_credentials.yaml")
}

tests <- function() {
  if (dev_mode) {
    cat("Testing DEV environment !\n")
  } else {
    cat("Testing PRODUCTION environment !\n")
  }

  server_online <- is_server_online(cred$HOST)
  if (!server_online) {
    stop(glue("Server at {cred$HOST} is not online."), call. = FALSE)
  }
  print(glue("Server at {cred$HOST} is online."))

  print(glue("Logging in as {cred$USER} ..."))
  token <- api_login(cred$HOST, cred$USER, cred$PWD)
  log <- data.frame()

  cat("Testing Endpoints ...\n")

  ## Information ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "formulations", "",
    api_get(cred$HOST, "api/formulations", token)
  )
  log <- api_test(log, "GET", "limits", "", api_get(cred$HOST, "api/limits", token))
  log <- api_test(
    log, "GET", "interactions/description", "",
    api_get(cred$HOST, "api/interactions/description", token)
  )

  ## PZN GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "interactions/pzns", "3 pzns",
    api_get(cred$HOST, "api/interactions/pzns?pzns=03967062,03041347,00592733", token)
  )
  log <- api_test(
    log, "GET", "interactions/pzns", "3 pzns / explain",
    api_get(cred$HOST, "api/interactions/pzns?pzns=03967062,03041347,00592733&explain=T", token)
  )
  log <- api_test(
    log, "GET", "interactions/pzns", "1 pzn",
    api_get(cred$HOST, "api/interactions/pzns?pzns=03967062", token)
  )
  log <- api_test(
    log, "GET", "interactions/pzns", "1 pzn / explain",
    api_get(cred$HOST, "api/interactions/pzns?pzns=03967062&explain=T", token)
  )

  log <- api_test(
    log, "GET", "pzns/products", "3 pzns",
    api_get(cred$HOST, "api/pzns/products?pzns=03967062,03041347,00592733", token)
  )

  log <- api_test(
    log, "GET", "pzns/products", "1 pzn",
    api_get(cred$HOST, "api/pzns/products?pzns=03967062", token)
  )

  log <- api_test(
    log, "GET", "priscus/pzns", "1 pzn",
    api_get(cred$HOST, "api/priscus/pzns?pzns=03967062", token)
  )

  log <- api_test(
    log, "GET", "priscus/pzns", "3 pzns",
    api_get(cred$HOST, "api/priscus/pzns?pzns=03967062,03041347,00592733", token)
  )

  log <- api_test(
    log, "GET", "qtc/pzns", "1 pzn",
    api_get(cred$HOST, "api/qtc/pzns?pzns=03967062", token)
  )

  log <- api_test(
    log, "GET", "qtc/pzns", "3 pzns",
    api_get(cred$HOST, "api/qtc/pzns?pzns=03967062,03041347,00592733", token)
  )

  log <- api_test(
    log, "GET", "adrs/pzns", "1 pzn, lang = 'german'",
    api_get(cred$HOST, "api/adrs/pzns?pzns=03967062&lang=german", token)
  )

  log <- api_test(
    log, "GET", "adrs/pzns", "3 pzns",
    api_get(cred$HOST, "api/adrs/pzns?pzns=03967062,03041347,00592733", token)
  )

  ## PZN Post ----
  # *******************************************************************
  pzn_list <- purrr::map(seq(5), \(i)  {
    list(id = unbox(as.character(i)), pzns = c("03041347", "17145955", "00592733", "13981502"))
  })
  log <- api_test(
    log, "POST", "interactions/pzns", "5 ids",
    api_post(cred$HOST, "api/interactions/pzns", pzn_list, token)
  )

  pzn_list <- purrr::map(seq(5), \(i)  {
    list(
      id = unbox(as.character(i)), explain = as.logical(i %% 2),
      pzns = c("03041347", "17145955", "00592733", "13981502")
    )
  })
  log <- api_test(
    log, "POST", "interactions/pzns", "5 ids / explain",
    api_post(cred$HOST, "api/interactions/pzns", pzn_list, token)
  )
  log <- api_test(
    log, "POST", "priscus/pzns", "5 ids",
    api_post(cred$HOST, "api/priscus/pzns", pzn_list, token)
  )
  log <- api_test(
    log, "POST", "qtc/pzns", "5 ids",
    api_post(cred$HOST, "api/qtc/pzns", pzn_list, token)
  )

  log <- api_test(
    log, "POST", "adrs/pzns", "5 ids",
    api_post(cred$HOST, "api/adrs/pzns", pzn_list, token)
  )

  pzn_list <- purrr::map(seq(5), \(i)  {
    list(
      id = unbox(as.character(i)), lang = c("german-simple"),
      pzns = c("03041347", "17145955", "00592733", "13981502")
    )
  })

  log <- api_test(
    log, "POST", "adrs/pzns", "5 ids, lang = 'german-simple'",
    api_post(cred$HOST, "api/adrs/pzns", pzn_list, token)
  )

  pzn_list <- purrr::map(seq(5), \(i)  {
    list(
      id = unbox(as.character(i)), lang = c("german"),
      pzns = c("03041347", "17145955", "00592733", "13981502")
    )
  })

  log <- api_test(
    log, "POST", "adrs/pzns", "5 ids, lang = 'german'",
    api_post(cred$HOST, "api/adrs/pzns", pzn_list, token)
  )

  ## Compound GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "interactions/compounds", "3 compounds",
    api_get(cred$HOST, "api/interactions/compounds?compounds=verapamil,simvastatin,diltiazem,amiodarone,amlodipine,lovastatin", token)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "3 compounds / explain",
    api_get(cred$HOST, "api/interactions/compounds?compounds=verapamil,simvastatin,diltiazem,amiodarone,amlodipine,lovastatin&explain=T", token)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "1 compound",
    api_get(cred$HOST, "api/interactions/compounds?compounds=verapamil", token)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "1 compound / explain",
    api_get(cred$HOST, "api/interactions/compounds?compounds=verapamil&explain=T", token)
  )
  log <- api_test(
    log, "GET", "priscus/compounds", "1 compound",
    api_get(cred$HOST, "api/priscus/compounds?compounds=verapamil", token)
  )
  log <- api_test(
    log, "GET", "priscus/compounds", "3 compounds",
    api_get(cred$HOST, "api/priscus/compounds?compounds=metoprolol,pindolol,diazepam", token)
  )
  log <- api_test(
    log, "GET", "qtc/compounds", "1 compound",
    api_get(cred$HOST, "api/qtc/compounds?compounds=verapamil", token)
  )
  log <- api_test(
    log, "GET", "qtc/compounds", "3 compounds",
    api_get(cred$HOST, "api/qtc/compounds?compounds=quinidine,diphenhydramine,ciprofloxacine", token)
  )

  ## Compound Post ----
  # *******************************************************************
  compound_list <- purrr::map(seq(5), \(i)  {
    list(id = unbox(as.character(i)), compounds = c("verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin"))
  })
  log <- api_test(
    log, "POST", "interactions/compounds", "5 ids",
    api_post(cred$HOST, "api/interactions/compounds", compound_list, token)
  )
  log <- api_test(
    log, "POST", "priscus/compounds", "5 ids",
    api_post(cred$HOST, "api/priscus/compounds", compound_list, token)
  )
  log <- api_test(
    log, "POST", "qtc/compounds", "5 ids",
    api_post(cred$HOST, "api/qtc/compounds", compound_list, token)
  )

  compound_list <- purrr::map(seq(5), \(i)  {
    list(
      id = unbox(as.character(i)), explain = as.logical(i %% 2),
      compounds = c("verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin")
    )
  })
  log <- api_test(
    log, "POST", "interactions/compounds", "5 ids / explain",
    api_post(cred$HOST, "api/interactions/compounds", compound_list, token)
  )

  ## ATC GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "atcs/drugs", "4 ATCs",
    api_get(cred$HOST, "api/atcs/drugs?atcs=C01BD01,C08DB01,C08DA01,J01CR02", token)
  )

  log <- log |>
    arrange(Endpoint)
  return(log)
}

print(glue("Testing API at {cred$HOST} ...\n"))
test_res <- tests()
n_test <- nrow(test_res)
n_success <- sum(test_res$Success)
print(test_res)
print(glue("Tests: {n_test}, Success: {n_success}, Failure: {n_test - n_success}"))
