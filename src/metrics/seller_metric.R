# ----------------------------------------------------------------------
# Arquivo: products_sales.R
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
#   Calcula métricas agregadas por vendedor, permitindo
#   análise de desempenho individual da equipe comercial.
#
# Objetivo:
#   - Identificar vendedores com maior volume de vendas
#   - Avaliar desempenho comercial
#   - Suportar rankings e dashboards de vendas
#
# Métricas calculadas:
#   - total_vendido : quantidade total de itens vendidos
#   - faturamento   : receita total gerada pelo vendedor
#
# Entrada:
#   - data_metric: tibble/data.frame com colunas padronizadas
#
# Saída:
#   - tibble ordenado por faturamento (decrescente)
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(dplyr)
library(glue)
library(logger)


metric_seller <- function(data_metric) {
  
  tryCatch({
    
    log_trace("Início da função metric_seller()")
    
    # -----------------------------------------------------
    # Validação de entrada
    # -----------------------------------------------------
    if (is.null(data_metric) || nrow(data_metric) == 0) {
      log_warn("Dataset vazio ou NULL recebido para métricas por vendedor")
      return(tibble::tibble())
    }
    
    log_debug(glue("Quantidade de registros recebidos: {nrow(data_metric)}"))
    
    # -----------------------------------------------------
    # Validação de colunas obrigatórias
    # -----------------------------------------------------
    required_cols <- c("nome_vendedor", "quantidade", "preco_venda")
    
    missing_cols <- setdiff(required_cols, colnames(data_metric))
    
    if (length(missing_cols) > 0) {
      log_error(glue("Colunas ausentes: {paste(missing_cols, collapse=', ')}"))
      stop("Estrutura inválida para métricas por vendedor")
    }
    
    log_trace("Estrutura de dados validada")
    
    # -----------------------------------------------------
    # Cálculo das métricas por vendedor
    # -----------------------------------------------------
    log_debug("Calculando métricas agregadas por vendedor")
    
    result <- data_metric %>%
      group_by(nome_vendedor) %>%
      summarise(
        total_vendido = sum(quantidade, na.rm = TRUE),
        faturamento   = sum(quantidade * preco_venda, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(faturamento))
    
    # -----------------------------------------------------
    # Log de resultado (resumo)
    # -----------------------------------------------------
    log_info(
      glue("Métricas por vendedor calculadas | vendedores={nrow(result)}")
    )
    
    # -----------------------------------------------------
    # Regra de alerta
    # -----------------------------------------------------
    if (nrow(result) == 0) {
      log_warn("Nenhum resultado gerado após agregação por vendedor")
    }
    
    # -----------------------------------------------------
    # Log adicional (top vendedor)
    # -----------------------------------------------------
    if (nrow(result) > 0) {
      log_debug(glue("Top vendedor: {result$nome_vendedor[1]}"))
    }
    
    log_trace("Fim da função metric_seller()")
    
    return(result)
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro
    # -----------------------------------------------------
    log_error(glue("Erro ao calcular métricas por vendedor: {e$message}"))
    
    log_fatal("Falha crítica na etapa de métricas por vendedor")
    
    stop(glue("Erro nas métricas por vendedor: {e$message}"))
  })
}