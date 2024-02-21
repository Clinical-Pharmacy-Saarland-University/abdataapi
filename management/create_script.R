source("create_user.R")

SETTINGS <- list(
  mail = list(
    enable = FALSE,
    subject = "CLinical Pharmacy Saarland University - abdata API Credentials",
    from = "dominik.selzer@uni-saarland.de",
    from_name = "Clinical Pharmacy Saarland University",
    host = "",
    username = "",
    password = "",
    use_ssl = FALSE
  ),
  userdb = list(
    url = "",
    db = "",
    collection = ""
  ),
  users = "users_roman.json"
)

create_users(SETTINGS)
show_users(SETTINGS$userdb)
