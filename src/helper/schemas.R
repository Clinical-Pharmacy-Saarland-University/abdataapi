# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Schema helper functions
# Date: 15-05-2024
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de) &
#   Simeon Ruedesheim
# *******************************************************************

load_schemas <- function(folder) {
  if (!dir.exists(folder)) {
    stop("Folder does not exist")
  }

  files <- list.files(folder, pattern = "*.schema.json", full.names = TRUE)

  schemas <- list()
  for (file in files) {
    schema_name <- basename(file) |>
      str_remove("\\.schema\\.json")
    schemas[[schema_name]] <- readChar(file, file.info(file)$size)
  }

  return(schemas)
}
