# ----------------------------------------------------------------------
# Arquivo: app.R
# Pipeline baseado em R para consumo de banco de dados MySQL, 
# Exploração de Dados e relatório R Markdown
# Autor: Carlos da Costa
# Localização: Recife, Pernambuco - Brasil
# Data de criação: 19/04/2026
# Última modificação: 20/04/2026
# Versão: 1.0.0
# Ambiente: development
#
# ----------------------------------------------------------------------
# Descrição: 
#   Dashboard interativo desenvolvido com Shiny, com o 
#   objetivo de explorar e analisar o desempenho de vendas em tempo 
#   real, a partir de um pipeline de dados estruturado em R.
#
#   A aplicação permite a visualização dinâmica de indicadores 
#   estratégicos, incluindo faturamento, lucro e ticket médio, 
#   além de análises detalhadas por produto e por vendedor.
# ----------------------------------------------------------------------  

# ----------------------------------------------------------------------
# Pacotes utilizados
# ----------------------------------------------------------------------
library(shiny)
library(dplyr)
library(here)
library(ggplot2)
library(scales)
library(shinydashboard)
library(logger)

# --------------------------------------------------------
# Importe do arquivo main
# --------------------------------------------------------
source(here("main.R"))

# --------------------------------------------------------
# Retorno do arquivo main
# --------------------------------------------------------
kpis <- main()

# Métricas de vendas
sales <- kpis$sales
# Métricas de produtos
products <- kpis$products
# Métricas dos vendedores
seller <- kpis$seller

log_info("Início da geração do DashBoard")

# --------------------------------------------------------
# Função padrão real(Br)
# --------------------------------------------------------
format_real <- function(x) {
  scales::label_dollar(
    prefix = "R$ ",
    big.mark = ".",
    decimal.mark = ","
  )(x)
}

# --------------------------------------------------------
# UI
# --------------------------------------------------------
ui <- dashboardPage(
  
  dashboardHeader(title = "📊 Dashboard de Vendas"),
  
  dashboardSidebar(
    
    sidebarMenu(
      menuItem("Visão Geral", tabName = "overview", icon = icon("chart-line")),
      menuItem("Produtos", tabName = "products", icon = icon("box")),
      menuItem("Vendedores", tabName = "seller", icon = icon("users")),
      
      hr(),
      
      selectInput(
        "produto",
        "Filtrar Produto:",
        choices = c("Todos", products$nome_produto),
        selected = "Todos"
      ),
      
      selectInput(
        "vendedor",
        "Filtrar Vendedor:",
        choices = c("Todos", seller$nome_vendedor),
        selected = "Todos"
      )
    )
  ),
  
  dashboardBody(
    
    tabItems(
      
      # --------------------------------------------------------
      # Visão geral
      # --------------------------------------------------------
      tabItem(tabName = "overview",
              
              fluidRow(
                valueBoxOutput("faturamento"),
                valueBoxOutput("lucro"),
                valueBoxOutput("ticket")
              ),
              
              fluidRow(
                box(width = 12, plotOutput("plot_kpis"))
              ),
              fluidRow(
                box(
                  tags$h1("Resumo Executivo"),
                  width = 12,
                  status = "success",
                  
                  p("A análise dos indicadores financeiros revela um desempenho 
                  sólido da operação, com faturamento total de R$ 1.424.320, 
                  evidenciando uma boa capacidade de geração de receita.
  
                  O lucro apurado de R$ 471.235 demonstra uma operação eficiente, 
                  com controle de custos e margens sustentáveis, refletindo uma 
                  estrutura financeira equilibrada.
  
                  O ticket médio de R$ 2.374 indica um valor relevante por 
                  transação, sugerindo que as vendas estão concentradas em 
                  produtos de maior valor agregado ou em estratégias eficazes 
                  de aumento de valor por cliente.
  
                  De forma integrada, esses indicadores apontam para um 
                  cenário positivo, com equilíbrio entre volume de vendas, 
                  rentabilidade e valor médio por pedido, criando uma 
                  base consistente para crescimento sustentável."),
                )
              )  
      ),
      
      # --------------------------------------------------------
      # Produtos
      # --------------------------------------------------------
      tabItem(tabName = "products",
              
              fluidRow(
                box(width = 6, plotOutput("plot_produtos")),
                box(width = 6, plotOutput("plot_relacao"))
              ),
              fluidRow(
                box(
                  tags$h1("Faturamento por Produto"),
                  width = 12,
                  status = "success",
                  
                  p("A análise de lucratividade por produto evidencia uma 
                  distribuição heterogênea, com destaque para itens como 
                  Impressora, HD Externo e Cadeira Gamer, que concentram as 
                  maiores contribuições para o resultado financeiro. 
                  Esses produtos combinam bom volume de vendas com margens 
                  mais elevadas, tornando-se estratégicos para a geração de 
                  valor."),

                  p("Por outro lado, produtos como Mouse, Pendrive e 
                  Teclado apresentam baixa participação no lucro total, 
                  indicando menor eficiência financeira. Esses itens podem 
                  estar associados a preços mais baixos, margens reduzidas 
                  ou menor demanda, exigindo reavaliação estratégica."),

                  p("Além disso, observa-se que alguns produtos com alto 
                  volume de vendas, como Webcam e Headset, não necessariamente 
                  se traduzem nos maiores lucros, o que reforça a importância 
                  de analisar não apenas quantidade vendida, mas também 
                  margem e posicionamento de preço."),
                  
                  tags$h3("Principais Implicações"),
                  
                  p("* Priorizar produtos com maior margem e retorno 
                    financeiro"),
                  p("* Revisar estratégia de precificação para itens de 
                    baixo desempenho"),
                  p("* Explorar oportunidades de aumento de valor em 
                    produtos de alto volume"),
                  p("Em síntese, a análise indica oportunidades claras 
                    de otimização do portfólio, com foco em maximizar 
                    rentabilidade e eficiência operacional.")
                )
            )
      ),
      
      # --------------------------------------------------------
      # Vendedores
      # --------------------------------------------------------
      tabItem(tabName = "seller",
              
              fluidRow(
                box(width = 12, plotOutput("plot_vendedores"))
              ),
              fluidRow(
                box(
                  tags$h1("Faturamento por Produto"),
                  width = 12,
                  status = "success",
                  
                  p("A análise de faturamento por vendedor evidencia 
                  diferenças relevantes de desempenho dentro da equipe 
                  comercial, com destaque para profissionais como 
                  Marcos Silva e Fernanda Rocha, que lideram em geração 
                  de receita e demonstram maior eficiência nas vendas."),
                  
                  p("Esses resultados indicam não apenas maior volume 
                  de negociações, mas também possivelmente melhores 
                  estratégias comerciais, relacionamento com clientes ou 
                  atuação em produtos de maior valor agregado."),
                  
                  p("Por outro lado, observa-se que outros vendedores 
                  apresentam desempenho inferior, o que pode estar 
                  associado a fatores como carteira de clientes, experiência 
                  ou abordagem comercial. Essa variação reforça a 
                  importância de monitoramento contínuo e desenvolvimento 
                  da equipe."),
                  
                  tags$h3("Principais insights:"),
                  
                  p("* Identificação clara dos top performers"),
                  p("* Existência de gap de performance entre vendedores"),
                  p("* Potencial de replicação de boas práticas comerciais"),
                  
                  tags$h3("Recomentações:"),
                  
                  p("* Compartilhar estratégias dos vendedores de melhor 
                  desempenho"),
                  p("* Implementar treinamentos direcionados"),
                  p("* Avaliar distribuição de leads ou carteira de clientes"),
                  
                  p("Em síntese, os dados permitem uma visão estratégica 
                  da equipe, possibilitando ações focadas em maximizar 
                  resultados e reduzir desigualdades de performance.")
                )
              )
      )
    )
  )
)

# --------------------------------------------------------
# Sevidor
# --------------------------------------------------------
server <- function(input, output, session) {
  
  # Filtro produto
  products_filtered <- reactive({
    if (input$produto == "Todos") {
      products
    } else {
      products %>% filter(nome_produto == input$produto)
    }
  })
  
  # Filtro vendedor
  seller_filtered <- reactive({
    if (input$vendedor == "Todos") {
      seller
    } else {
      seller %>% filter(nome_vendedor == input$vendedor)
    }
  })
  
  # --------------------------------------------------------
  # KPIs
  # --------------------------------------------------------
  
  output$faturamento <- renderValueBox({
    valueBox(
      value = format_real(sales$faturamento),
      subtitle = "Faturamento",
      color = "blue",
      icon = icon("dollar-sign")
    )
  })
  
  output$lucro <- renderValueBox({
    valueBox(
      value = format_real(sales$lucro),
      subtitle = "Lucro",
      color = "green",
      icon = icon("chart-line")
    )
  })
  
  output$ticket <- renderValueBox({
    valueBox(
      value = format_real(sales$ticket_medio),
      subtitle = "Ticket Médio",
      color = "orange",
      icon = icon("shopping-cart")
    )
  })
  
  # --------------------------------------------------------
  # KPIs Gráficos
  # --------------------------------------------------------
  
  output$plot_kpis <- renderPlot({
    
    tibble::tibble(
      indicador = c("Faturamento", "Lucro", "Ticket Médio"),
      valor = c(sales$faturamento, sales$lucro, sales$ticket_medio)
    ) %>%
      ggplot(aes(indicador, valor, fill = indicador)) +
      geom_col(width = 0.6, show.legend = FALSE) +
      geom_text(
        aes(label = format_real(valor)),
        vjust = -0.5,
        size = 5,              
        fontface = "bold"
      ) +
      scale_fill_manual(
        values = c(
          "Faturamento" = "#2C7BE5",   
          "Lucro" = "#00A65A",        
          "Ticket Médio" = "#F39C12"   
        )
      ) +
      scale_y_continuous(
        labels = scales::label_dollar(
          prefix = "R$ ",
          big.mark = ".",
          decimal.mark = ","
        )
      ) +
      theme_minimal(base_size = 14
      ) +
      labs(
        title = "Indicadores Gerais",
        x = "Indicador",
        y = "Valor (R$)"
      ) 
  })
  
  # --------------------------------------------------------
  # Produtos
  # --------------------------------------------------------
  
  output$plot_produtos <- renderPlot({
    
    products_filtered() %>%
      arrange(lucro) %>%
      ggplot(aes(reorder(nome_produto, lucro), lucro)) +
      
      geom_col(fill = "#2C7BE5") +
      
      geom_text(
        aes(label = format_real(lucro)),
        hjust = 1.1,
        color = "white",
        size = 5,              
        fontface = "bold"
      ) +
      coord_flip() +
      
      scale_y_continuous(
        labels = scales::label_dollar(
          prefix = "R$ ",
          big.mark = ".",
          decimal.mark = ","
        ),
        expand = expansion(mult = c(0, 0.05))
      ) +
      labs(
        title = "Lucro por Produto",
        x = "Produtos",
        y = "Lucro (R$)"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")
      ) 
  })
  
  # --------------------------------------------------------
  # Relação
  # --------------------------------------------------------
  output$plot_relacao <- renderPlot({
    
    products %>%
      ggplot(aes(total_vendido, lucro, label = nome_produto)) +
      geom_point(size = 4, color = "#F39C12") +
      geom_text(nudge_y = 5000) +
      scale_y_continuous(labels = scales::label_dollar(
        prefix = "R$ ",
        big.mark = ".",
        decimal.mark = ","
      )) +
      labs(title = "Volume vs Lucro") +
      labs(
        title = "Lucro por Produto",
        x = "Total Vendido",
        y = "Lucro (R$)"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")
      ) 
  })
  
  # --------------------------------------------------------
  # Vendedores
  # --------------------------------------------------------
  
  output$plot_vendedores <- renderPlot({
    
    seller_filtered() %>%
      arrange(faturamento) %>%
      ggplot(aes(reorder(nome_vendedor, faturamento), faturamento)) +
      
      geom_col(fill = "#00A65A") +
      
      geom_text(
        aes(label = format_real(faturamento)),
        hjust = 1.1,
        size = 5,              
        fontface = "bold",
        color = "white"
      ) +
      
      coord_flip() +
      
      scale_y_continuous(
        labels = scales::label_dollar(
          prefix = "R$ ",
          big.mark = ".",
          decimal.mark = ","
        ),
        expand = expansion(mult = c(0, 0.05))
      ) +
      
      labs(title = "Faturamento por Vendedor") +
      labs(
        title = "Faturamento por Vendedor",
        x = "Vendedores",
        y = "Faturamento"
      ) +
      theme_minimal(base_size = 12) +
      theme(
        axis.title.x = element_text(face = "bold"),
        axis.title.y = element_text(face = "bold")
      ) 
  })
}

log_info("Término da geração do DashBoard")

# --------------------------------------------------------
# Run App
# --------------------------------------------------------
shinyApp(ui, server)