# Relatório de Laboratório – Lab 01: Ajuste de Performance em Banco de Dados

## 1. Experimentos Realizados

### 1.1. Consultas sem Chave Primária (PK)

#### 1.1.1. Descrição:
Nesta etapa, uma consulta SQL será realizada sem a chave primária, de modo a comparar o desempenho da execução em relação à mesma consulta com chave primária.

#### 1.1.2. Procedimento:
1. Conectar ao banco de dados:
   ```sql
   CONNECT system/fatec;
   ```

   ![alt text](image.png)

2. Dropar a chave primária e o índice da tabela `oe.product_descriptions`:
   ```sql
   ALTER TABLE oe.product_descriptions DROP PRIMARY KEY;
   DROP INDEX prd_desc_pk;
   ```

   ![alt text](image-1.png)
   ![alt text](image-2.png)

3. Executar a consulta abaixo com o comando `SET TIMING ON` habilitado para medir o tempo de execução:
   ```sql
   SELECT * FROM product_descriptions WHERE product_id = 3060 AND language_id = 'US';
   ```
4. **Tempo de execução:** 0,03 segundos.
5. **Print:** ![alt text](image-7.png)

### 1.2. Consultas com Chave Primária (PK)

#### 1.2.1. Descrição:
Nesta etapa, a chave primária será restaurada na tabela, e a consulta será repetida para análise comparativa de desempenho.

#### 1.2.2. Procedimento:
1. Restaurar a chave primária:
   ```sql
   ALTER TABLE product_descriptions ADD PRIMARY KEY (product_id, language_id);
   ```
   ![alt text](image-4.png)

2. Executar novamente a consulta:
   ```sql
   SELECT * FROM product_descriptions WHERE product_id = 3060 AND language_id = 'US';
   ```

3. **Tempo de execução:** 0,01 segundos.
4. **Print:** ![alt text](image-6.png)
5. **Diferença observada:** Na consulta com chave primária, houve um tempo menor de execução.

### 1.3. Consultas de Vendas sem Campo Consolidado

#### 1.3.1. Descrição:
Aqui serão executadas consultas de contagem de vendas sem o uso de um campo previamente consolidado.

#### 1.3.2. Procedimento:
1. Executar a consulta:
   ```sql
   SELECT cust_id, COUNT(*) FROM sales GROUP BY cust_id;
   ```
2. **Tempo de execução:** 0,17 segundos.
3. **Print:** ![alt text](image-8.png)

### 1.4. Consultas de Vendas com Campo Consolidado

#### 1.4.1. Descrição:
Nesta etapa, será criada uma tabela consolidada para armazenar o total de vendas por cliente. A consulta será realizada na tabela consolidada para análise de desempenho.

#### 1.4.2. Procedimento:
1. Criar a tabela consolidada:
   ```sql
   CREATE TABLE sales_summary AS
   SELECT cust_id, SUM(amount_sold) AS amount_sold FROM sales GROUP BY cust_id;
   ALTER TABLE sales_summary ADD PRIMARY KEY (cust_id);
   ```

   ![alt text](image-9.png)
   ![alt text](image-10.png)

2. Executar a consulta:
   ```sql
   SELECT cust_id, amount_sold FROM sales_summary WHERE cust_id = 116;
   ```
3. **Tempo de execução:** 0,02 segundos.
4. **Print:** ![alt text](image-11.png)
5. **Diferença observada:** Com campo consolidado, o tempo de execução da consulta é muito menor.

---

## 2. Parte II: Índices e Consultas com/sem Índices

Nesta segunda parte, o foco é analisar o impacto de índices na performance de consultas em diferentes cenários. Será utilizado o comando `SET TIMING ON` para medir os tempos de execução.

### 2.1. Consultas com Índices Exclusivos e Não Exclusivos

1. **Criar Índice Exclusivo:**
   ```sql
   CREATE UNIQUE INDEX idx_exclusive ON sales(cust_id);
   ```

   ![alt text](image-14.png)

   Executar a consulta:
   ```sql
   SELECT * FROM sales WHERE cust_id = 116;
   ```
   - **Tempo de execução:** 0,30 segundos.
   - **Print:** ![alt text](image-15.png)

2. **Criar Índice Não Exclusivo:**
   ```sql
   CREATE INDEX idx_non_exclusive ON sales(amount_sold);
   ```

   ![alt text](image-16.png)

   Executar a consulta:
   ```sql
   SELECT * FROM sales WHERE amount_sold > 100;
   ```
   - **Tempo de execução:** Aproximadamente 3 segundos.
   - **Print:** ![alt text](image-17.png)

3. **Diferença Observada:** O uso do índice único exclusivo teve um desempenho superior ao ao índice não exclusivo.

### 2.2. Consultas com Índices Composto

1. **Criar Índice Composto:**
   ```sql
   CREATE INDEX idx_composite ON sales(cust_id, amount_sold);
   ```

   ![alt text](image-18.png)

2. Executar a consulta:
   ```sql
   SELECT * FROM sales WHERE cust_id = 116 AND amount_sold > 100;
   ```
   - **Tempo de execução:** 0,01 segundos.
   - **Print:** ![alt text](image-19.png)
   **Diferença Observada:** O uso do índice composto se mostrou o mais efetivo, alcançando métricas de tempo de execução muito superiores aos demais tipos.

## 3. Observações detalhadas para cada abordagem:

### 1. Consultas sem Chave Primária (PK)
Na primeira seção, a chave primária foi removida, e o tempo de execução da consulta sem a chave primária foi registrado em **0,03 segundos**. Sem a PK, o banco de dados precisa realizar uma pesquisa completa na tabela (full table scan), resultando em maior tempo de processamento, especialmente em grandes tabelas.

### 2. Consultas com Chave Primária (PK)
Após restaurar a chave primária, o tempo de execução da mesma consulta caiu para **0,01 segundos**. A presença da PK permite que o Oracle utilize um índice para localizar os dados de maneira mais eficiente, reduzindo drasticamente o tempo necessário para executar a busca. Isso demonstra claramente a vantagem de manter índices bem estruturados para melhorar a performance de consultas que dependem de campos-chave.

### 3. Consultas de Vendas sem Campo Consolidado
Quando a consulta foi realizada sem um campo consolidado (resumo), o tempo de execução foi de **0,17 segundos**. Nesse caso, o Oracle teve que agrupar os resultados dinamicamente, o que exige mais recursos de processamento. Consultas que envolvem operações de agregação em tabelas grandes frequentemente enfrentam esse tipo de penalidade de desempenho.

### 4. Consultas de Vendas com Campo Consolidado
Quando foi criada uma tabela consolidada (`sales_summary`), o tempo de execução foi reduzido para **0,02 segundos**. O fato de os dados já estarem pré-agrupados permite que o Oracle acesse diretamente os resultados sem precisar processá-los em tempo real, resultando em uma performance significativamente melhor.

### 5. Consultas com Índices
A seção final aborda o impacto do uso de diferentes tipos de índices. O **índice exclusivo (PK)** resultou em um tempo de execução de **0,30 segundos**, enquanto o **índice não exclusivo** levou cerca de **3 segundos**. O uso de um **índice composto** (envolvendo `cust_id` e `amount_sold`) proporcionou o melhor desempenho, com o tempo de execução caindo para **0,01 segundos**. Isso reforça a ideia de que a escolha correta do tipo de índice pode melhorar drasticamente o desempenho, especialmente em consultas que envolvem múltiplas colunas e agrupamentos.

## 4. Análise de Desempenho Geral:
- O uso de **índices primários** e **índices compostos** se mostrou muito eficiente, melhorando significativamente o tempo de resposta em consultas direcionadas por esses índices.
- A criação de **tabelas consolidadas** (resumos) é extremamente eficaz para reduzir o tempo de execução em consultas que envolvem agregações complexas, como somas e agrupamentos.
- Consultas sem otimizações adequadas, como a falta de PK ou ausência de campos consolidados, exigem mais processamento e resultam em tempos de execução muito maiores.

## 5. Impacto no Desempenho:
Essas diferenças demonstram a importância de aplicar boas práticas de otimização no design do banco de dados, como a manutenção de **índices bem estruturados** e a criação de **tabelas consolidadas** para operações que envolvem grandes volumes de dados ou agregações frequentes.