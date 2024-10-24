rodar no firefox dentro da VM:

http://localhost:5500/em

login: system  senha: oracle

rodar no sqlplus ou no sqldeveloper:

logado como sys as sysdba


# O laboratório de Explain Plan For

explain plan for select * from OE.product_descriptions where product_id =3057;   --and language_id ='US';

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

select * from OE.product_descriptions where product_id =3057 and language_id ='US';

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

alter table oe.product_descriptions drop primary key;

create index ix_language on oe.product_descriptions (language_id);

select count(*) from OE.product_descriptions;

select * from v$sql where sql_text like '%product_descriptions%';

--sql id: fk9vbvj1ukx4h


# O laboratório de Tuning Task

alter session set container=cdb$root;

ALTER SYSTEM SET control_management_pack_access='DIAGNOSTIC+TUNING' SCOPE=BOTH;

alter session set container=orcl;

DECLARE
  v_Return varchar2(150);
BEGIN
  v_Return := DBMS_SQLTUNE.CREATE_TUNING_TASK (
          sql_id      => 'fk9vbvj1ukx4h'
,         task_name   => 'task_fk9vbvj1ukx4h_01'
,         time_limit => 1800);
END;
/

BEGIN
  DBMS_SQLTUNE.EXECUTE_TUNING_TASK( task_name => 'task_fk9vbvj1ukx4h_01' );
END;
/

set long 65536
set longchunksize 65536
set linesize 250
set pages 0

SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK( 'task_fk9vbvj1ukx4h_01') FROM   DUAL;





