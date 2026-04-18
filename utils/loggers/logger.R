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
    
    log_trace("Início da função setup_logger()")
    
    # -----------------------------------------------------
    # Leitura dos arquivos de configuração
    # -----------------------------------------------------
    config_paths   <- read_yaml_safe(here::here("config", "paths.yaml"))
    config_logging <- read_yaml_safe(here::here("config", "logging.yaml"))
    
    log_trace("Arquivos de configuração carregados com sucesso")
    
    # -----------------------------------------------------
    # Caminho do arquivo de log
    # -----------------------------------------------------
    log_path <- here::here(config_paths$logs$file)
    
    log_debug(glue("Caminho do arquivo de log: {log_path}"))
    
    # -----------------------------------------------------
    # Garante que o diretório de logs exista
    # -----------------------------------------------------
    if (!dir.exists(dirname(log_path))) {
      log_warn("Diretório de logs não existe. Criando automaticamente.")
    }
    
    dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)
    
    log_trace("Diretório de logs validado/criado")
    
    # -----------------------------------------------------
    # Define o nível de log (INFO, DEBUG, ERROR, etc.)
    # Conversão feita via função helper
    # -----------------------------------------------------
    level_str <- config_logging$logging$level
    
    log_debug(glue("Nível de log recebido do config: {level_str}"))
    
    level <- get_log_level(level_str)
    log_threshold(level)
    
    log_info(glue("Nível de log configurado para: {toupper(level_str)}"))
    
    # -----------------------------------------------------
    # Configuração de timezone para padronização dos logs
    # -----------------------------------------------------
    Sys.setenv(TZ = config_logging$format$timezone)
    
    log_debug(glue("Timezone configurado: {config_logging$format$timezone}"))
    
    # -----------------------------------------------------
    # Define o layout (formato) das mensagens de log
    # Exemplo: timestamp | nível | mensagem
    # -----------------------------------------------------
    
    log_trace("Configurando layout do logger")
    
    log_layout(logger::layout_glue_generator(
      format = config_logging$format$format
    ))
    
    log_debug("Layout do logger configurado com sucesso")
    
    # -----------------------------------------------------
    # Define se o arquivo será sobrescrito ou incrementado
    # -----------------------------------------------------
    append_mode <- !isTRUE(config_logging$logging$overwrite)
    
    if (!append_mode) {
      log_warn("Logs serão sobrescritos a cada execução (overwrite = TRUE)")
    } else {
      log_trace("Modo append ativado (logs acumulativos)")
    }
    
    # -----------------------------------------------------
    # Configuração dos destinos do log:
    #   - Console
    #   - Arquivo
    # -----------------------------------------------------
    log_trace("Configurando appenders (console/file)")
    
    if (isTRUE(config_logging$logging$console)) {
      
      log_debug("Logger configurado para console + arquivo")
      
      logger::log_appender(function(lines) {
        logger::appender_console(lines)
        logger::appender_file(log_path, append = append_mode)(lines)
      })
      
    } else {
      
      log_debug("Logger configurado apenas para arquivo")
      
      logger::log_appender(
        logger::appender_file(log_path, append = append_mode)
      )
    }
    
    # -----------------------------------------------------
    # Log final indicando sucesso na configuração
    # -----------------------------------------------------
    log_info(glue("Logger iniciado | file={log_path} | level={config_logging$logging$level}"))
    
    log_trace("Fim da função setup_logger()")
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro 
    # -----------------------------------------------------
    log_error(glue("Erro ao configurar logger: {e$message}"))
    
    log_fatal("Falha crítica na inicialização do logger")
    
    stop(e$message)
    
  })
}