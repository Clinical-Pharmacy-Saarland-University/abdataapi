# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: Swagger config
# Date: 09-05-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************
api_spec <- function(x, paths = NULL) {
  # set authentication method for swagger UI/openapi
  x[["components"]] <- list(
    securitySchemes = list(
      ApiKeyAuth = list(
        type = "apiKey",
        `in` = "header",
        name = "TOKEN",
        description = "Authentication token provided to users that successfully logged in"
      )
    )
  )
  # add authentication requirement for all endpoints
  if (is.null(paths)) paths <- names(x$paths)
  for (path in paths) {
    nn <- names(x$paths[[path]])
    for (p in intersect(nn, c("get", "head", "post", "put", "delete"))) {
      x$paths[[path]][[p]] <- c(
        x$paths[[path]][[p]],
        list(security = list(list(ApiKeyAuth = vector())))
      )
    }
  }

  # title et al
  x$info <- list(
    title = SWAGGER_SETTINGS$title,
    summary = SWAGGER_SETTINGS$summary,
    description = SWAGGER_SETTINGS$description,
    version = SETTINGS$version,
    contact = SWAGGER_SETTINGS$contact
  )

  return(x)
}
