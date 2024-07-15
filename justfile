# settings
port := "3333"
cran := "https://cloud.r-project.org"

r_s := if os_family() == "windows" {"Rscript.exe"} else {"Rscript"}

# run api tests with dev credentials
[group('test')]
test-dev:
    @cd test && {{r_s}} api_test.R

# run api tests with prod credentials
[group('test')]
test-prod:
    @cd test && {{r_s}} -e "dev_mode <- FALSE; source('api_test.R');"

# Install or update R packages for testing
[group('test')]
test-rpkg:
    @ cd test && {{r_s}} -e "options(repos = c(CRAN = '{{cran}}')); source('packages.R'); install.packages(packages());"
    @echo "Installed packages"

# Inititalize testing credentials files (backups existing files)
[group('test')]
test-init:
    @ cd test && {{r_s}} -e "source('credentials.R'); write_dev_cred(); write_prod_cred();"
    @echo "Created testing credentials files"





# run on port {{port}}
# [group('start')]
# run:
#     {{r}} -e "shiny::runApp(launch.browser = F, port={{port}})"

# # Installs or upgrades R packages
# [group('init')]
# rpkg:
#     {{r}} -e "options(repos = c(CRAN = '{{cran}}')); source('functions/packages.R'); install.packages(packages());"
#     @echo "Installed packages"

# # Inititalize settings.yaml file
# [group('init')]
# init:
#     {{r}} -e "source('functions/secrets.R'); create_settings_file();"
#     @echo "Created settings file"

# # initializes and updates pre-commit hooks
# [group('dev')]
# init-hooks:
#     {{r}} -e "options(repos = c(CRAN = '{{cran}}')); install.packages('precommit');"
#     pip3 install pre-commit --user
#     {{r}} -e "precommit::use_precommit();"
#     @echo "Installed pre-commit hooks. You don't need to do anything else !!"

# # auto restart on file change (needs watchexec)
# [group('dev')]
# watch:
#     watchexec -r "{{r}} -e 'shiny::runApp(launch.browser = F, port={{port}})'"
