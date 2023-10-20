# *******************************************************************
# Project: ABData API user management
# Script purpose: Signup user
# Date: 10-20-2023
# Author: Dominik Selzer (dominik.selzer@uni-saarland.de)
# *******************************************************************

library(glue)
library(curl)
library(purrr)
library(jsonlite)
library(mongolite)

# Functions ----
# *******************************************************************
create_users <- function(settings) {
  users <- read_user_json(settings$users)
  walk(users, \(x) {
    data <- list()
    data$name <- x$name
    data$email <- x$email
    data$password <- x$password
    data$username <- x$username
    signup_user(data$username, data$password, settings$userdb)
    send_mail(data, settings)
  })
}


show_users <- function(settings) {
  con <- mongo_userdb(settings)
  qry <- con$find('{}')
  con$disconnect()
  return(qry)
}


# Helper ----
# *******************************************************************
mongo_safely <- safely(mongo)
mongo_userdb <- function(settings) {
  con <- mongo_safely(collection = settings$collection,
                      db = settings$db,
                      url = settings$url)
  con <- con$result
  if (is.null(con)) {
    stop("Connection error")
  }
  return(con)
}


signup_user <- function(username, pw, settings) {
  con <- mongo_userdb(settings)
  hashed <- hashpw(pw)

  qry <- glue('{"username": "(username)", "password": "(password)"}',
              .open = "(", .close = ")",
              username = username, password = hashed)

  con$insert(qry)
  con$disconnect()
}

read_user_json <- function(file) {
  data <- read_json(file)
  map(data, \(x) {
    tmp <- list()
    tmp$name <- x$name
    tmp$email <- x$email
    tmp$password <- x$password
    tmp$username <- x$username
    tmp
  })
}


send_mail <- function(data, SETTINGS) {
  name <- data$name
  email <- data$email
  password <- data$password
  username <- data$username

  msg_template <-
    r"(From: "{SETTINGS$mail$from_name}" <{SETTINGS$mail$from}>
To: "{name}" <{email}>
Subject: {SETTINGS$mail$subject}
Content-Type: text/plain; charset=UTF-8

Dear {name},

We have registered an account to access the abdata API (https://abdata.clinicalpharmacy.me/api).

Your credentials are:
username: {username}
password: {password}

This is an automatically generated mail.
We will provide you with additional information on the usage of the API later on.
If you have any questions, please contact fatima.marok@uni-saarland.de.)"


  msg <- glue::glue(msg_template)
  dump <- curl::send_mail(
    mail_from = SETTINGS$mail$from,
    mail_rcpt = email,
    message = msg,
    smtp_server = SETTINGS$mail$host,
    username = SETTINGS$mail$username,
    password = SETTINGS$mail$password,
    use_ssl = ifelse(SETTINGS$mail$use_ssl, "force", "no"),
    verbose = TRUE
  )
  return(TRUE)
}
