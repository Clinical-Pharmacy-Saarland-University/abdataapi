# ABDATA Database API

<!-- START_BADGES -->

[![Project Status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active/) [![Package version](https://img.shields.io/badge/Version-0.6.2-red.svg)](https://github.com/Clinical-Pharmacy-Saarland-University/nmrunner/) [![minimal R version](https://img.shields.io/badge/R%3E%3D-4.1.0-blue.svg)](https://cran.r-project.org/)

<!-- END_BADGES -->

## Description

This repository provides a RESTful API for the ABDATA DDI Checks.
The API is based on the plumber package and provides endpoints for the operations specified in [the manual](manual/manual.md).
This repository does **not** provide the ABDA data base.

## Requirements

1. The application should run on Windows and Linux.

2. To the start the application you need a runtime of at least `R Version 4.1`
   and packages listed in `src/helper/packages.R`.
3. Is is highly recommended to use the `just` command line tool to run the commands in the `justfile`. The `just` command line tool can be installed via the following command:

```bash
winget install just # windows
apt-get install just # linux
```

## Quick Start

Thse steps will install or update the necessary packages, initialize the application settings file and start the application.

```bash
just rpkg
just init
just start
```

After configuration via `secrets.json` you can also start the application via the following command:

```r
setwd("src")
source("start_api.R")
```

## Settings File

Provide `secrets.json` file in the `src` directory. The file should provide credentials for your data base instances in the following format:

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
    "collection": "user_collection",
    "db": "db_for_users",
    "url": "url_to_mongodb"
  },
  "log_db": {
    "collection": "logs_collection",
    "db": "db_for_logs",
    "url": "url_to_mongodb"
  },
  "token": {
    "token_salt": "token_salt"
  },
  "server": {
    "host": "host",
    "port": 0001
  }
}
```

## Management

**TODO**

## Developement

The following just commands are available for development:

```bash
just doc # render the index.html file from the manual.md in manual directory (needs `pandoc`)
just init-hooks # install git pre-commit hooks (needs python3 installed)
just watch # watch the src directory for changes and restart the api (needs `watchexec`)
```

Install `pandoc` and `watchexec` via the following commands in windows:

```bash
winget install pandoc
scoop install watchexec@2.0.0
```

## API Endpoint Tests

Test are implemented in the `tests` directory (file `api_test.R`).

1. Install test related `r` packages via the following command:

```bash
just test-rpkg
```

2. Initalize login credentatls and host information via:

```bash
just test-init
```

Edit the files `dev_credentials.yaml` and `prod_credentials.yaml` in the `tests` directory to provide the necessary information.

3. Tests for development and production environment can be run via the following commands:

```bash
just test-dev
just test-prod
```
