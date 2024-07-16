# *******************************************************************
# Project: ABDATA API Client
# Script purpose: For custom test launches and debugging
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************
options(warn = -1)
source("packages.R")
source("test_helper.R")
init_packages()

cred <- read_yaml("dev_credentials.yaml")
cat("Testing DEV environment !\n")

server_online <- is_server_online(cred$HOST)
if (!server_online) {
  stop(glue("Server at {cred$HOST} is not online."), call. = FALSE)
}
print(glue("Server at {cred$HOST} is online."))


# *******************************************************************
token <- api_login(cred$HOST, cred$USER, cred$PWD)
print("Login successful.")
api_get(cred$HOST, "api/formulations", token) |>
  print()
