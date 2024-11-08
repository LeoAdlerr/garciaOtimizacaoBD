-- Habilitar a medi��o de tempo
SET TIMING ON;

-- Consulta sem PK, usando a coluna promo_cost que n�o possui �ndice prim�rio
SELECT promo_id, promo_name, promo_cost
FROM sh.promotions
WHERE promo_cost = 300;


-- Habilitar a medi��o de tempo
SET TIMING ON;

-- Consulta com PK, utilizando a coluna promo_id que possui �ndice prim�rio
SELECT promo_id, promo_name, promo_cost
FROM sh.promotions
WHERE promo_id = 343;

-- Habilitar medi��o de tempo
SET TIMING ON;

-- Consulta para somar o valor de `AMOUNT_SOLD` para o `cust_id` 116
SELECT CUST_ID, SUM(AMOUNT_SOLD)
FROM SH.sales
WHERE CUST_ID = 116
GROUP BY CUST_ID;


-- Habilitar medi��o de tempo
SET TIMING ON;

-- Criar a tabela consolidada com a soma de `AMOUNT_SOLD` por `CUST_ID`
CREATE TABLE sh.sales_summary AS
SELECT CUST_ID, SUM(AMOUNT_SOLD) AS AMOUNT_SOLD
FROM SH.sales
GROUP BY CUST_ID;

-- Habilitar medi��o de tempo
SET TIMING ON;

-- Adicionar a chave prim�ria � tabela consolidada
ALTER TABLE sh.sales_summary ADD PRIMARY KEY (CUST_ID);


-- Habilitar medi��o de tempo
SET TIMING ON;

-- Consulta usando a tabela consolidada para obter o total de `AMOUNT_SOLD` para o `cust_id` 116
SELECT CUST_ID, AMOUNT_SOLD
FROM SH.sales_summary
WHERE CUST_ID = 116;

----- Parte 2 do LAB 1 -------------

-- Criar uma nova tabela baseada em `sh.promotions` sem constraints
CREATE TABLE promotions_no_constraints AS 
SELECT * FROM sh.promotions;

-- Criar um �ndice �nico simples em `promo_id` na nova tabela
CREATE UNIQUE INDEX idx_promo_id_unique_no_constraints ON promotions_no_constraints(promo_id);

-- Consulta usando `promo_id` na tabela sem constraints
SELECT promo_id, promo_name
FROM promotions_no_constraints
WHERE promo_id = 343;

-- Remover o �ndice �nico simples
DROP INDEX idx_promo_id_unique_no_constraints;

-- Criar um �ndice n�o-�nico simples em `promo_cost`
CREATE INDEX idx_promo_cost_no_constraints ON promotions_no_constraints(promo_cost);

-- Consulta usando `promo_cost` na nova tabela sem constraints
SELECT promo_id, promo_name, promo_cost
FROM promotions_no_constraints
WHERE promo_cost = 400;

-- Remover o �ndice n�o-�nico simples
DROP INDEX idx_promo_cost_no_constraints;

-- Criar um �ndice n�o-�nico composto em `promo_subcategory_id` e `promo_category_id`
CREATE INDEX idx_promo_subcat_cat_no_constraints ON promotions_no_constraints(promo_subcategory_id, promo_category_id);

-- Consulta usando `promo_subcategory_id` e `promo_category_id` na tabela sem constraints
SELECT promo_id, promo_name, promo_cost
FROM promotions_no_constraints
WHERE promo_subcategory_id = 20 AND promo_category_id = 9;

-- Remover o �ndice n�o-�nico composto
DROP INDEX idx_promo_subcat_cat_no_constraints;



















