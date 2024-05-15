# abdataapi

## Description
This repository provides a RESTful API for the ABDATA DDI Checks.
The API is based on the plumber package and provides endpoints for the operations specified in [the manual](manual/manual.md).
This repository does **not** provide the ABDA data base.

##  Requirements

1. The application should run on Windows and Linux.

2. To the start the application you need a runtime of at least `R Version 4.1` and the following CRAN-hosted libraries installed:

3. Provide *secrets.json* file in the *src* directory. The file should provide credentials for your data base instances in the following format:
```json
{
  "sql": {
    "host": "db_host",
    "user": "db_user",
    "pwd": "db_pwd",
    "port": 0000,
    "database": "db_name"
  },
  "userdb": {
    "collection": "users",
    "db": "abdata",
    "url": "mongodb://localhost:27017"
  },
   "log_db": {
    "collection": "logs_collection",
    "db": "db_for_logs",
    "url": "url_to_mongodb"
  },
  "token": {
    "token_salt": "token_salt"
  },
  "server" : {
    "host" : "host",
    "port" : 0001
  }
}
```

```r
install.packages(c("plumber", "dplyr", "purrr", "tidyr", "glue", "jsonlite", "jsonvalidate",
    "DBI", "RMySQL", "pool", "promises", "future", "bcrypt",
    "jose", "mongolite", "httpproblems")
```

## Application Start

After configuration you can start the application via the following command:
```r
setwd("src") # or manually set the working directory to the src folder in RStudio
source("start_api.R")
```
