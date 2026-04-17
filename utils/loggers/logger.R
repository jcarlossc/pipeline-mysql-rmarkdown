# ----------------------------------------------------------------------
# Arquivo: error_handler.R
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
# Módulo: Logger
# Descrição:
#   Responsável por inicializar e configurar o sistema de logs
#   da aplicação de forma centralizada, utilizando arquivos
#   de configuração YAML.
#
# Funcionalidades:
#   - Leitura de configurações externas (paths e logging)
#   - Definição de nível de log dinâmico
#   - Configuração de timezone
#   - Customização do formato das mensagens
#   - Escrita de logs em arquivo e/ou console
#   - Criação automática do diretório de logs
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(glue)
library(yaml)
library(here)
library(logger)

# ----------------------------------------------------------------------
# Carrega funções auxiliares (ex: get_log_level)
# ----------------------------------------------------------------------
source(here::here("utils/helper/helpers.R"))

# ----------------------------------------------------------------------
# Função: setup_logger
# Descrição:
#   Inicializa o sistema de logs da aplicação com base
#   nos arquivos de configuração.
#
# Retorno:
#   Não retorna valor. Configura o logger global.
# ----------------------------------------------------------------------
setup_logger <- function() {
  
  tryCatch({
    
    # -----------------------------------------------------
    # Leitura dos arquivos de configuração
    # -----------------------------------------------------
    config_paths   <- read_yaml_safe(here::here("config", "paths.yaml"))
    config_logging <- read_yaml_safe(here::here("config", "logging.yaml"))
    
    # -----------------------------------------------------
    # Caminho do arquivo de log
    # -----------------------------------------------------
    log_path <- here::here(config_paths$logs$file)
    
    # -----------------------------------------------------
    # Garante que o diretório de logs exista
    # -----------------------------------------------------
    dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)
    
    # -----------------------------------------------------
    # Define o nível de log (INFO, DEBUG, ERROR, etc.)
    # Conversão feita via função helper
    # -----------------------------------------------------
    level <- get_log_level(config_logging$logging$level)
    log_threshold(level)
    
    # -----------------------------------------------------
    # Configuração de timezone para padronização dos logs
    # -----------------------------------------------------
    Sys.setenv(TZ = config_logging$format$timezone)
    
    # -----------------------------------------------------
    # Define o layout (formato) das mensagens de log
    # Exemplo: timestamp | nível | mensagem
    # -----------------------------------------------------
    log_layout(logger::layout_glue_generator(
      format = config_logging$format$format
    ))
    
    # -----------------------------------------------------
    # Define se o arquivo será sobrescrito ou incrementado
    # -----------------------------------------------------
    append_mode <- !isTRUE(config_logging$logging$overwrite)
    
    # -----------------------------------------------------
    # Configuração dos destinos do log:
    #   - Console
    #   - Arquivo
    # -----------------------------------------------------
    if (isTRUE(config_logging$logging$console)) {
      
      logger::log_appender(function(lines) {
        logger::appender_console(lines)
        logger::appender_file(log_path, append = append_mode)(lines)
      })
      
    } else {
      
      logger::log_appender(
        logger::appender_file(log_path, append = append_mode)
      )
    }
    
    # -----------------------------------------------------
    # Log inicial indicando sucesso na configuração
    # -----------------------------------------------------
    log_info(glue("Logger iniciado | file={log_path} | level={config_logging$logging$level}"))
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro na inicialização do logger
    # -----------------------------------------------------
    message(glue("Erro no logger: {e$message}"))
    stop(e$message)
    
  })
}