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
  
  # --------------------------------------------------------
  # Validação dos parâmetros
  # --------------------------------------------------------
  if (!is.function(func)) {
    stop("Parâmetro 'func' deve ser uma função.")
  }
  
  if (attempts <= 0) {
    stop("Parâmetro 'attempts' deve ser maior que zero.")
  }
  
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
        stop(e)
      }
      
      # Retorna NULL para indicar falha controlada
      return(NULL)
    })
    
    # --------------------------------------------------------
    # Se execução bem-sucedida, retorna resultado
    # --------------------------------------------------------
    if (!is.null(result)) {
      log_info("Execução bem-sucedida.")
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
  
  if (!file.exists(path)) {
    stop(glue("Arquivo não encontrado: {path}"))
  }
  
  yaml::read_yaml(path)
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
  
  level <- levels[[toupper(level_str)]]
  
  if (is.null(level)) {
    stop(glue("Nível de log inválido: {level_str}"))
  }
  
  level
}