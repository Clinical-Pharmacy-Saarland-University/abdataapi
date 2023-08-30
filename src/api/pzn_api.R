# *******************************************************************
# Project: ABDATA DDI API
# Script purpose: PZN API functionality
# Date: 08-28-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

# list or NULL on error
api_pzn_interactions <- function(pzns) {
  ret <- pzn_interactions(pzns)
  if (is.null(ret)) {
    return(NULL)
  }

  ret <- tag_result(ret)
  ret$pzns <- pzns

  return(ret)
}

# 03967062,03041347,17145955,00592733,13981502


schema <- '{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "patient_id": {
        "type": "string"
      },
      "pzns": {
        "type": "array",
        "items": {
          "anyOf": [
            {"type": "string"},
            {"type": "number"}
          ]
        },
        "minItems": 1,
        "uniqueItems": true,
      }
    },
    "required": ["patient_id", "pzns"]
  }
}'


validate_json <- function(json_str, schema) {
  tryCatch(
    {
      json_validate(json_str, schema)
      return("JSON is valid.")
    },
    error = function(e) {
      return(paste("Validation error:", e$message))
    }
  )
}


# returns the json object throws on error
read_pzn_json <- function(body_data) {
  data <- safe_fromJson(body_data)
  if (is.null(data$result)) {
    stop("Posted data is not valid JSON.")
  }

  data <- data$result
}
