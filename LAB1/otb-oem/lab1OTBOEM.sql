SET TIMING ON;

DECLARE
    v_promo_id sh.promotions.promo_id%TYPE;
    v_promo_name sh.promotions.promo_name%TYPE;
    v_promo_cost sh.promotions.promo_cost%TYPE;
BEGIN
    LOOP
        SELECT promo_id, promo_name, promo_cost
        INTO v_promo_id, v_promo_name, v_promo_cost
        FROM sh.promotions
        WHERE promo_cost = 300;
    END LOOP;
END;
/

SET TIMING ON;

DECLARE
    v_promo_id sh.promotions.promo_id%TYPE;
    v_promo_name sh.promotions.promo_name%TYPE;
    v_promo_cost sh.promotions.promo_cost%TYPE;
BEGIN
    LOOP
        SELECT promo_id, promo_name, promo_cost
        INTO v_promo_id, v_promo_name, v_promo_cost
        FROM sh.promotions
        WHERE promo_id = 343;
    END LOOP;
END;
/

SET TIMING ON;

DECLARE
    v_cust_id sh.sales.cust_id%TYPE;
    v_amount_sold NUMBER;
BEGIN
    LOOP
        SELECT CUST_ID, SUM(AMOUNT_SOLD)
        INTO v_cust_id, v_amount_sold
        FROM SH.sales
        WHERE CUST_ID = 116
        GROUP BY CUST_ID;
    END LOOP;
END;
/

SET TIMING ON;

BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE sh.sales_summary AS
        SELECT CUST_ID, SUM(AMOUNT_SOLD) AS AMOUNT_SOLD
        FROM SH.sales
        GROUP BY CUST_ID';
END;
/

SET TIMING ON;

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE sh.sales_summary ADD PRIMARY KEY (CUST_ID)';
END;
/


SET TIMING ON;

DECLARE
    v_cust_id sh.sales_summary.cust_id%TYPE;
    v_amount_sold sh.sales_summary.amount_sold%TYPE;
BEGIN
    LOOP
        SELECT CUST_ID, AMOUNT_SOLD
        INTO v_cust_id, v_amount_sold
        FROM SH.sales_summary
        WHERE CUST_ID = 116;
    END LOOP;
END;
/


SELECT acc.constraint_name, ac.constraint_type, acc.column_name
FROM all_cons_columns acc
JOIN all_constraints ac
ON acc.constraint_name = ac.constraint_name
WHERE acc.table_name = 'SALES_SUMMARY'
AND acc.owner = 'SH';


SELECT index_name
FROM all_indexes
WHERE table_name = 'SALES_SUMMARY'
AND owner = 'SH';


SET TIMING ON;

SELECT * 
FROM sh.sales_summary
WHERE CUST_ID = 8349 AND AMOUNT_SOLD = 10420.07;

ALTER TABLE sh.sales_summary ADD PRIMARY KEY (CUST_ID, AMOUNT_SOLD);

SET TIMING ON;

SELECT * 
FROM sh.sales_summary
WHERE CUST_ID = 8349 AND AMOUNT_SOLD = 10420.07;

EXPLAIN PLAN FOR
SELECT * 
FROM sh.sales_summary 
WHERE CUST_ID = 8349 AND AMOUNT_SOLD = 10420.07;

SELECT PLAN_TABLE_OUTPUT
FROM TABLE(DBMS_XPLAN.DISPLAY());

--Tuning task do Oracle
SELECT * FROM v$sql;

DECLARE
    V_return VARCHAR2(150);
BEGIN
    V_return := DBMS_SQLTUNE.CREATE_TUNING_TASK(
        sql_id     => '6y5uhfdaz7zn1',
        task_name  => 'task_01',
        time_limit => 1800
    );
END;
/

-- Executar a tarefa de tuning
BEGIN
    DBMS_SQLTUNE.EXECUTE_TUNING_TASK(task_name => 'task_01');
END;
/

-- Gerar e visualizar o relatório de tuning
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK('task_01') FROM dual;



    





