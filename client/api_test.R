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
    log, "GET", "interactions/pzns", "1 pzn",
    api_get(HOST, "api/interactions/pzns?pzns=03967062", token, time = time)
  )

  ## PZN Post ----
  # *******************************************************************
  pzn_list <- purrr::map(seq(5), \(i)  {
    list(id = unbox(as.character(i)), pzns = c("03041347", "17145955", "00592733", "13981502"))
  })
  log <- api_test(
    log, "Post", "interactions/pzns", "5 ids",
    api_post(HOST, "api/interactions/pzns", pzn_list, token)
  )

  ## Compound GET ----
  # *******************************************************************
  log <- api_test(
    log, "GET", "interactions/compounds", "3 compounds",
    api_get(HOST, "api/interactions/compounds?compounds=verapamil,simvastatin,diltiazem,amiodarone,amlodipine,lovastatin", token, time = time)
  )
  log <- api_test(
    log, "GET", "interactions/compounds", "1 compound",
    api_get(HOST, "api/interactions/compounds?compounds=verapamil", token, time = time)
  )

  ## Compound Post ----
  # *******************************************************************
  compound_list <- purrr::map(seq(5), \(i)  {
    list(id = unbox(as.character(i)), compounds = c("verapamil","simvastatin","diltiazem","amiodarone","amlodipine","lovastatin"))
  })
  log <- api_test(
    log, "Post", "interactions/compounds", "5 ids",
    api_post(HOST, "api/interactions/compounds", compound_list, token)
  )


  log <- log |> arrange(endpoint)
  return(log)
}

tests()


compound_list <- purrr::map(seq(100), \(i)  {
  list(id = unbox(as.character(i)), compounds = c("verapamil","simvastatin","diltiazem","amiodarone","amlodipine","lovastatin"))
})
a <- api_post(HOST, "api/interactions/compounds", compound_list, token)

