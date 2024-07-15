# *******************************************************************
# Project: ABDATA API Client
# Script purpose: Create or load credentials
# Date: 07-15-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************
options(warn = -1)
suppressPackageStartupMessages({
  library(yaml)
})

cred_template <- list(
  HOST = "",
  USER = "user",
  PWD = "password"
)

write_dev_cred <- function() {
  if (file.exists("dev_credentials.yaml")) {
    file.rename("dev_credentials.yaml", "dev_credentials_bak.yaml")
  }

  cred <- cred_template
  cred$HOST <- "127.0.0.1:2222"
  write_yaml(cred, "dev_credentials.yaml")
}

write_prod_cred <- function() {
  if (file.exists("prod_credentials.yaml")) {
    file.rename("prod_credentials.yaml", "prod_credentials_bak.yaml")
  }

  cred <- cred_template
  cred$HOST <- "https://abdata.clinicalpharmacy.me"
  write_yaml(cred, "prod_credentials.yaml")
}
