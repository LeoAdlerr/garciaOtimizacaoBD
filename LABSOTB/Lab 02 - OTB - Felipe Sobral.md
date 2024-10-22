# Relatório de Laboratório – Lab 02: Particionamento de Tabelas

## 1. Experimentos Realizados

### 1.1. Pesquisa e Documentação dos Tipos de Particionamento

#### 1.1.1. Descrição:
Nesta etapa, os tipos de particionamento disponíveis no Oracle SGBD serão pesquisados e documentados.

#### 1.1.2. Procedimento:
1. Realizar a pesquisa sobre os tipos de particionamento:
   - **Particionamento por Range**
   - **Particionamento por Lista**
   - **Particionamento por Hash**
   
2. Documentar as características de cada tipo de particionamento.

![alt text](image-27.png)

### 1.2. Criação de Tabela Não Particionada

#### 1.2.1. Descrição:
Nesta etapa, uma nova tabela será criada a partir da tabela `costs`, sem particionamento, para servir de base de comparação nas consultas subsequentes.

#### 1.2.2. Procedimento:
1. Criar a tabela não particionada:
   ```sql
   CREATE TABLE costs_comum AS SELECT * FROM costs;
   ```

   ![alt text](image.png)

### 1.3. Execução de Consultas em Tabelas Não Particionadas

#### 1.3.1. Descrição:
Serão executadas consultas em tabelas não particionadas e os tempos de execução serão medidos.

#### 1.3.2. Procedimento:
1. Executar as consultas com e sem chave primária na tabela `costs_comum`.
2. Utilizar o comando `SET TIMING ON` para medir o tempo de execução.
   - **Consulta sem PK:**
     ```sql
     SELECT * FROM costs_comum WHERE cost_id = 100;
     ```
     ![alt text](image-8.png)

     **Tempo de execução:** 0,01 segundos.
   - **Consulta com PK (após criar PK):**
     ```sql
     ALTER TABLE costs_comum ADD PRIMARY KEY (cost_id);
     SELECT * FROM costs_comum WHERE cost_id = 100;
     ```

     ![alt text](image-9.png)
     ![alt text](image-10.png)

     **Tempo de execução:** 0,01 segundos.

### 1.4. Execução de Consultas em Tabelas Particionadas

#### 1.4.1. Descrição:
Serão criadas tabelas particionadas e executadas consultas para medir os tempos de execução.

#### 1.4.2. Procedimento:
1. Criar tabela particionada por **Range**:
   ```sql
   CREATE TABLE costs_range (
       cost_id NUMBER,
       amount NUMBER,
       description VARCHAR2(100),
       date_of_entry DATE
   ) PARTITION BY RANGE (cost_id) (
       PARTITION p1 VALUES LESS THAN (100),
       PARTITION p2 VALUES LESS THAN (200),
       PARTITION p3 VALUES LESS THAN (MAXVALUE)
   );
   ```

   ![alt text](image-11.png)

2. Criar tabela particionada por **Lista**:
   ```sql
   CREATE TABLE costs_list (
       cost_id NUMBER,
       amount NUMBER,
       description VARCHAR2(100),
       date_of_entry DATE
   ) PARTITION BY LIST (cost_id) (
       PARTITION p1 VALUES (10, 20, 30),
       PARTITION p2 VALUES (40, 50, 60)
   );
   ```

   ![alt text](image-12.png)

3. Criar tabela particionada por **Hash**:
   ```sql
   CREATE TABLE costs_hash (
       cost_id NUMBER,
       amount NUMBER,
       description VARCHAR2(100),
       date_of_entry DATE
   ) PARTITION BY HASH (cost_id) PARTITIONS 3;
   ```

   ![alt text](image-13.png)

4. Executar as consultas nas tabelas particionadas.
   - **Consulta na tabela particionada por range:**
     ```sql
     SELECT * FROM costs_range WHERE cost_id = 150;
     ```

      ![alt text](image-14.png)

     **Tempo de execução:** Basicamente, resultou em aproximadamente 0 segundos.
   
   - **Consulta na tabela particionada por lista:**
     ```sql
     SELECT * FROM costs_list WHERE cost_id = 20;
     ```

      ![alt text](image-15.png)

     **Tempo de execução:** 0,03 segundos.
   
   - **Consulta na tabela particionada por hash:**
     ```sql
     SELECT * FROM costs_hash WHERE cost_id = 150;
     ```

      ![alt text](image-16.png)

     **Tempo de execução:** 0,01 segundos.

### 1.5. Análise do Plano de Execução (Explain Plan)

#### 1.5.1. Descrição:
Utilizar o comando `EXPLAIN PLAN` para analisar o plano de execução das consultas realizadas nas tabelas particionadas e não particionadas.

#### 1.5.2. Procedimento:
1. Para cada consulta, executar o comando:
   ```sql
   EXPLAIN PLAN FOR [comando SQL];
   SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY());
   ```

2. **Print:** 

   - Para range:
      ![alt text](image-17.png)
      ![alt text](image-18.png)
      ![alt text](image-19.png)
   - Para lista:
      ![alt text](image-20.png)
      ![alt text](image-21.png)
   - Para hash:
      ![alt text](image-22.png)
      ![alt text](image-23.png)

### 1.6. Inserção de Dados e Comportamento das Partições

#### 1.6.1. Descrição:
Nesta etapa, será realizada a inserção de dados nas tabelas particionadas, com o objetivo de observar o comportamento do Oracle ao lidar com partições.

#### 1.6.2. Procedimento:
1. Inserir dados na tabela particionada por range:
   ```sql
   INSERT INTO costs_range (cost_id, amount, description, date_of_entry)
   SELECT cost_id, amount, description, date_of_entry
   FROM costs
   WHERE cost_id <= 100;
   
   INSERT INTO costs_range (cost_id, amount, description, date_of_entry)
   SELECT cost_id, amount, description, date_of_entry
   FROM costs
   WHERE cost_id > 100 AND cost_id <= 200;
   
   INSERT INTO costs_range (cost_id, amount, description, date_of_entry)
   SELECT cost_id, amount, description, date_of_entry
   FROM costs
   WHERE cost_id > 200;

   COMMIT;
   ```

   ![alt text](image-24.png)

2. Inserir dados na tabela particionada por lista:
   ```sql
   INSERT INTO costs_list (cost_id, amount, description, date_of_entry)
   SELECT cost_id, amount, description, date_of_entry
   FROM costs
   WHERE cost_id IN (10, 20, 30);

   INSERT INTO costs_list (cost_id, amount, description, date_of_entry)
   SELECT cost_id, amount, description, date_of_entry
   FROM costs
   WHERE cost_id IN (40, 50, 60);
   
   COMMIT;
   ```

   ![alt text](image-25.png)

3. Inserir dados na tabela particionada por hash:
   ```sql
   INSERT INTO costs_hash (cost_id, amount, description, date_of_entry)
   SELECT cost_id, amount, description, date_of_entry
   FROM costs;
   
   COMMIT;
   ```

   ![alt text](image-26.png)
   
## 2. Observações detalhadas para cada abordagem:

### 1. **Tabela Não Particionada**
   - **Consulta sem PK**: O tempo de execução foi **0,01 segundos**, o que é relativamente rápido para uma tabela comum sem índices.
   - **Consulta com PK**: Mantém o mesmo tempo de execução (**0,01 segundos**), o que é um resultado interessante. Isso sugere que, no cenário atual, a presença de uma chave primária não teve um impacto perceptível.

### 2. **Tabela Particionada por Range**
   - **Tempo de execução**: O tempo registrado foi de **0 segundos**, o que é muito otimizado devido ao mecanismo de **partition pruning** do Oracle. Esse mecanismo identifica automaticamente a partição onde o valor da consulta se encontra, restringindo a pesquisa a uma menor porção de dados.
   - **Conclusão**: Esse tipo de particionamento é ideal quando você tem uma sequência contínua de valores, como datas ou IDs sequenciais. Ele permite uma execução altamente eficiente em consultas que se concentram em uma faixa de valores.

### 3. **Tabela Particionada por Lista**
   - **Tempo de execução**: O tempo foi **0,03 segundos**. Essa diferença é pequena, mas notável quando comparada ao particionamento por Range.
   - **Conclusão**: O particionamento por Lista é mais adequado para cenários onde os valores da chave não são contínuos, como categorias específicas. Contudo, pode não ser tão rápido quanto Range para grandes volumes de dados distribuídos uniformemente.

### 4. **Tabela Particionada por Hash**
   - **Tempo de execução**: **0,01 segundos**, desempenho similar à tabela particionada por Range.
   - **Conclusão**: Particionamento por Hash funciona melhor quando se deseja distribuir os dados de forma balanceada entre várias partições sem uma lógica de sequência. É útil quando você não pode definir intervalos específicos ou valores listados, mas ainda quer evitar hotspots (concentração de dados em uma partição específica).

## 3. Análise de Desempenho Geral:
- **Tabela Não Particionada**: Desempenho aceitável para pequenas consultas, mas à medida que o volume de dados aumenta, o particionamento se torna fundamental para otimização.
- **Particionamento por Range**: Demonstrou ser extremamente eficiente, particularmente útil quando as consultas são feitas em intervalos de valores.
- **Particionamento por Lista**: Apesar de ser um pouco mais lento que o Range, ainda oferece melhorias significativas quando comparado a uma tabela não particionada.
- **Particionamento por Hash**: Excelente para distribuição uniforme de dados, evita hotspots e mantém o desempenho rápido.

A diferença nos tempos de execução pode ser explicada pelo fato de que **partition pruning** permite ao Oracle reduzir a quantidade de dados que ele precisa escanear. O particionamento por Range e Hash oferece o melhor desempenho em cenários onde há uma lógica previsível ou distribuição uniforme de dados, enquanto o particionamento por Lista é útil quando se trabalha com conjuntos de valores discretos e não contínuos.

## 4. Impacto no Desempenho:
As técnicas de particionamento, especialmente Range e Hash, ajudam a reduzir o tempo de execução drasticamente quando comparadas a uma tabela não particionada. Isso ocorre porque essas técnicas limitam a área de pesquisa às partições relevantes, melhorando significativamente o desempenho geral do sistema. 

Por fim, a partir desse relatório e análise, podemos concluir que o particionamento pode ser uma solução eficaz para melhorar o desempenho de consultas em grandes conjuntos de dados, especialmente quando bem alinhado com a lógica de uso dos dados.