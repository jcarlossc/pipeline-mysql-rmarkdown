library(yaml)
library(here)
library(dbplyr)
library(logger)

source("utils/helper/helpers.R")

config_paths <- read_yaml_safe(here::here("config", "paths.yaml"))
config_database <- read_yaml_safe(here::here("config", "config.yaml"))
config_retry <- read_yaml_safe(here::here("config", "config.yaml"))

source(here(config_paths$utils$helper))
source(here(config_paths$src$database))
source(here(config_paths$utils$logger))
source(here(config_paths$src$data_access))
source(here(config_paths$src$standardization))
source(here(config_paths$src$sales))
source(here(config_paths$src$products))
source(here(config_paths$src$seller))

setup_logger()

retries <- config_retry$database$retries
timeout <- config_retry$database$timeout

con <- retry_manual(function() get_db_connection(), retries, timeout)
data_tibble <- get_tables(con, config_database)
data_tibble

on.exit(DBI::dbDisconnect(con))
