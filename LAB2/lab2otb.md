conteudo do lab 2 particionamento

1. Pesquisar e Documentar os Tipos de Particionamento no Oracle
O Oracle Database suporta vários tipos de particionamento para otimizar o desempenho das consultas e gerenciar grandes volumes de dados. Os principais tipos de particionamento disponíveis incluem:

Particionamento por Intervalo: Distribui dados em partições com base em intervalos de valores de uma coluna específica (como uma data). Ex.: PARTITION BY RANGE.

Particionamento por Lista: Agrupa dados em partições específicas de acordo com valores predeterminados. Ex.: PARTITION BY LIST.

Particionamento por Hash: Distribui linhas em partições com base em uma função hash aplicada aos valores de uma coluna, para balanceamento de carga. Ex.: PARTITION BY HASH.

Particionamento por Composição (Composite Partitioning): Combinação de dois métodos de particionamento, como RANGE-HASH ou RANGE-LIST, útil para dados com múltiplos níveis de organização.

Particionamento por Intervalo com Subpartições (Interval-Subpartitioning): Expansão automática com base em intervalos de valores e permite subpartições (como LIST ou HASH).

Esses métodos permitem flexibilidade no gerenciamento de dados e eficiência nas operações de consulta, facilitando o desempenho em consultas complexas.

2. Criar uma Nova Tabela Não Particionada a partir de SH.COSTS
Execute o comando abaixo para criar uma cópia não particionada da tabela SH.COSTS, denominada sh.costs_comum:

CREATE TABLE sh.costs_comum AS
SELECT * FROM sh.costs;

3. Executar as Consultas do Lab 01 na Tabela sh.costs_comum com e sem PK
Agora, vamos realizar as consultas do Lab 01 adaptadas para sh.costs_comum, documentando os resultados com e sem chave primária.

a) Adicionar e Remover a Chave Primária (PK)
Para adicionar uma chave primária na coluna CUST_ID:
ALTER TABLE sh.costs_comum ADD PRIMARY KEY (cust_id);

Para remover a chave primária:

sql
Copy code
ALTER TABLE sh.costs_comum DROP PRIMARY KEY;
b) Executar as Consultas e Documentar os Resultados
Com PK: Execute as consultas usadas no Lab 01 (como filtros por CUST_ID e AMOUNT_SOLD) e documente o tempo de execução e o plano de execução de cada consulta.

Sem PK: Repita as consultas, desta vez sem a chave primária. Observe as diferenças de desempenho e o impacto nos planos de execução.

4. Executar as Consultas na Tabela SH.COSTS e Documentar os Resultados
a) Consultas com PK e sem PK
Repita o processo para a tabela original SH.COSTS:

Adicionar e Remover PK em SH.COSTS (conforme necessário, considerando os requisitos do banco de dados).

Executar Consultas e Comparar:

Execute as mesmas consultas feitas na tabela sh.costs_comum.
Compare o tempo de execução e o plano de execução para cada caso (com e sem PK).
5. Monitorar a Execução dos Comandos com o Oracle Enterprise Manager (OEM)
Use o Oracle Enterprise Manager para monitorar a execução das consultas e identificar possíveis gargalos. Anote as métricas de tempo e recursos usados para cada consulta, tanto na tabela particionada (SH.COSTS) quanto na não particionada (sh.costs_comum).

6. Utilizar o Comando EXPLAIN PLAN para Obter o Plano de Execução
Para cada consulta executada, gere o plano de execução utilizando o EXPLAIN PLAN para verificar como o Oracle processa cada uma delas.

Exemplo:

sql
Copy code
EXPLAIN PLAN FOR
SELECT * FROM sh.costs_comum WHERE cust_id = 8349 AND amount_sold = 10420.07;

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY());
Faça isso para cada consulta, tanto na tabela particionada quanto na não particionada. Documente os passos de acesso, o uso de índices e o impacto de ter ou não uma chave primária.

Resumo dos Resultados e Documentação
Após executar todas as etapas, faça uma análise comparativa entre o desempenho da tabela particionada (SH.COSTS) e da tabela não particionada (sh.costs_comum). Considere aspectos como:

Impacto da presença e ausência da chave primária em consultas.
Diferenças nos planos de execução.
Vantagens de particionamento para a organização e eficiência das tabelas.
Essas etapas fornecerão uma visão detalhada dos benefícios e desafios das tabelas particionadas versus não particionadas no Oracle Database, além de demonstrar como índices e chaves primárias afetam o desempenho das consultas.


ChatGPT said:
ChatGPT
Para implementar o particionamento na tabela sh.customers no Oracle, vamos criar três tabelas com regras de particionamento distintas. Este exercício visa praticar a sintaxe de particionamento e observar o comportamento do Oracle ao inserir dados.

1. Particionamento por Lista
Primeiro, vamos criar uma tabela particionada por lista com base em uma coluna de estado ou país. Neste exemplo, vamos supor que a coluna COUNTRY_ID representa o país do cliente, e particionaremos a tabela por diferentes valores dessa coluna.

Criação da Tabela Particionada por Lista
sql
Copy code
CREATE TABLE sh.customers_list_partitioned (
    cust_id       NUMBER,
    cust_first_name VARCHAR2(50),
    cust_last_name  VARCHAR2(50),
    country_id    NUMBER,
    cust_year_of_birth NUMBER,
    cust_marital_status VARCHAR2(20),
    cust_income_level VARCHAR2(20),
    cust_credit_limit NUMBER
)
PARTITION BY LIST (country_id) (
    PARTITION usa VALUES (1),
    PARTITION canada VALUES (2),
    PARTITION mexico VALUES (3),
    PARTITION others VALUES (DEFAULT)
);
Inserção de Dados
Para inserir dados da tabela original sh.customers na tabela particionada:

sql
Copy code
INSERT INTO sh.customers_list_partitioned
SELECT * FROM sh.customers;
Visualizar Dados em uma Partição Específica
Para verificar o conteúdo de uma partição específica (por exemplo, usa):

sql
Copy code
SELECT * FROM sh.customers_list_partitioned PARTITION (usa);
2. Particionamento por Intervalo (Range) com Base em uma Coluna de Data
Agora, vamos criar uma tabela particionada por intervalo com base na coluna SIGNUP_DATE, considerando um intervalo diário. Caso SIGNUP_DATE não exista, você pode escolher uma coluna de data apropriada, ou adicionar essa coluna para o exercício.

Criação da Tabela Particionada por Intervalo
sql
Copy code
CREATE TABLE sh.customers_range_partitioned (
    cust_id       NUMBER,
    cust_first_name VARCHAR2(50),
    cust_last_name  VARCHAR2(50),
    signup_date   DATE,
    country_id    NUMBER,
    cust_year_of_birth NUMBER,
    cust_marital_status VARCHAR2(20),
    cust_income_level VARCHAR2(20),
    cust_credit_limit NUMBER
)
PARTITION BY RANGE (signup_date) (
    PARTITION p20220101 VALUES LESS THAN (TO_DATE('2022-01-01', 'YYYY-MM-DD')),
    PARTITION p20220201 VALUES LESS THAN (TO_DATE('2022-02-01', 'YYYY-MM-DD')),
    PARTITION p20220301 VALUES LESS THAN (TO_DATE('2022-03-01', 'YYYY-MM-DD')),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);
Inserção de Dados
Inserindo os dados na tabela particionada por intervalo:

sql
Copy code
INSERT INTO sh.customers_range_partitioned
SELECT * FROM sh.customers;
Visualizar Dados em uma Partição Específica
Para visualizar os registros na partição p20220201:

sql
Copy code
SELECT * FROM sh.customers_range_partitioned PARTITION (p20220201);
3. Particionamento por Hash
A terceira tabela será particionada por hash, distribuindo os dados uniformemente entre 10 partições, sem se preocupar com valores específicos. Vamos particionar com base na coluna CUST_ID.

Criação da Tabela Particionada por Hash
sql
Copy code
CREATE TABLE sh.customers_hash_partitioned (
    cust_id       NUMBER,
    cust_first_name VARCHAR2(50),
    cust_last_name  VARCHAR2(50),
    country_id    NUMBER,
    cust_year_of_birth NUMBER,
    cust_marital_status VARCHAR2(20),
    cust_income_level VARCHAR2(20),
    cust_credit_limit NUMBER
)
PARTITION BY HASH (cust_id)
PARTITIONS 10;
Inserção de Dados
Para inserir dados na tabela particionada por hash:

sql
Copy code
INSERT INTO sh.customers_hash_partitioned
SELECT * FROM sh.customers;
Visualizar Dados em uma Partição Específica
Para ver o conteúdo de uma das partições, como SYS_P1, que é nomeada automaticamente pelo Oracle:

sql
Copy code
SELECT * FROM sh.customers_hash_partitioned PARTITION (SYS_P1);
Resumo
Este exercício permitiu criar três tipos de tabelas particionadas (por lista, por intervalo, e por hash) e inserimos dados da tabela sh.customers em cada uma. Utilize o comando EXPLAIN PLAN se desejar ver o plano de execução para consultas em cada tabela, o que pode ajudar a entender o impacto do particionamento em futuras operações de leitura e escrita.

Se precisar de mais detalhes sobre o comportamento ou monitoramento das operações de particionamento, o Oracle Enterprise Manager (OEM) pode ser útil para analisar o desempenho.