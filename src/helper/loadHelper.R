# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Load ensure function
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# Loads package and (if necessary) installs the package from CRAN
ensureLib <- function(package_name) {
  if (!requireNamespace(package_name, quietly = TRUE)) {
    install.packages(package_name, dependencies = TRUE)
  }
  library(package_name,
    character.only = TRUE, warn.conflicts = FALSE,
    verbose = FALSE, quietly = TRUE
  ) |> suppressMessages()
}
