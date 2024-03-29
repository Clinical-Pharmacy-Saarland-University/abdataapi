# *******************************************************************
# Project: ABDATA API Client
# Script purpose: Client tests
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

source("client_helper.R")
# just define HOST = "XXX", USER = "XXX" and PWD = "YYY"
source("test_credentials.R")

tests <- function(time = TRUE) {
  token <- api_login(HOST, USER, PWD)

  log <- data.frame()

  ## Information ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "formulations", "",
    api_get(HOST, "api/formulations", token, time = time)
  )
  log <- api_test(log, "GET", "limits", "", api_get(HOST, "api/limits", token, time = time))
  log <- api_test(
    log, "GET", "interactions/description", "",
    api_get(HOST, "api/interactions/description", token, time = time)
  )

  ## PZN GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "interactions/pzns", "3 pzns",
    api_get(HOST, "api/interactions/pzns?pzns=03967062,03041347,00592733", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/pzns", "3 pzns / explain",
    api_get(HOST, "api/interactions/pzns?pzns=03967062,03041347,00592733&explain=T", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/pzns", "1 pzn",
    api_get(HOST, "api/interactions/pzns?pzns=03967062", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/pzns", "1 pzn / explain",
    api_get(HOST, "api/interactions/pzns?pzns=03967062&explain=T", token, time = time)
  )

  log <- api_test(
    log, "GET", "pzns/products", "3 pzns",
    api_get(HOST, "api/pzns/products?pzns=03967062,03041347,00592733", token, time = time)
  )

  log <- api_test(
    log, "GET", "pzns/products", "1 pzn",
    api_get(HOST, "api/pzns/products?pzns=03967062", token, time = time)
  )

  ## PZN Post ----
  # *******************************************************************
  pzn_list <- purrr::map(seq(5), \(i)  {
    list(id = unbox(as.character(i)), pzns = c("03041347", "17145955", "00592733", "13981502"))
  })
  log <- api_test(
    log, "POST", "interactions/pzns", "5 ids",
    api_post(HOST, "api/interactions/pzns", pzn_list, token, time = time)
  )

  pzn_list <- purrr::map(seq(5), \(i)  {
    list(
      id = unbox(as.character(i)), explain = as.logical(i %% 2),
      pzns = c("03041347", "17145955", "00592733", "13981502")
    )
  })
  log <- api_test(
    log, "POST", "interactions/pzns", "5 ids / explain",
    api_post(HOST, "api/interactions/pzns", pzn_list, token, time = time)
  )

  ## Compound GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "interactions/compounds", "3 compounds",
    api_get(HOST, "api/interactions/compounds?compounds=verapamil,simvastatin,diltiazem,amiodarone,amlodipine,lovastatin", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "3 compounds / explain",
    api_get(HOST, "api/interactions/compounds?compounds=verapamil,simvastatin,diltiazem,amiodarone,amlodipine,lovastatin&explain=T", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "1 compound",
    api_get(HOST, "api/interactions/compounds?compounds=verapamil", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "1 compound / explain",
    api_get(HOST, "api/interactions/compounds?compounds=verapamil&explain=T", token, time = time)
  )

  ## Compound Post ----
  # *******************************************************************
  compound_list <- purrr::map(seq(5), \(i)  {
    list(id = unbox(as.character(i)), compounds = c("verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin"))
  })
  log <- api_test(
    log, "POST", "interactions/compounds", "5 ids",
    api_post(HOST, "api/interactions/compounds", compound_list, token, time = time)
  )

  compound_list <- purrr::map(seq(5), \(i)  {
    list(
      id = unbox(as.character(i)), explain = as.logical(i %% 2),
      compounds = c("verapamil", "simvastatin", "diltiazem", "amiodarone", "amlodipine", "lovastatin")
    )
  })
  log <- api_test(
    log, "POST", "interactions/compounds", "5 ids / explain",
    api_post(HOST, "api/interactions/compounds", compound_list, token, time = time)
  )

  ## ATC GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "atcs/drugs", "4 ATCs",
    api_get(HOST, "api/atcs/drugs?atcs=C01BD01,C08DB01,C08DA01,J01CR02", token, time = time)
  )

  log <- log |> arrange(endpoint)
  return(log)
}

tests()
