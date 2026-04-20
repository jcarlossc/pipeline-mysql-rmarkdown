# 📌 Pipeline Analítico de Vendas (R)

Pipeline completo de análise de vendas com R + R Markdown, focado em geração automatizada de relatórios executivos a partir de dados processados.

## 📌 Relatório R Markdown
[📄 Ver relatório completo](report/report.pdf)<br>
[📥 Baixar relatório completo](https://github.com/jcarlossc/pipeline-mysql-rmarkdown/blob/main/report/report.pdf)

## 📌 Visão Geral

Este projeto implementa um fluxo profissional de análise de dados:

* Processamento e transformação de dados (ETL leve)
* Estrutura modular e desacoplada
* Geração de relatório executivo em PDF
* Execução automatizada via R Markdown

O objetivo é simular um cenário real de negócio, entregando insights acionáveis a partir de métricas de vendas.

## 📌 Imagens DashBoard

<table>
  <tr>
    <td><img src="https://github.com/jcarlossc/pipeline-mysql-rmarkdown/blob/main/images/dashboard/dashboard_01.png" alt="Imagem Dashboard" width="200"/> </td>
    <td><img src="https://github.com/jcarlossc/pipeline-mysql-rmarkdown/blob/main/images/dashboard/dashboard_02.png" alt="Imagem Dashboard" width="200"/> </td>
    <td><img src="https://github.com/jcarlossc/pipeline-mysql-rmarkdown/blob/main/images/dashboard/dashboard_03.png" alt="Imagem Dashboard" width="200"/> </td>
  </tr>
</table>

## 📌 Arquitetura do Projeto
```
pipeline-mysql-rmarkdown/
|
├── app/
│     └── app.R
├── script_database/
│     └── loja_informatica.sql
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

## 📌 Tecnologias Utilizadas
| Tecnologia | Descrição |
| ---------- | --------- |
| R | Linguagem de programação |
| RStudio | IDE |
| dplyr | Manipulação de dados |
| ggplot2 | Visualização |
| scales | Formatação de valores |
| logger | Geração de logs |
| yaml | Aquivos de configuração |
| rmarkdown | Geração de relatórios |
| tibble | Estruturas de dados modernas |
| DBI | Interface padão para banco de dados |
| RMySQL | Drive que conecta DBI ao MySQL/MariaDB |
| shiny | DashBoard interativo |
| XAMPP | Pacote de software livre e gratuito |
| apache | Servidor local |
| MySQL | Banco de Dados |  

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

### 📌 Saída Relatório
report.pdf

Relatório executivo com:

* KPIs visuais
* Gráficos analíticos
* Insights estratégicos

### 📌 Saída DashBoard

app

DashBoard executivo com:

* KPIs visuais
* Gráficos analíticos
* Insights estratégicos

## 📌 Mecanismo de Retry
O pipeline implementa retry automático para garantir robustez em falhas de conexão:
```
retry:
  max_attempts: 3
  wait_seconds: 5
```
✔ Evita falhas intermitentes<br>
✔ Aumenta confiabilidade do pipeline<br>

## 📌 Logging
O projeto utiliza logging estruturado:<br>
Exemplo:<br>
```
[2026-04-20 14:03:55.771578] INFO - Carregando configurações...
[2026-04-20 14:03:55.898084] INFO - Carregando módulos...
[2026-04-20 14:03:58.018395] INFO - Nível de log configurado para: INFO
[2026-04-20 14:03:58.028467] INFO - Logger iniciado | file=C:/workspace/projects_R/pipeline-mysql-rmarkdown/logs/app.log | level=INFO
[2026-04-20 14:03:58.035779] INFO - Pipeline iniciado
[2026-04-20 14:03:58.04506] INFO - Conectando ao banco...
[2026-04-20 14:03:58.861117] INFO - Tentativa 1 de 3
[2026-04-20 14:03:59.218379] INFO - Conectando em ambiente local (localhost)
[2026-04-20 14:03:59.226573] INFO - Tentando conectar ao banco loja_informatica em localhost:3306
...

```

## 📌 Diferenciais do Projeto
* Arquitetura desacoplada (pipeline vs relatório)
* Implementação de retentativas (retry) 
* Tratamento de error
* Automação completa da análise
* Código organizado e escalável
* Foco em insight de negócio, não apenas código

## 📌 Modo de Utilização

### 1. Execute o XAMPP
* Caso não o tenha, baixe-o: <a href="https://www.apachefriends.org/pt_br/download.html">https://www.apachefriends.org/pt_br/download.html</a>
* Instale-o normalmente
* Execute o Painel de Controle
* Acione o Apache e o MySQL/MariaDB
* Ao lado do botão start/stop, clique em Admin. Isso irá abrir a interface do MySQL/MariaDB no navegador
* Clique na aba importar e em escolher arquivo: o script está na raiz do projeto: ```script_database/loja_informatica.sql```, após isso, clique em importar no final da página
* O banco de Dados está com usuário ```root``` e senha vazia. O arquivo de configuração está em: ```config/db.yaml```

### 2. Clone o repositório e acesse o diretório
```
git clone https://github.com/jcarlossc/pipeline-mysql-rmarkdown.git
cd pipeline-mysql-rmarkdown
```
### 3. Restaure as dependências:
```
renv::restore()
```
### 4. Gerar relatório PDF:
* Acesse o arquivo do relatótio: ```pipeline-mysql-rmarkdown/report/report.Rmd``` e clique no botão ```Knit```
* Ou, acesse o arquivo do relatótio: ```pipeline-mysql-rmarkdown/report/report.Rmd``` e use o atalho ```Ctrl + Shift + K```
* Ou, simplesmente, no console, digite: ```rmarkdown::render("report/report.Rmd")```
* Qualquer um desses procedimentos vai gerar um relatório em PDF

### 5. Gerar DashBoard interativo:
* Acesse o arquivo do DashBoard: ```pipeline-mysql-rmarkdown/app/app.R``` e clique no botão ```Run App```
* Ou, no console, digite: ```shiny::runApp("app")```
* Após abertura de uma janela com o DashBoard, existe um botão na parte superior que, caso queira, o DashBoard poderá ser visualizado, também no navegador. 

## 📌 Licença
Este projeto está licenciado sob MIT License.

## 📌 Contato
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
