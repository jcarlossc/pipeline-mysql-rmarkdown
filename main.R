# ----------------------------------------------------------------------
# Arquivo: main.R
# Pipeline baseado em R para consumo de banco de dados MySQL, 
# Exploração de Dados e relatório R Markdown
# Autor: Carlos da Costa
# Localização: Recife, Pernambuco - Brasil
# Data de criação: 18/04/2026
# Última modificação: 18/04/2026
# Versão: 1.0.0
# Ambiente: development
#
# ----------------------------------------------------------------------
# MAIN - PIPELINE DE ANÁLISE EXPLORATÓRIA
#
# Responsável por:
# - Orquestrar execução do pipeline
# - Gerenciar configuração (YAML)
# - Controlar logs
# - Tratar erros globais
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(yaml)
library(here)
library(dbplyr)
library(logger)
library(glue)
library(DBI)

# ----------------------------------------------------------
# Carregar helpers essenciais
# ----------------------------------------------------------
source(here::here("utils/helper/helpers.R"))

# ----------------------------------------------------------
# Função principal
# ----------------------------------------------------------
main <- function() {
  
  tryCatch({
    
    # ----------------------------------------------------------
    # Configurações
    # ----------------------------------------------------------
    log_info("Carregando configurações...")
    
    config_paths <- safe_run(
      read_yaml_safe(here::here("config", "paths.yaml")),
      "LOAD_CONFIG_PATHS"
    )
    
    config_database <- safe_run(
      read_yaml_safe(here::here("config", "config.yaml")),
      "LOAD_CONFIG_DATABASE"
    )
    
    config_retry <- safe_run(
      read_yaml_safe(here::here("config", "config.yaml")),
      "LOAD_CONFIG_RETRY"
    )
    
    # ----------------------------------------------------------
    # Módulos
    # ----------------------------------------------------------
    log_info("Carregando módulos...")
    
    safe_run(source(here::here(config_paths$utils$helper)), "LOAD_HELPERS")
    safe_run(source(here::here(config_paths$utils$logger)), "LOAD_LOGGER")
    safe_run(source(here::here(config_paths$src$database)), "LOAD_DATABASE")
    safe_run(source(here::here(config_paths$src$data_access)), "LOAD_DATA_ACCESS")
    safe_run(source(here::here(config_paths$src$standardization)), "LOAD_STANDARDIZATION")
    safe_run(source(here::here(config_paths$src$sales)), "LOAD_SALES")
    safe_run(source(here::here(config_paths$src$products)), "LOAD_PRODUCTS")
    safe_run(source(here::here(config_paths$src$seller)), "LOAD_SELLER")
    
    # ----------------------------------------------------------
    # Logger
    # ----------------------------------------------------------
    safe_run(setup_logger(), "SETUP_LOGGER")
    
    log_info("Pipeline iniciado")
    
    # ----------------------------------------------------------
    # Retry config
    # ----------------------------------------------------------
    retries <- config_retry$database$retries
    timeout <- config_retry$database$timeout
    
    log_debug(glue::glue("Retry | tentativas={retries} | timeout={timeout}s"))
    
    # ----------------------------------------------------------
    # Conexão
    # ----------------------------------------------------------
    log_info("Conectando ao banco...")
    
    con <- safe_run(
      retry_manual(function() get_db_connection(), retries, timeout),
      "DB_CONNECTION"
    )
    
    log_info("Conexão estabelecida")
    
    # fechamento seguro
    on.exit({
      logger::log_info("Encerrando conexão...")
      DBI::dbDisconnect(con)
    }, add = TRUE)
    
    # ----------------------------------------------------------
    # Extração
    # ----------------------------------------------------------
    log_info("Extraindo dados...")
    
    data_tibble <- safe_run(
      get_tables(con, config_database),
      "DATA_EXTRACTION"
    )
    
    log_debug(glue::glue("Linhas extraídas: {nrow(data_tibble)}"))
    
    # ----------------------------------------------------------
    # Transformação
    # ----------------------------------------------------------
    log_info("Padronizando dados...")
    
    data_standardized <- safe_run(
      standardization_data(data_tibble),
      "DATA_STANDARDIZATION"
    )
    
    # ----------------------------------------------------------
    # Métricas
    # ----------------------------------------------------------
    log_info("Calculando métricas...")
    
    sales <- safe_run(
      metric_sales(data_standardized),
      "METRIC_SALES"
    )
    
    products <- safe_run(
      metric_products(data_standardized),
      "METRIC_PRODUCTS"
    )
    
    seller <- safe_run(
      metric_seller(data_standardized),
      "METRIC_SELLER"
    )
    
    # ----------------------------------------------------------
    # Consolidação
    # ----------------------------------------------------------
    log_info("Consolidando KPIs...")
    
    kpis <- list(
      sales = sales,
      products = products,
      seller = seller
    )
      
    log_info("Pipeline encerrado com sucesso")

    return(kpis)
    
  },
  
  # ----------------------------------------------------------
  # Erro global
  # ----------------------------------------------------------
  error = function(e) {
    
    log_error(glue::glue("Erro crítico no pipeline: {e$message}"))
    
    if (file.exists("utils/error_handler.R")) {
      source("utils/error_handler.R")
      handle_error(e, step = "MAIN_PIPELINE")
    }
    
    stop(e)
  },
  
  # ----------------------------------------------------------
  # Warning global
  # ----------------------------------------------------------
  warning = function(w) {
    
    log_warn(glue::glue("Aviso global: {w$message}"))
    invokeRestart("muffleWarning")
  }
  
  )
}

main()