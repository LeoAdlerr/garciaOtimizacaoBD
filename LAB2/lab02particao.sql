-- criando tabela do lab 02 para criar as particoes
CREATE TABLE sh.costs_comum AS
SELECT * FROM sh.costs;
--result = Table SH.COSTS_COMUM criado.

-- selects semelhantes ao lab 01 porem na tabela criada sh.costs_comum
SET TIMING ON;

SELECT prod_id, time_id, promo_id, channel_id, unit_cost
FROM sh.costs_comum
WHERE unit_cost = 25.62;
-- result = Decorrido: 00:00:00.009

--adicionando PK para exeprimento
ALTER TABLE sh.costs_comum ADD PRIMARY KEY (prod_id, time_id, promo_id, channel_id);
--result = Table SH.COSTS_COMUM alterado.

--select com pk para verificar desempenho com pk
SET TIMING ON;

SELECT prod_id, time_id, promo_id, channel_id, unit_cost
FROM sh.costs_comum
WHERE prod_id = 128;
--result = Decorrido: 00:00:00.240

-- consulta de agregacao na tabela sh.costs_comum
SET TIMING ON;

SELECT prod_id, SUM(unit_cost) AS total_unit_cost
FROM sh.costs_comum
WHERE prod_id = 128
GROUP BY prod_id;
--result = Decorrido: 00:00:00.240

-- criando tabela com agregado calculado
CREATE TABLE sh.costs_summary AS
SELECT prod_id, SUM(unit_cost) AS total_unit_cost
FROM sh.costs_comum
GROUP BY prod_id;
--result = Table SH.COSTS_SUMMARY criado.
ALTER TABLE sh.costs_summary ADD PRIMARY KEY (prod_id);
--result = Table SH.COSTS_SUMMARY alterado.

-- consulta a tabela com agregado calculado
SET TIMING ON;

SELECT prod_id, total_unit_cost
FROM sh.costs_summary
WHERE prod_id = 128;
--result = Decorrido: 00:00:00.019

-- agora visando resultados no OEM loops com as queries acima serao criados

-- dropando a pk para resultado correto do experimento
ALTER TABLE sh.costs_comum drop PRIMARY KEY;
-- result = Table SH.COSTS_COMUM alterado.

-- loop sem pk
SET TIMING ON;

DECLARE
    v_prod_id sh.costs_comum.prod_id%TYPE;
    v_time_id sh.costs_comum.time_id%TYPE;
    v_promo_id sh.costs_comum.promo_id%TYPE;
    v_channel_id sh.costs_comum.channel_id%TYPE;
    v_unit_cost sh.costs_comum.unit_cost%TYPE;
BEGIN
    LOOP
        SELECT prod_id, time_id, promo_id, channel_id, unit_cost
        INTO v_prod_id, v_time_id, v_promo_id, v_channel_id, v_unit_cost
        FROM (
            SELECT prod_id, time_id, promo_id, channel_id, unit_cost
            FROM sh.costs_comum
            WHERE unit_cost = 25.62
            AND ROWNUM = 1
        );
    END LOOP;
END;
/
-- TIME & WAIT STATISTICS =  Duration == 25.0s, DATABASE TIME == 26.8s,  PL/SQL & Java == 0.4s, Activity % == 100
-- I/O Statistics =  Buffer Gets == 4,199K,  I/O Requests == 0, I/O Bytes == 0

-- criando pk novamente
ALTER TABLE sh.costs_comum ADD PRIMARY KEY (prod_id, time_id, promo_id, channel_id);
--result = Table SH.COSTS_COMUcosts_comum

--loop com pk
SET TIMING ON;

DECLARE
    v_prod_id sh.costs_comum.prod_id%TYPE;
    v_time_id sh.costs_comum.time_id%TYPE;
    v_promo_id sh.costs_comum.promo_id%TYPE;
    v_channel_id sh.costs_comum.channel_id%TYPE;
    v_unit_cost sh.costs_comum.unit_cost%TYPE;
BEGIN
    LOOP
        SELECT prod_id, time_id, promo_id, channel_id, unit_cost
        INTO v_prod_id, v_time_id, v_promo_id, v_channel_id, v_unit_cost
        FROM (
            SELECT prod_id, time_id, promo_id, channel_id, unit_cost
            FROM sh.costs_comum
            WHERE prod_id = 128
            AND ROWNUM = 1  -- Limita a consulta a apenas uma linha
        );
    END LOOP;
END;
/
-- TIME & WAIT STATISTICS =  Duration == 50.0s, DATABASE TIME == 50.0s,  PL/SQL & Java == 4.5s, Activity % == 100
-- I/O Statistics =  Buffer Gets == 9,420K,  I/O Requests == 1, I/O Bytes == 8KB

--consulta de soma agregada direto na query
SET TIMING ON;

DECLARE
    v_prod_id sh.costs_comum.prod_id%TYPE;
    v_total_cost NUMBER;
BEGIN
    LOOP
        SELECT prod_id, SUM(unit_cost)
        INTO v_prod_id, v_total_cost
        FROM sh.costs_comum
        WHERE prod_id = 128
        GROUP BY prod_id;
    END LOOP;
END;
/
-- TIME & WAIT STATISTICS =  Duration == 19.0s, DATABASE TIME == 18.0s,  PL/SQL & Java == 81.3ms, Activity % == 100
-- I/O Statistics =  Buffer Gets == 3,691K,  I/O Requests == 0, I/O Bytes == 0

--consulta de soma agregada na tabela pronta
SET TIMING ON;

DECLARE
    v_prod_id sh.costs_summary.prod_id%TYPE;
    v_total_unit_cost sh.costs_summary.total_unit_cost%TYPE;
BEGIN
    LOOP
        SELECT prod_id, total_unit_cost
        INTO v_prod_id, v_total_unit_cost
        FROM sh.costs_summary
        WHERE prod_id = 128;  -- Usando a chave primária
    END LOOP;
END;
/
-- TIME & WAIT STATISTICS =  Duration == 15.0s, DATABASE TIME == 13.5s,  PL/SQL & Java == 1.3s, Activity % == 100
-- I/O Statistics =  Buffer Gets == 1,680K,  I/O Requests == 0, I/O Bytes == 0

--comando explain for do select para entender o plano de execucao
EXPLAIN PLAN FOR
SELECT prod_id, time_id, promo_id, channel_id, unit_cost
FROM sh.costs_comum
WHERE unit_cost = 25.62;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
--irei inserir imagem e comentarios relacionados e esse plano de execucao basicamente houve um full scan e o resultado seriam 14 linhas 

----------------------------------------------------- parte 2 da lab particionamento ---------------------------------------------

--criando versao sem particoes da tabela sh.customers
CREATE TABLE sh.customers_no_partition AS
SELECT * FROM sh.customers;
--result = Table SH.CUSTOMERS_NO_PARTITION criado.

--criando tabela particionada por lista
CREATE TABLE sh.customers_list_partitioned (
    CUST_ID NUMBER,
    CUST_FIRST_NAME VARCHAR2(50),
    CUST_LAST_NAME VARCHAR2(50),
    CUST_YEAR_OF_BIRTH NUMBER,
    CUST_MARITAL_STATUS VARCHAR2(10),
    CUST_STREET_ADDRESS VARCHAR2(100),
    CUST_POSTAL_CODE NUMBER,
    CUST_CITY VARCHAR2(50),
    CUST_CITY_ID NUMBER,
    CUST_STATE_PROVINCE VARCHAR2(50),
    CUST_STATE_PROVINCE_ID NUMBER,
    COUNTRY_ID NUMBER,
    CUST_MAIN_PHONE_NUMBER VARCHAR2(20),
    CUST_INCOME_LEVEL VARCHAR2(50),
    CUST_CREDIT_LIMIT NUMBER,
    CUST_EMAIL VARCHAR2(100),
    CUST_TOTAL VARCHAR2(50),
    CUST_TOTAL_ID NUMBER,
    CUST_SRC_ID NUMBER,
    CUST_EFF DATE
)
PARTITION BY LIST (CUST_STATE_PROVINCE) (
    PARTITION p_scotland VALUES ('Scotland'),
    PARTITION p_wi VALUES ('WI'),
    PARTITION p_mi VALUES ('MI'),
    PARTITION p_ca VALUES ('CA'),
    PARTITION p_other VALUES (DEFAULT)
);
--result = Table SH.CUSTOMERS_LIST_PARTITIONED criado.

--criando tabela particionada por intervalo/range
CREATE TABLE sh.customers_range_partitioned (
    CUST_ID NUMBER,
    CUST_FIRST_NAME VARCHAR2(50),
    CUST_LAST_NAME VARCHAR2(50),
    CUST_YEAR_OF_BIRTH NUMBER,
    CUST_MARITAL_STATUS VARCHAR2(10),
    CUST_STREET_ADDRESS VARCHAR2(100),
    CUST_POSTAL_CODE NUMBER,
    CUST_CITY VARCHAR2(50),
    CUST_CITY_ID NUMBER,
    CUST_STATE_PROVINCE VARCHAR2(50),
    CUST_STATE_PROVINCE_ID NUMBER,
    COUNTRY_ID NUMBER,
    CUST_MAIN_PHONE_NUMBER VARCHAR2(20),
    CUST_INCOME_LEVEL VARCHAR2(50),
    CUST_CREDIT_LIMIT NUMBER,
    CUST_EMAIL VARCHAR2(100),
    CUST_TOTAL VARCHAR2(50),
    CUST_TOTAL_ID NUMBER,
    CUST_SRC_ID NUMBER,
    CUST_EFF DATE
)
PARTITION BY LIST (CUST_INCOME_LEVEL) (
    PARTITION p_Below_30000 VALUES ('A: Below 30,000'),
    PARTITION p_30000_49999 VALUES ('B: 30,000 - 49,999'),
    PARTITION p_50000_69999 VALUES ('C: 50,000 - 69,999'),
    PARTITION p_70000_89999 VALUES ('D: 70,000 - 89,999'),
    PARTITION p_90000_109999 VALUES ('E: 90,000 - 109,999'),
    PARTITION p_110000_129999 VALUES ('F: 110,000 - 129,999'),
    PARTITION p_130000_149999 VALUES ('G: 130,000 - 149,999'),
    PARTITION p_150000_169999 VALUES ('H: 150,000 - 169,999'),
    PARTITION p_170000_189999 VALUES ('I: 170,000 - 189,999'),
    PARTITION p_190000_249999 VALUES ('J: 190,000 - 249,999'),
    PARTITION p_250000_299999 VALUES ('K: 250,000 - 299,999'),
    PARTITION p_Above_300000 VALUES ('L: 300,000 and above'),
    PARTITION p_others VALUES (DEFAULT)  -- Esta partição captura todos os outros valores
);

--result = Table SH.CUSTOMERS_RANGE_PARTITIONED criado.

--criando tabela particionada por hash 
CREATE TABLE sh.customers_hash_partitioned (
    CUST_ID NUMBER,
    CUST_FIRST_NAME VARCHAR2(50),
    CUST_LAST_NAME VARCHAR2(50),
    CUST_YEAR_OF_BIRTH NUMBER,
    CUST_MARITAL_STATUS VARCHAR2(10),
    CUST_STREET_ADDRESS VARCHAR2(100),
    CUST_POSTAL_CODE NUMBER,
    CUST_CITY VARCHAR2(50),
    CUST_CITY_ID NUMBER,
    CUST_STATE_PROVINCE VARCHAR2(50),
    CUST_STATE_PROVINCE_ID NUMBER,
    COUNTRY_ID NUMBER,
    CUST_MAIN_PHONE_NUMBER VARCHAR2(20),
    CUST_INCOME_LEVEL VARCHAR2(50),
    CUST_CREDIT_LIMIT NUMBER,
    CUST_EMAIL VARCHAR2(100),
    CUST_TOTAL VARCHAR2(50),
    CUST_TOTAL_ID NUMBER,
    CUST_SRC_ID NUMBER,
    CUST_EFF DATE
)
PARTITION BY HASH (CUST_ID)
PARTITIONS 10;

-- Verificando os dados em uma partição específica (exemplo: p_scotland)
SELECT * FROM sh.customers_list_partitioned PARTITION (p_scotland);
--result= resultset vazio

-- Verificando os dados em uma partição específica (exemplo: p_wi)
SELECT * FROM sh.customers_list_partitioned PARTITION (p_wi);
--result=50 linhas extraidas

-- Verificando os dados em uma partição específica (exemplo: p_90000_109999)
SELECT * FROM sh.customers_range_partitioned PARTITION (p_90000_109999);
--result = 50 linhas extraidas e unico valor em CUST_INCOME_LEVEL == E: 90,000 - 109,999

-- Verificando os dados em uma partição específica (exemplo: p_others)
SELECT * FROM sh.customers_range_partitioned PARTITION (p_others);
--result = 41 linhas extraidas e unico valor em CUST_INCOME_LEVEL == (null)

-- Verificando os dados em uma partição específica (por exemplo, a partição SYS_P390)
SELECT * FROM sh.customers_hash_partitioned PARTITION (SYS_P390);
-- result = 3.487 linhas selecionadas. Decorrido: 00:00:02.872
 
-- Verificando os dados em uma partição específica (por exemplo, a partição SYS_P386)
SELECT * FROM sh.customers_hash_partitioned PARTITION (SYS_P386);
-- 5.000 linhas selecionadas(ou limite de linhas suportado)  Decorrido: 00:00:04.290










