# Relatório de Laboratório – Lab 01: Visualização do Plano de Execução dos Comandos SQL (OEM)

## 1. Experimentos Realizados

### 1.1. Consulta de Registros sem Chave Primária (PK)

#### 1.1.1. Descrição:
Nesta etapa, será realizada uma consulta em uma tabela sem chave primária, e o plano de execução será analisado utilizando o Oracle Enterprise Manager (OEM).

#### 1.1.2. Procedimento:
1. Dropar a chave primária e o índice:
   ```sql
   ALTER TABLE product_descriptions DROP PRIMARY KEY;
   DROP INDEX prd_desc_pk;
   ```
   ![alt text](image-20.png)

2. Executar a consulta:
   ```sql
   SELECT * FROM product_descriptions WHERE product_id = 3060 AND language_id = 'US';
   ```

   ![alt text](image-21.png)

3. **Plano de Execução:** Utilizar o OEM para capturar o plano de execução. Para isso, executar a consulta dentro de um loop:
   ```sql
   BEGIN
      FOR i IN 1..500000 LOOP
         FOR rec IN (SELECT product_id, language_id
                     FROM product_descriptions
                     WHERE product_id = 3060 AND language_id = 'US') 
         LOOP
               NULL;  
         END LOOP;
      END LOOP;
   END;
   /
   ```

4. **Print:** ![alt text](image-25.png)

### 1.2. Consulta de Registros com Chave Primária (PK)

#### 1.2.1. Descrição:
Nesta etapa, será realizada uma consulta em uma tabela com chave primária, e o plano de execução será analisado utilizando o Oracle Enterprise Manager (OEM).

#### 1.2.2. Procedimento:
1. Adicionar a chave primária:
   ```sql
   ALTER TABLE product_descriptions ADD PRIMARY KEY (product_id, language_id);
   ```

   ![alt text](image-23.png)

2. Executar a consulta:
   ```sql
   SELECT * FROM product_descriptions WHERE product_id = 3060 AND language_id = 'US';
   ```

3. **Plano de Execução:** Utilizar o OEM para capturar o plano de execução, seguindo o mesmo procedimento do item anterior (executar a consulta dentro de um loop).

4. **Print:** ![alt text](image-26.png)

### 1.3. Consulta de Vendas sem Campo Consolidado

#### 1.3.1. Descrição:
Será realizada uma consulta de vendas sem campo consolidado, e o plano de execução será analisado utilizando o Oracle Enterprise Manager (OEM).

#### 1.3.2. Procedimento:
1. Executar a consulta:
   ```sql
   SELECT cust_id, COUNT(*) FROM sales GROUP BY cust_id;
   ```

2. **Plano de Execução:** Utilizar o OEM para capturar o plano de execução da consulta.

3. **Print:** ![alt text](image-27.png)

### 1.4. Consulta de Vendas com Campo Consolidado

#### 1.4.1. Descrição:
Será realizada uma consulta de vendas utilizando um campo previamente consolidado, e o plano de execução será analisado utilizando o Oracle Enterprise Manager (OEM).

#### 1.4.2. Procedimento:
1. Criar a tabela consolidada:
   ```sql
   CREATE TABLE sales_summary AS
   SELECT cust_id, SUM(amount_sold) AS amount_sold FROM sales GROUP BY cust_id;
   ALTER TABLE sales_summary ADD PRIMARY KEY (cust_id);
   ```

2. Executar a consulta:
   ```sql
   SELECT cust_id, amount_sold FROM sales_summary WHERE cust_id = 116;
   ```

3. **Plano de Execução:** Utilizar o OEM para capturar o plano de execução da consulta.

4. **Print:** ![alt text](image-28.png)

### 1.5. Plano de Execução (Explain Plan)

#### 1.5.1. Descrição:
Nesta etapa, será obtido o plano de execução para a consulta utilizando o comando `EXPLAIN PLAN FOR`.

#### 1.5.2. Procedimento:
1. Executar o comando abaixo para obter o plano de execução:
   ```sql
   EXPLAIN PLAN FOR
   SELECT * FROM product_descriptions WHERE product_id = 3060 AND language_id = 'US';
   ```

   ![alt text](image-12.png)

2. Visualizar o plano de execução:
   ```sql
   SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());
   ```
3. **Print:** ![alt text](image-13.png)

### 1.5. Tuning Task do Oracle

#### 1.5.1. Descrição:
Utilizar a funcionalidade **Tuning Task** do Oracle para obter recomendações de otimização para uma consulta específica.

#### 1.5.2. Procedimento:
1. Obter o `sql_id` da consulta desejada via OEM:
   ```sql
   SELECT sql_id FROM v$sql WHERE sql_text LIKE '%SELECT * FROM product_descriptions%';
   ```
![alt text](image-29.png)

2. Criar uma tarefa de tuning:
   ```sql
   DECLARE
       V_return VARCHAR2(150);
   BEGIN
       V_return := dbms_sqltune.create_tuning_task(sql_id => '1pbq26afzd15a', task_name => 'task_01', time_limit => 1800);
   END;
   ```

3. Executar a tarefa de tuning:
   ```sql
   EXEC dbms_sqltune.execute_tuning_task(task_name => 'task_01');
   ```
   ![alt text](image-30.png)

4. Visualizar o relatório de tuning:
   ```sql
   SET LONG 65536;
   SELECT dbms_sqltune.report_tuning_task('task_01') AS recommendation FROM dual;
   ```

5. **Print:** ![alt text](image-31.png)

## 2. Observações detalhadas do experimento e pela análise das execuções no OEM:

### 1. **Consultas sem Chave Primária (PK)**

Quando realizamos uma consulta sem a presença de uma chave primária, o Oracle não consegue otimizar a busca usando índices específicos, o que faz com que o sistema utilize um **Table Access Full**. Essa abordagem realiza uma leitura completa da tabela, resultando em um tempo de execução mais elevado, principalmente em tabelas grandes. 

- **Tempo de execução:** 0,03 segundos.
  
Essa diferença pode parecer pequena em uma tabela menor, mas em tabelas com milhões de registros, o impacto seria mais significativo.

- **Plano de execução:** Observa-se o **Table Access Full**, confirmando que não há índice sendo utilizado, o que aumenta o tempo de busca pela falta de um caminho mais eficiente.

### 2. **Consultas com Chave Primária (PK)**

Ao restaurar a chave primária, o Oracle utiliza o índice associado à chave primária para otimizar a consulta, trocando o **Table Access Full** pelo **Index Unique Scan**. Esse método permite ao Oracle localizar o registro de forma muito mais eficiente.

- **Tempo de execução:** 0,01 segundos.
  
Aqui, o impacto da PK foi notável, mesmo em uma tabela pequena, reduzindo significativamente o tempo de busca.

- **Plano de execução:** O plano mostra um **Index Unique Scan**, o que confirma o uso eficiente do índice criado pela chave primária, reduzindo drasticamente o custo de busca.

### 3. **Consultas sem Campo Consolidado**

Quando realizamos a consulta de vendas sem um campo consolidado, o Oracle precisa realizar operações de **Group By** na hora, o que aumenta o tempo de processamento.

- **Tempo de execução:** 0,17 segundos.

Embora isso seja aceitável em tabelas pequenas, em um ambiente de produção, esse tipo de operação se torna muito mais custoso à medida que o número de registros cresce. Além disso, o plano de execução demonstra a necessidade de operações mais pesadas, como o agrupamento dos dados no momento da consulta.

### 4. **Consultas com Campo Consolidado**

Com a criação de uma tabela consolidada, o cálculo dos dados (neste caso, a soma das vendas) já está feito, e a consulta apenas precisa acessar a tabela já pronta, o que reduz consideravelmente o tempo de resposta.

- **Tempo de execução:** 0,02 segundos.

A melhoria é significativa, pois o Oracle não precisa realizar a operação de **Group By** novamente, bastando acessar os dados já organizados na tabela consolidada. Isso mostra a importância de pré-processar dados em grandes bancos de dados para consultas frequentes.

- **Plano de execução:** O plano revela que o acesso foi direto à tabela consolidada, o que confirma o uso eficiente dessa técnica para otimizar o tempo de execução.

### 5. **Índices Exclusivos e Não Exclusivos**

#### a. **Índice Exclusivo**
Ao utilizar um índice exclusivo na coluna `cust_id`, o Oracle pode localizar rapidamente os registros correspondentes, usando um **Index Unique Scan**.

- **Tempo de execução:** 0,30 segundos.
  
O índice exclusivo garante que a consulta seja otimizada, com um tempo de execução consideravelmente menor em comparação a uma busca sem índice.

#### b. **Índice Não Exclusivo**
Para consultas com índices não exclusivos, o Oracle ainda utiliza o índice, mas sem a garantia de que a consulta resulte em um único registro, tornando o processo um pouco menos eficiente.

- **Tempo de execução:** Aproximadamente 3 segundos.

#### c. **Índice Composto**
Quando usamos um índice composto (usando mais de uma coluna), o Oracle pode otimizar ainda mais a busca, especialmente em consultas que envolvem múltiplas colunas nas cláusulas de busca.

- **Tempo de execução:** 0,01 segundos.

O índice composto foi o mais eficiente de todos, mostrando que, quando bem configurados, os índices compostos podem otimizar dramaticamente o tempo de execução.

## 3. Últimas Considerações:

- Cada abordagem testada no Lab 01 demonstra a importância de utilizar corretamente índices e chaves primárias para otimização. Consultas sem chave primária ou índices adequados sofrem penalidades de tempo, enquanto consultas com índices compostos ou uso de tabelas consolidadas oferecem melhorias notáveis no tempo de execução. Este tipo de otimização se torna ainda mais crucial à medida que o volume de dados cresce em bancos de produção.

- Para melhorar a performance em bancos de dados maiores, é recomendável criar índices específicos e considerar o uso de tabelas consolidadas, quando apropriado, para evitar operações de agrupamento e cálculo on-the-fly.
