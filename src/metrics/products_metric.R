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
#   Calcula métricas agregadas por produto, permitindo análise
#   de desempenho individual (vendas, faturamento e lucro).
#
# Objetivo:
#   - Identificar produtos mais vendidos
#   - Avaliar rentabilidade por produto
#   - Suportar análises e dashboards (ranking)
#
# Métricas calculadas:
#   - total_vendido : soma da quantidade vendida por produto
#   - faturamento   : receita total por produto
#   - lucro         : lucro total por produto
#
# Entrada:
#   - data_metric: tibble/data.frame com colunas padronizadas
#
# Saída:
#   - tibble ordenado por faturamento (decrescente)
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(dplyr)
library(glue)
library(logger)

metric_products <- function(data_metric) {
  
  tryCatch({
    
    log_trace("Início da função metric_products()")
    
    # -----------------------------------------------------
    # Validação de entrada
    # -----------------------------------------------------
    if (is.null(data_metric) || nrow(data_metric) == 0) {
      log_warn("Dataset vazio ou NULL recebido para métricas por produto")
      return(tibble::tibble())
    }
    
    log_debug(glue("Quantidade de registros recebidos: {nrow(data_metric)}"))
    
    # -----------------------------------------------------
    # Validação de colunas obrigatórias
    # -----------------------------------------------------
    required_cols <- c("nome_produto", "quantidade", "preco_venda", "preco_compra")
    
    missing_cols <- setdiff(required_cols, colnames(data_metric))
    
    if (length(missing_cols) > 0) {
      log_error(glue("Colunas ausentes: {paste(missing_cols, collapse=', ')}"))
      stop("Estrutura inválida para métricas por produto")
    }
    
    log_trace("Estrutura validada com sucesso")
    
    # -----------------------------------------------------
    # Cálculo das métricas por produto
    # -----------------------------------------------------
    log_debug("Calculando métricas agregadas por produto")
    
    result <- data_metric %>%
      group_by(nome_produto) %>%
      summarise(
        total_vendido = sum(quantidade, na.rm = TRUE),
        faturamento   = sum(quantidade * preco_venda, na.rm = TRUE),
        lucro         = sum((preco_venda - preco_compra) * quantidade, na.rm = TRUE),
        .groups = "drop"
      ) %>%
      arrange(desc(faturamento))
    
    # -----------------------------------------------------
    # Log de resultado (resumo)
    # -----------------------------------------------------
    log_info(
      glue(
        "Métricas por produto calculadas | produtos={nrow(result)}"
      )
    )
    
    # -----------------------------------------------------
    # Regra de alerta (resultado vazio após agregação)
    # -----------------------------------------------------
    if (nrow(result) == 0) {
      log_warn("Nenhum resultado gerado após agregação por produto")
    }
    
    log_trace("Fim da função metric_products()")
    
    return(result)
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro
    # -----------------------------------------------------
    log_error(glue("Erro ao calcular métricas por produto: {e$message}"))
    
    log_fatal("Falha crítica na etapa de métricas por produto")
    
    stop(glue("Erro nas métricas por produto: {e$message}"))
  })
}