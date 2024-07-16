# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Starting Script for the API
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Libs and Options ----
# *******************************************************************
library(mirai) |>
  suppressWarnings()
daemons(1L, dispatcher = FALSE, autoexit = tools::SIGINT) |>
  invisible()

m <- mirai({
  source("helper/packages.R")
  init_packages()
  source("helper/schemas.R")
  source("settings.R")
  source("helper/pool.R")
  source("helper/helper.R")
  source("db/sql_helper.R")
  source("db/sql.R")
  source("db/mongo.R")
  source("helper/logger.R")
  source("helper/translators.R")
  source("helper/validators.R")
  source("helper/user_handling.R")
  source("api/api_filters.R")
  source("api/pzn_api.R")
  source("api/atc_api.R")
  source("api/misc_api.R")
  source("api/interaction_api.R")
  source("api/priscus_api.R")
  source("api/qtc_api.R")
  source("api/adrs_api.R")
  source("setup/swagger.R")
  source("setup/handlers.R")
  source("helper/logger.R")

  if (SETTINGS$server$multisession) {
    daemons(SETTINGS$server$worker_threads, dispatcher = FALSE) |>
      invisible()
  }

  if (SETTINGS$sql$use_pool) {
    SETTINGS$sql$pool <- createPool(SETTINGS$sql, SETTINGS$server$multisession)
  }

  # Plumb ----
  # *******************************************************************
  # endpoints <- Plumber$new("api/endpoints.R") |>

  router <- pr() |>
    pr_post(
      "api/login",
      function(req, res, credentials =
                 list(username = "username", password = "password")) {
        username <- catch_error(req$body$credentials$username)$result
        password <- catch_error(req$body$credentials$password)$result

        user_login(username, password,
          token_salt = SETTINGS$token$token_salt,
          time = SETTINGS$token$token_exp
        )
      }
    ) |>
    pr_get(
      "/api/formulations",
      function(req, res) {
        log_info <- req_info(req)
        promise <- mirai(
          {
            api_formulation_list_get()
          },
          .args = list(info = log_info),
          .GlobalEnv
        )
      }
    ) |>
    pr_set_error(api_error_handler) |>
    pr_static("/", "./www") |>
    pr_hook("exit", function() {
      closePool(SETTINGS$sql$pool)
    })

  # Run ----
  # *******************************************************************
  message(glue("Starting API on {SETTINGS$server$host}:{SETTINGS$server$port} ..."))
  pr_run(router,
    host = SETTINGS$server$host,
    port = SETTINGS$server$port,
    debug = SETTINGS$debug_mode,
    quiet = !SETTINGS$debug_mode
  )
})
m[] |> str()
