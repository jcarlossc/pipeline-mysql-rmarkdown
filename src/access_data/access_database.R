# ----------------------------------------------------------------------
# Arquivo: access_database.R
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
#   Responsável por consultar, integrar e materializar dados
#   provenientes de múltiplas tabelas no banco de dados,
#   utilizando operações lazy (dbplyr) para otimização.
#
# Objetivo:
#   - Centralizar lógica de joins entre tabelas
#   - Minimizar transferência de dados (processamento no banco)
#   - Garantir rastreabilidade via logging
# ----------------------------------------------------------------------

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(dplyr)
library(tibble)
library(logger)
library(glue)

# ----------------------------------------------------------------------
# Função: get_tables
# Descrição:
#   Realiza a leitura e junção de tabelas do banco de dados
#   com base em configurações externas, retornando um dataset
#   consolidado pronto para análise.
#
# Parâmetros:
#   - con    : conexão ativa com o banco (DBI)
#   - config : lista de configuração contendo nomes das tabelas
#
# Fluxo:
#   1. Lê nomes das tabelas do config
#   2. Cria referências lazy (sem executar query)
#   3. Realiza joins no banco (inner_join)
#   4. Executa collect() (materializa em memória)
#   5. Aplica transformações finais
#
# Retorno:
#   - Tibble com dados consolidados
#
# Observação:
#   - Joins são executados no banco (melhor performance)
#   - collect() traz dados para memória local
# ----------------------------------------------------------------------
get_tables <- function(con, config) {
  tryCatch({
    
    log_trace("Entrando na função get_tables()")
    
    # -----------------------------------------------------
    # Leitura dos nomes das tabelas a partir da configuração
    # -----------------------------------------------------
    log_debug("Lendo nomes das tabelas do config")
    
    produto_name  <- config$tables$produto
    vendas_name   <- config$tables$vendas
    vendedor_name <- config$tables$vendedor
    
    log_info(glue("Carregando tabelas: {produto_name}, {vendas_name}, {vendedor_name}"))
    
    # -----------------------------------------------------
    # Criação de tabelas lazy (sem execução imediata)
    # dbplyr traduz operações para SQL posteriormente
    # -----------------------------------------------------
    produto   <- tbl(con, produto_name)
    vendas    <- tbl(con, vendas_name)
    vendedor  <- tbl(con, vendedor_name)
    
    log_debug("Tabelas carregadas (lazy)")
    
    # -----------------------------------------------------
    # Construção da query via dplyr (executada no banco)
    # Evita trazer dados desnecessários para memória
    # -----------------------------------------------------
    log_trace("Iniciando joins entre tabelas")
    
    result <- vendas %>%
      inner_join(produto, by = "produto_id") %>%
      inner_join(vendedor, by = "vendedor_id")
    
    log_debug("Joins realizados com sucesso")
    
    # -----------------------------------------------------
    # Materialização dos dados (execução real da query)
    # A partir daqui os dados estão em memória local
    # -----------------------------------------------------
    log_trace("Executando collect() no banco")
    
    result <- result %>%
      collect() %>%
      as_tibble() %>%
      mutate(across(where(is.numeric), ~ round(.x, 2)))
    
    # -----------------------------------------------------
    # Logging de resultado
    # -----------------------------------------------------
    log_info(glue("Consulta finalizada. Total de registros: {nrow(result)}"))
    
    # -----------------------------------------------------
    # Regra de alerta: dataset vazio
    # -----------------------------------------------------
    if (nrow(result) == 0) {
      log_warn("A consulta retornou 0 registros")
    }
    
    log_trace("Saindo da função get_tables()")
    
    return(result)
    
  }, error = function(e) {
    
    # -----------------------------------------------------
    # Tratamento de erro
    # -----------------------------------------------------
    log_error(glue("Erro ao buscar dados: {e$message}"))
    
    log_fatal("Falha crítica na função get_tables()")
    
    stop(glue("Erro ao buscar dados: {e$message}"))
  })
}