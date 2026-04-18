# ----------------------------------------------------------------------
# Arquivo: metric_sales.R
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
#   Calcula métricas agregadas de vendas a partir de um dataset
#   já padronizado, incluindo volume, faturamento, custo e lucro.
#
# Objetivo:
#   - Consolidar indicadores-chave (KPIs)
#   - Suportar análises e dashboards
#   - Servir como camada semântica de negócio
#
# Métricas calculadas:
#   - total_vendas  : quantidade de registros (transações)
#   - total_itens   : soma de itens vendidos
#   - faturamento   : receita total (quantidade * preço venda)
#   - custo_total   : custo total (quantidade * preço compra)
#   - lucro         : faturamento - custo
#   - ticket_medio  : faturamento / total de vendas
#
# Entrada:
#   - data_metric: tibble/data.frame com colunas padronizadas
#
# Saída:
#   - tibble com métricas agregadas
#
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(dplyr)
library(glue)
library(logger)

metric_sales <- function(data_metric) {
  
  tryCatch({
    
    log_trace("Início da função metric_sales()")
    
    # -----------------------------------------------------
    # Validação de entrada
    # -----------------------------------------------------
    if (is.null(data_metric) || nrow(data_metric) == 0) {
      log_warn("Dataset vazio ou NULL recebido para cálculo de métricas")
      
      return(tibble::tibble(
        total_vendas = 0,
        total_itens = 0,
        faturamento = 0,
        custo_total = 0,
        lucro = 0,
        ticket_medio = 0
      ))
    }
    
    log_debug(glue("Quantidade de registros recebidos: {nrow(data_metric)}"))
    
    # -----------------------------------------------------
    # Validação de colunas obrigatórias
    # -----------------------------------------------------
    required_cols <- c("quantidade", "preco_venda", "preco_compra")
    
    missing_cols <- setdiff(required_cols, colnames(data_metric))
    
    if (length(missing_cols) > 0) {
      log_error(glue("Colunas ausentes: {paste(missing_cols, collapse=', ')}"))
      stop("Estrutura inválida para cálculo de métricas")
    }
    
    log_trace("Estrutura validada com sucesso")
    
    # -----------------------------------------------------
    # Cálculo das métricas
    # -----------------------------------------------------
    log_debug("Iniciando cálculo das métricas de vendas")
    
    result <- data_metric %>%
      summarise(
        total_vendas = n(),
        total_itens = sum(quantidade, na.rm = TRUE),
        faturamento = sum(quantidade * preco_venda, na.rm = TRUE),
        custo_total = sum(quantidade * preco_compra, na.rm = TRUE),
        lucro = faturamento - custo_total,
        ticket_medio = ifelse(total_vendas > 0, faturamento / total_vendas, 0)
      )
    
    # -----------------------------------------------------
    # Log de resultado (resumo)
    # -----------------------------------------------------
    log_info(
      glue(
        "Métricas calculadas | vendas={result$total_vendas} | faturamento={round(result$faturamento,2)}"
      )
    )
    
    log_trace("Fim da função metric_sales()")
    
    return(result)
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro
    # -----------------------------------------------------
    log_error(glue("Erro ao calcular métricas de vendas: {e$message}"))
    
    log_fatal("Falha crítica na etapa de métricas (metric_sales)")
    
    stop(glue("Erro nas métricas de vendas: {e$message}"))
  })
}
