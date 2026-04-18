# ----------------------------------------------------------------------
# Arquivo: helpers.R
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
# Descrição:
#   Conjunto de funções auxiliares responsáveis por:
#     - Execução resiliente com retry manual
#     - Leitura segura de arquivos YAML
#     - Conversão de níveis de log para o pacote logger
#
# Objetivo:
#   Centralizar comportamentos críticos reutilizáveis,
#   garantindo robustez, padronização e rastreabilidade.
#
# Dependências:
#   - logger
#   - glue
#   - yaml
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(logger)
library(glue)
library(yaml)

# ----------------------------------------------------------------------
# Função: retry_manual
# Descrição:
#   Executa uma função com política de retry controlada.
#
# Parâmetros:
#   - func     : função a ser executada
#   - attempts : número máximo de tentativas
#   - wait     : tempo de espera (em segundos) entre tentativas
#
# Regras de negócio:
#   - Erros contendo "VALIDATION_ERROR" NÃO devem ser reprocessados
#   - Falhas são logadas com nível WARN
#   - Sucesso encerra imediatamente o loop
#
# Retorno:
#   - Resultado da função executada com sucesso
#   - Erro caso todas as tentativas falhem
# ----------------------------------------------------------------------
retry_manual <- function(func, attempts, wait) {
  
  log_trace("Início da função retry_manual()")
  
  # --------------------------------------------------------
  # Validação dos parâmetros
  # --------------------------------------------------------
  if (!is.function(func)) {
    log_error("Parâmetro 'func' inválido (não é função)")
    stop("Parâmetro 'func' deve ser uma função.")
  }
  
  if (attempts <= 0) {
    log_error("Parâmetro 'attempts' inválido")
    stop("Parâmetro 'attempts' deve ser maior que zero.")
  }
  
  log_debug(glue("Retry configurado | attempts={attempts} | wait={wait}s"))
  
  # --------------------------------------------------------
  # Loop de tentativas
  # --------------------------------------------------------
  for (i in 1:attempts) {
    
    log_info(glue("Tentativa {i} de {attempts}"))
    
    # --------------------------------------------------------
    # Execução protegida com tratamento de erro
    # --------------------------------------------------------
    result <- tryCatch({
      
      # Executa a função fornecida
      func()
      
    }, error = function(e) {
      
      log_warn(glue("Erro na tentativa {i}: {e$message}"))
      
      # --------------------------------------------------------
      # Regra de negócio:
      # Não realizar retry para erros de validação
      # --------------------------------------------------------
      if (grepl("VALIDATION_ERROR", e$message)) {
        log_error("Erro de validação detectado - abortando retries")
        stop(e)
      }
      
      # Retorna NULL para indicar falha controlada
      return(NULL)
    })
    
    # --------------------------------------------------------
    # Se execução bem-sucedida, retorna resultado
    # --------------------------------------------------------
    if (!is.null(result)) {
      log_info(glue("Execução bem-sucedida na tentativa {i}"))
      log_trace("Fim da função retry_manual()")
      return(result)
    }
    
    # --------------------------------------------------------
    # Aguarda antes da próxima tentativa
    # --------------------------------------------------------
    if (i < attempts) {
      log_info(glue("Aguardando {wait}s antes da próxima tentativa"))
      Sys.sleep(wait)
    }
  }
  
  # --------------------------------------------------------
  # Se todas as tentativas falharem, lança erro final
  # --------------------------------------------------------
  log_error(glue("Todas as {attempts} tentativas falharam"))
  
  log_fatal("Falha definitiva após retries")
  
  stop(glue("Falha após {attempts} tentativas"))
}


# ---------------------------------------------------------
# Função: read_yaml_safe
# Descrição:
#   Realiza leitura segura de arquivos YAML com validação
#   de existência do arquivo.
#
# Parâmetros:
#   - path : caminho do arquivo YAML
#
# Retorno:
#   - Lista com conteúdo do YAML
#
# Erros:
#   - Lança erro se o arquivo não existir
# ---------------------------------------------------------
read_yaml_safe <- function(path) {
  
  log_trace(glue("Lendo arquivo YAML: {path}"))
  
  if (!file.exists(path)) {
    log_error(glue("Arquivo não encontrado: {path}"))
    stop(glue("Arquivo não encontrado: {path}"))
  }
  
  result <- tryCatch({
    
    yaml::read_yaml(path)
    
  }, error = function(e) {
    
    log_error(glue("Erro ao ler YAML: {e$message}"))
    stop(glue("Erro ao ler YAML: {e$message}"))
  })
  
  log_debug("YAML carregado com sucesso")
  
  return(result)
}


# ---------------------------------------------------------
# Função: get_log_level
# Descrição:
#   Converte uma string de nível de log (configuração externa)
#   para o formato reconhecido pelo pacote logger.
#
# Parâmetros:
#   - level_str : nível em formato string (ex: "INFO", "DEBUG")
#
# Retorno:
#   - Constante de nível do logger
#
# Erros:
#   - Lança erro caso o nível informado seja inválido
# ---------------------------------------------------------
get_log_level <- function(level_str) {
  
  levels <- list(
    TRACE = TRACE,
    DEBUG = DEBUG,
    INFO  = INFO,
    WARN  = WARN,
    ERROR = ERROR,
    FATAL = FATAL
  )
  
  level_key <- toupper(trimws(level_str))
  
  level <- levels[[level_key]]
  
  if (is.null(level)) {
    log_error(glue("Nível de log inválido: {level_str}"))
    stop(glue("Nível de log inválido: {level_str}"))
  }
  
  log_debug(glue("Nível de log convertido: {level_key}"))
  
  return(level)
}


# ---------------------------------------------------------
# Função: safe_run
# Descrição:
#    A função safe_run é um wrapper de execução segura responsável por 
# encapsular chamadas de funções críticas dentro de um mecanismo 
# padronizado de tratamento de erros e avisos.
#
# Parâmetros:
#   - expr → expressão a ser executada
#   - step → identificador da etapa (usado em logs)
#
# Retorno:
#   - O safe_run retorna exatamente o resultado da expressão (expr)
#
# Erros:
#   - Erros (error)
#       registra log com nível ERROR
#       inclui o nome da etapa (step)
#       interrompe a execução com stop()
# Avisos (warning)
#       registra log com nível WARN
#       evita poluição do console com muffleWarning
# ---------------------------------------------------------
safe_run <- function(expr, step) {
  tryCatch(
    expr,
    error = function(e) {
      logger::log_error(glue::glue("❌ Erro na etapa [{step}]: {e$message}"))
      stop(e)
    },
    warning = function(w) {
      logger::log_warn(glue::glue("⚠️ Aviso na etapa [{step}]: {w$message}"))
      invokeRestart("muffleWarning")
    }
  )
}