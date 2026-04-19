# 📌 Pipeline Analítico de Vendas (R)

Pipeline completo de análise de vendas com R + R Markdown, focado em geração automatizada de relatórios executivos a partir de dados processados.

---

## 📌 Visão Geral

Este projeto implementa um fluxo profissional de análise de dados:

* Processamento e transformação de dados (ETL leve)
* Estrutura modular e desacoplada
* Geração de relatório executivo em PDF
* Execução automatizada via R Markdown

O objetivo é simular um cenário real de negócio, entregando insights acionáveis a partir de métricas de vendas.

---

## 📌 Arquitetura do Projeto
```
pipeline-mysql-rmarkdown/
|
├── .gitignore
├── .RData
├── .Rhistory
├── .Rprofile
├── config/
│       ├── config.yaml
│       ├── db.yaml
│       ├── logging.yaml
│       └── paths.yaml
├── pipeline-mysql-rmarkdown.Rproj
├── LICENSE
├── logs/
|     └── app.log
├── main.R
├── README.md
├── renv/
├── renv.lock
├── reports/
│       ├── vendas.jpg
│       ├── report.pdf
│       └── report.Rmd
├── src/
│     ├── access_data/
│     |     └── access_database.R
│     ├── db/
│     |     └── db_connection.R
│     ├── metrics/
|     |     ├── products_metric.R
|     |     ├── sales_metric.R
│     |     └── seller_metric.R
│     └── standardization/
│           └── data_standardization.R
└── utils/
      ├── error/
      |     └── error_handler.R.R
      ├── helper/
      |     └── helpers.R
      └── loggers/
            └── logger.R
```

---

## 📌 Tecnologias Utilizadas
| Tecnologia | Descrição |
| ---------- | --------- |
| R | Linguagem de programação |
| dplyr | Manipulação de dados |
| ggplot2 | Visualização |
| scales | Formatação de valores |
| logger | Geração de logs |
| yaml | Aquivos de configuração |
| rmarkdown | Geração de relatórios |
| tibble | Estruturas de dados modernas |
| DBI | Interface padão para banco de dados |
| RMySQL | Drive que conecta DBI ao MySQL/MariaDB |

---

## 📌 Métricas Analisadas

O projeto trabalha com três níveis principais de análise:

### 📌 Vendas (Visão Executiva)
* Faturamento total
* Lucro
* Ticket médio
* Volume de itens vendidos
### 📌 Produtos
* Faturamento por produto
* Produtos mais vendidos
### 📌 Vendedores
* Volume de vendas
* Faturamento individual
* Ranking de performance

---

## 📌 Pipeline de Execução
### 📌 Executar o processamento
source("main.R")

Isso irá:

* Conectar ao Banco de Dados
* Acessar o Banco de dados
* Padronizar os nomes de colunas
* Gerar os KPIs
* Consolida as métricas em uma lista
* Renderizar o relatório automaticamente

### 📌 Saída
report.pdf

Relatório executivo com:

* KPIs visuais
* Gráficos analíticos
* Insights estratégicos

---

## 📌 Diferenciais do Projeto
* Arquitetura desacoplada (pipeline vs relatório)
* Implementação de retentativas (retry) 
* Tratamento de error
* Automação completa da análise
* Código organizado e escalável
* Foco em insight de negócio, não apenas código

---

## 📌 Modo de Utilização


---

📌 Licença
Este projeto está licenciado sob MIT License.

---

📌 Contato
* Recife, PE - Brasil
* Telefone: +55 81 99712 9140
* Telegram: @jcarlossc
* Blogger linguagem R: https://informaticus77-r.blogspot.com/
* Blogger linguagem Python: https://informaticus77-python.blogspot.com/
* Email: jcarlossc1977@gmail.com
* LinkedIn: https://www.linkedin.com/in/carlos-da-costa-669252149/
* GitHub: https://github.com/jcarlossc
* Kaggle: https://www.kaggle.com/jcarlossc/
* Twitter/X: https://x.com/jcarlossc1977
