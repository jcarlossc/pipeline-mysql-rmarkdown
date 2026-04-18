# ----------------------------------------------------------------------
# Arquivo: db_connection.R
# Pipeline baseado em R para consumo de banco de dados MySQL, 
# Exploração de Dados e relatório R Markdown
# Autor: Carlos da Costa
# Localização: Recife, Pernambuco - Brasil
# Data de criação: 17/04/2026
# Última modificação: 17/04/2026
# Versão: 1.0.0
# Ambiente: development
#
# ----------------------------------------------------------------------
# Módulo: Conexão com Banco de Dados
# Descrição:
#   Responsável por estabelecer conexão com o banco MySQL
#   utilizando configurações externas (YAML), garantindo
#   padronização, segurança e rastreabilidade via logs.
#
# Objetivo:
#   Centralizar a criação de conexões com o banco,
#   evitando hardcode de credenciais e facilitando manutenção.
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(DBI)
library(RMySQL)
library(yaml)
library(logger)
library(glue)

# ----------------------------------------------------------------------
# Função: get_db_connection
# Descrição:
#   Cria e retorna uma conexão ativa com o banco de dados
#   com base nas configurações definidas em arquivo YAML.
#
# Fluxo:
#   1. Valida existência do arquivo de configuração
#   2. Carrega parâmetros de conexão
#   3. Tenta estabelecer conexão via DBI
#   4. Loga sucesso ou falha
#
# Retorno:
#   - Objeto de conexão DBI válido
#
# ----------------------------------------------------------------------
get_db_connection <- function() {
  tryCatch({
    
    log_trace("Início da função get_db_connection()")
    
    # -----------------------------------------------------
    # Caminho do arquivo de configuração
    # -----------------------------------------------------
    config_db <- here::here("config", "db.yaml")
    
    log_debug(glue("Caminho do config: {config_db}"))
    
    # -----------------------------------------------------
    # Validação de existência do arquivo
    # -----------------------------------------------------
    if (!file.exists(config_db)) {
      log_error(glue("Arquivo não encontrado: {config_db}"))
      log_fatal("Falha crítica: configuração do banco ausente")
      stop("Arquivo de configuração não encontrado")
    }
    
    log_trace("Arquivo de configuração encontrado")
    
    # -----------------------------------------------------
    # Leitura das configurações do banco
    # Estrutura esperada: db: {host, port, name, user, password}
    # -----------------------------------------------------
    db_config <- yaml::read_yaml(config_db)$db
    
    log_debug("Configuração YAML carregada com sucesso")
    
    # -----------------------------------------------------
    # Validação de campos obrigatórios
    # -----------------------------------------------------
    required_fields <- c("host", "port", "name", "user", "password")
    missing <- setdiff(required_fields, names(db_config))
    
    if (length(missing) > 0) {
      log_error(glue("Campos ausentes no config: {paste(missing, collapse=', ')}"))
      stop("Configuração inválida do banco")
    }
    
    log_trace("Configuração do banco validada")
    
    # -----------------------------------------------------
    # Aviso de ambiente (exemplo de WARN útil)
    # -----------------------------------------------------
    if (db_config$host %in% c("localhost", "127.0.0.1")) {
      log_warn("Conectando em ambiente local (localhost)")
    }
    
    # -----------------------------------------------------
    # Log informativo (sem expor credenciais)
    # -----------------------------------------------------
    log_info(
      glue(
        "Tentando conectar ao banco {db_config$name} em {db_config$host}:{db_config$port}"
      )
    )
    
    # -----------------------------------------------------
    # Estabelece conexão com o banco via DBI
    # -----------------------------------------------------
    con <- DBI::dbConnect(
      RMySQL::MySQL(),
      host = db_config$host,
      port = db_config$port,
      dbname = db_config$name,
      user = db_config$user,
      password = db_config$password
    )
    
    log_debug("dbConnect executado sem erro")
    
    # -----------------------------------------------------
    # Log de sucesso
    # -----------------------------------------------------
    log_info("Conexão estabelecida com sucesso")
    
    log_trace("Fim da função get_db_connection()")
    
    return(con)
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro
    # -----------------------------------------------------
    log_error(glue("Erro na conexão: {e$message}"))
    
    log_fatal("Falha crítica ao conectar ao banco")
    
    stop(glue("Erro ao conectar ao banco: {e$message}")) 
    
  })
}