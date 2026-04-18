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
#   Centraliza o tratamento de erros do pipeline, garantindo:
#     - Logging estruturado
#     - Fallback seguro caso logger falhe
#     - Interrupção controlada da execução
#
# Parâmetros:
#   e (condition): objeto de erro capturado (tryCatch)
#   step (character): etapa do pipeline onde ocorreu o erro
#
# Retorno:
#   Não retorna (interrompe execução com stop)
#
# Observação:
#   Deve ser utilizada dentro de blocos tryCatch
# ------------------------------------------------------------

# --------------------------------------------------------
# Função responsável pela centralização de erros
# --------------------------------------------------------
handle_error <- function(e, step = "DESCONHECIDO") {
  
  tryCatch({
    
    log_trace("Início da função handle_error()")
    
    # --------------------------------------------------------
    # Validação de entrada
    # --------------------------------------------------------
    if (!inherits(e, "error")) {
      log_warn("Objeto recebido não é da classe 'error'")
      stop("Objeto passado não é um erro válido")
    }
    
    log_debug(glue("Erro capturado na etapa: {step}"))
    
    # --------------------------------------------------------
    # Construção da mensagem de erro
    # --------------------------------------------------------
    msg_step  <- glue("Erro na etapa: {step}")
    msg_error <- glue("Mensagem original: {e$message}")
    
    # --------------------------------------------------------
    # Registro no logger
    # --------------------------------------------------------
    log_error(msg_step)
    log_error(msg_error)
    
    # ----------------------------------------------------------
    # Contexto adicional (útil para debug)
    # ----------------------------------------------------------
    if (!is.null(conditionCall(e))) {
      log_debug(glue("Call: {deparse(conditionCall(e))}"))
    }
    
    if (!is.null(conditionMessage(e))) {
      log_trace(glue("Detalhe completo: {conditionMessage(e)}"))
    }
    
    log_trace("Fim do registro de erro no logger")
    
  }, error = function(log_err) {
    
    message("[FALLBACK_LOG] Falha ao registrar no logger")
    message(glue("Detalhe logger: {log_err$message}"))
    message(glue("Erro original: {e$message}"))
  })
  
  # ----------------------------------------------------------
  # Interrupção controlada
  # ----------------------------------------------------------
  log_fatal(glue("Interrompendo execução | etapa={step}"))
  
  stop(glue(
    "[PIPELINE_ERROR] Etapa: {step} | Mensagem: {e$message}"
  ))
}