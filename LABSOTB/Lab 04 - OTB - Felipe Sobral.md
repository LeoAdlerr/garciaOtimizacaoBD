# Relatório de Laboratório – Lab 04: Parse e Variáveis Embutidas

## 1. Experimentos Realizados

### 1.1. Implementação de Comandos SQL Hardcoded

#### 1.1.1. Descrição:
Nesta etapa, será implementada uma rotina em uma linguagem de programação (optei pelo Python) para realizar consultas SQL utilizando comandos hardcoded.

#### 1.1.2. Procedimento:
1. Criar um código que execute 100.000 vezes o seguinte comando SQL hardcoded:
   ```sql
   SELECT * FROM employees WHERE employee_id = 1021;
   ```

2. Utilizar a linguagem de programação para implementar o código hardcoded:
   ```python
   def hardcoded_query():
    with engine.connect() as conn:
        for _ in range(100000):
            conn.execute(text("SELECT * FROM employees WHERE employee_id = 1021"))
   ```

3. **Execução:** Executar o código e medir o tempo total de execução.
4. **Print:** ![alt text](image.png)

### 1.2. Implementação de Comandos SQL Softcoded

#### 1.2.1. Descrição:
Nesta etapa, será implementada uma rotina em uma linguagem de programação para realizar consultas SQL utilizando prepared statements (softcoded).

#### 1.2.2. Procedimento:
1. Criar um código que execute 100.000 vezes o seguinte comando SQL softcoded utilizando prepared statements:
   ```sql
   SELECT * FROM employees WHERE employee_id = :id;
   ```

2. Utilizar a linguagem de programação para implementar o código softcoded:
   ```python
   def softcoded_query():
    with engine.connect() as conn:
        statement = text("SELECT * FROM employees WHERE employee_id = :id")
        for _ in range(100000):
            conn.execute(statement, {"id": 1021})
   ```

3. **Execução:** Executar o código e medir o tempo total de execução.
4. **Print:** ![alt text](image-1.png)

### 1.3. Comparação entre Hardcoded e Softcoded

#### 1.3.1. Descrição:
Comparar o tempo de execução entre as rotinas que utilizam comandos hardcoded e softcoded, com o objetivo de verificar o impacto no desempenho.

### 1.3.2 Análise dos Resultados:

![alt text](3e0eb0ab-de86-4873-986a-069b5319095c.png)

Os tempos de execução observados foram:

- **Hardcoded**: 27.82 segundos
- **Softcoded**: 26.58 segundos

A diferença observada entre os tempos de execução com **hardcoded** e **softcoded** foi relativamente pequena (cerca de 1.24 segundos), com o **softcoded** apresentando uma performance ligeiramente superior ao hardcoded.

### 1.3.3 Impacto no Desempenho:

O uso de consultas **hardcoded** implica na repetição da mesma string SQL a cada execução. Essa abordagem pode ter um impacto marginal no desempenho devido ao fato de o banco de dados precisar recompilar ou analisar a string SQL repetidamente.

Por outro lado, o uso de **prepared statements** (softcoded) melhora ligeiramente o desempenho ao reutilizar a mesma consulta preparada (com parâmetros). Isso elimina a necessidade de recompilar ou analisar a consulta para cada execução, resultando em menor overhead. Embora a diferença de desempenho observada neste teste tenha sido pequena, em cenários com maior volume de dados ou maior complexidade de consultas, o ganho de performance com **softcoded** tende a ser mais significativo.

### 1.3.4 Porque a diferença no tempo de execução é tão pequena?

A diferença é pequena porque:

- A consulta SQL é simples.
- O Oracle reutiliza planos de execução através do cache de queries, minimizando o overhead de recompilação.
- O volume de dados e a complexidade das operações são baixos no contexto do teste.

Em sistemas mais complexos ou com alto volume de dados, a diferença entre hardcoded e softcoded seria mais significativa, pois o overhead de recompilação de consultas se tornaria mais evidente.