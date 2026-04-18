# ----------------------------------------------------------------------
# Arquivo: standardization_data.R
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
# Descrição:
#   Responsável por padronizar os nomes das colunas do dataset
#   proveniente do banco de dados, aplicando um padrão semântico
#   consistente para uso nas etapas posteriores do pipeline.
#
# Objetivo:
#   - Melhorar legibilidade dos dados
#   - Padronizar nomenclatura (snake_case)
#   - Facilitar manutenção e integração com outras camadas
#
# Regra de negócio:
#   - Campos são renomeados para nomes mais descritivos
#   - Nenhuma transformação de valores é realizada aqui
#
# Entrada:
#   - data_db: data.frame/tibble com colunas originais do banco
#
# Saída:
#   - tibble com colunas padronizadas
# ----------------------------------------------------------------------
standardization_data <- function(data_db) {
  
  tryCatch({
    
    log_trace("Início da função standardization_data()")
    
    # -----------------------------------------------------
    # Validação de entrada
    # -----------------------------------------------------
    if (is.null(data_db) || nrow(data_db) == 0) {
      log_warn("Dataset vazio ou NULL recebido para padronização")
      return(data_db)
    }
    
    log_debug(glue("Quantidade de registros recebidos: {nrow(data_db)}"))
    
    # -----------------------------------------------------
    # Verificação de colunas esperadas
    # -----------------------------------------------------
    required_cols <- c(
      "vendas_id",
      "data_venda",
      "quantidade_vendida",
      "produto",
      "vendedor",
      "valor_venda",
      "valor_compra"
    )
    
    missing_cols <- setdiff(required_cols, colnames(data_db))
    
    if (length(missing_cols) > 0) {
      log_error(glue("Colunas ausentes: {paste(missing_cols, collapse=', ')}"))
      stop("Estrutura de dados inválida para padronização")
    }
    
    log_trace("Estrutura de colunas validada")
    
    # -----------------------------------------------------
    # Padronização de nomes das colunas
    # -----------------------------------------------------
    log_debug("Aplicando padronização de nomes das colunas")
    
    result <- data_db %>%
      rename(
        id_venda       = vendas_id,
        data           = data_venda,
        quantidade     = quantidade_vendida,
        nome_produto   = produto,
        nome_vendedor  = vendedor,
        preco_venda    = valor_venda,
        preco_compra   = valor_compra
      )
    
    # -----------------------------------------------------
    # Log de sucesso
    # -----------------------------------------------------
    log_info("Padronização de colunas concluída com sucesso")
    
    log_trace("Fim da função standardization_data()")
    
    return(result)
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro
    # -----------------------------------------------------
    log_error(glue("Erro na padronização de dados: {e$message}"))
    
    log_fatal("Falha crítica na etapa de transformação (standardization_data)")
    
    stop(glue("Erro na padronização: {e$message}"))
  })
}