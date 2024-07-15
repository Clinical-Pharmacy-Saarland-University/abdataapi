# settings
cran := "https://cloud.r-project.org"
r_s := if os_family() == "windows" {"Rscript.exe"} else {"Rscript"}

# Runs the api server
[group('start')]
run:
    @ cd src && {{r_s}} start_api.R

# Creates secrets.json settings file (backups existing file)
[group('init')]
init:
    @ cd src && {{r_s}} -e "source('helper/secret.R'); create_secret_file('secrets.json');"
    @echo "Created settings file"

# Installs or updates R packages
[group('init')]
rpkg:
    @ cd src && {{r_s}} -e "options(repos = c(CRAN = '{{cran}}')); source('helper/packages.R'); install.packages(packages());"
    @echo "Installed packages"

# Runs api tests with dev credentials
[group('test')]
test-dev:
    @cd test && {{r_s}} api_test.R

# Runs api tests with prod credentials
[group('test')]
test-prod:
    @cd test && {{r_s}} -e "dev_mode <- FALSE; source('api_test.R');"

# Installs or updates R packages for testing
[group('test')]
test-rpkg:
    @ cd test && {{r_s}} -e "options(repos = c(CRAN = '{{cran}}')); source('packages.R'); install.packages(packages());"
    @echo "Installed packages"

# Inititalizes testing credentials files (backups existing files)
[group('test')]
test-init:
    @ cd test && {{r_s}} -e "source('credentials.R'); write_dev_cred(); write_prod_cred();"
    @echo "Created testing credentials files"


# Inititalizes and updates pre-commit hooks
[group('dev')]
init-hooks:
    @ cd test && {{r_s}} -e "options(repos = c(CRAN = '{{cran}}')); install.packages('precommit');"
    @ pip3 install pre-commit --user
    @ cd test && {{r_s}} -e "precommit::use_precommit();"
    @echo "Installed pre-commit hooks. You don't need to do anything else !!"

# Renders the manual to /src/www from /manual/manual.md
[group('dev')]
doc:
    @ pandoc -c style.css -s ./manual/manual.md -H ./manual/header.html -o ./src/www/index.html
    @echo "Rendered manual to src/www/index.html"

# Starts and auto restarts the api server on file changes
[group('dev')]
watch:
    @ watchexec -r "cd src && {{r_s}} start_api.R"
