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

rmarkdown → Geração de relatórios
tibble → Estruturas de dados modernas
