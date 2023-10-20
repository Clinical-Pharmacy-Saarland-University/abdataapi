source("create_user.R")

SETTINGS <- list(
  mail = list(
    enable = FALSE,
    subject = "CLinical Pharmacy Saarland University - abdata API Credentials",
    from = "",
    from_name = "",
    host = "",
    username = "",
    password = "",
    use_ssl = FALSE
  ),
  userdb = list(
    url = "mongodb://localhost:27017",
    db = "",
    collection = ""
  ),
  users = "users.json"
)

create_users(SETTINGS)
show_users(SETTINGS$userdb)
