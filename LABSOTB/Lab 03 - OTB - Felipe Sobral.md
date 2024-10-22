# Relatório de Laboratório – Lab 03: Refatoração de SQL com Hot Spot

## 1. Experimentos Realizados

### 1.1. Implementação de Rotinas com Controle Sequencial Manual (Hot Spot)

#### 1.1.1. Descrição:
Nesta etapa, será implementada uma rotina em PL/SQL que utiliza controle sequencial manual (Hot Spot) para gerar requisições de inserção de dados em uma tabela.

#### 1.1.2. Procedimento:
1. Criar uma tabela para armazenar os dados:
   ```sql
   CREATE TABLE tabela_hot_spot (
       col1 NUMBER,
       col2 VARCHAR2(100)
   );
   ```

    ![alt text](image-1.png)

2. Criar uma tabela de controle para o sequencial:
   ```sql
   CREATE TABLE tab_controla_id (
       valor_id NUMBER
   );
   INSERT INTO tab_controla_id VALUES (1);
   ```

    ![alt text](image.png)

3. Criar a rotina com controle sequencial manual (Hot Spot):
   ```sql
    DECLARE
        variavel NUMBER;
    BEGIN
        FOR i IN 1..1000000 LOOP
            SELECT valor_id INTO variavel FROM tab_controla_id FOR UPDATE;
            UPDATE tab_controla_id SET valor_id = valor_id + 1;
            INSERT INTO tabela_hot_spot (col1, col2) VALUES (variavel, 'texto1');
            
            COMMIT;
        END LOOP;
    END;
    /
   ```

4. **Execução:** Executar a rotina em duas ou mais janelas do SQL*Plus para gerar paralelismo e concorrência.

    ![alt text](image-2.png)
    ![alt text](image-3.png)
    ![alt text](image-4.png)

5. **Análise de Desempenho do Hot Spot**

- **Tempo total de execução**: A rotina esteve em execução por aproximadamente **1.06 horas** em múltiplas sessões, gerando uma carga de trabalho considerável.
- **I/O Requests**: Foram realizados **1.927 requisições de I/O**, o que indica uma quantidade significativa de operações de entrada/saída de disco, sugerindo um gargalo de I/O.
- **Bytes de I/O**: Aproximadamente **490.9MB** foram transferidos durante a execução.
- **Tempo total de banco de dados**: O tempo total gasto no banco de dados foi de **10.7 segundos**.
- **PL/SQL e Java Time**: O tempo total gasto com execução de blocos **PL/SQL** foi de **54.1ms**, o que parece pequeno, mas o tempo total de execução em múltiplas sessões (cerca de 1.06h) indica um gargalo causado pela sobrecarga de execução simultânea.

6. **Impacto e Problemas do Hot Spot**
A técnica **Hot Spot** envolve uma rotina que faz uso de controle sequencial manual com **FOR UPDATE** em uma tabela de controle de IDs. O principal impacto desta abordagem, conforme observado nas métricas, é:

- **Sobrecarga no Banco de Dados**: Cada sessão precisa realizar um **bloqueio de linha** (lock) na tabela de controle (Hot Spot), o que resulta em alto uso de I/O e tempo de espera em filas, especialmente quando a mesma rotina é executada em múltiplas sessões simultâneas. As operações de **FOR UPDATE** exigem que a sessão mantenha o bloqueio até que a transação seja finalizada, o que gera contenção.
- **Gargalo de I/O**: Com o alto número de sessões simultâneas e operações em cada uma delas, o banco de dados experimenta um grande número de operações de entrada/saída (I/O). Isso pode gerar **congestionamento no sistema de I/O**, como evidenciado pelas **quase 2.000 requisições de I/O** e o tempo de execução prolongado de **1.06 horas**.
- **Baixo Desempenho do PL/SQL**: Embora o tempo de execução das operações **PL/SQL** seja baixo em termos de milissegundos, o gargalo gerado pela sobrecarga do controle manual de IDs com **FOR UPDATE** afeta negativamente o desempenho geral da rotina.

---

### 1.2. Implementação de Rotinas com Controle via Sequence do Oracle

#### 1.2.1. Descrição:
Nesta etapa, será implementada uma rotina em PL/SQL que utiliza uma sequence do Oracle para gerar requisições de inserção de dados em uma tabela.

#### 1.2.2. Procedimento:
1. Criar uma sequence no Oracle:
   ```sql
   CREATE SEQUENCE sequencia START WITH 1 INCREMENT BY 1;
   ```

    ![alt text](image-9.png)

2. Criar a rotina com controle via sequence:
   ```sql
   DECLARE
    variavel NUMBER;
    BEGIN
        FOR i IN 1..1000000 LOOP
            variavel := sequencia.NEXTVAL;

            INSERT INTO tabela_hot_spot (col1, col2) VALUES (variavel, 'texto1');
            
            COMMIT;
        END LOOP;
    END;
    /
   ```

3. **Execução:** Executar a rotina em duas ou mais janelas do SQL*Plus para gerar paralelismo e concorrência.

    ![alt text](image-10.png)
    ![alt text](image-11.png)

4. **Análise de Desempenho com Sequences**

- **Tempo de execução**: As sessões estão rodando há aproximadamente **9.48m a 10.25m**. Isso é significativamente menor comparado à execução de **Hot Spot**, onde o tempo foi superior a **1 hora**.
- **Tempo de banco de dados**: As execuções mostram um **tempo de banco de dados de cerca de 10.42m** para cada sessão, o que também é muito menor em comparação ao **Hot Spot**.
- **I/O Requests**: O número de **requisições de I/O** por sessão variou entre **41 e 164**, bem menor que as **1.927 requisições de I/O** observadas no Hot Spot.
- **Bytes de I/O**: Cada execução processou **20.9MB** de dados, o que é significativamente mais eficiente comparado aos **490.9MB** transferidos nas execuções com Hot Spot.
- **Atividade (%)**: O sistema dedicou **100%** da atividade ao processo, mas o tempo de execução por comando é muito menor do que o observado no Hot Spot.
- **PL/SQL & Java Time**: O tempo total dedicado ao **PL/SQL** é de **13.4ms por execução**, o que é muito eficiente. Na comparação com o Hot Spot, que teve **54.1ms**, é claro que o uso de sequences reduz o overhead do processamento PL/SQL.

5. **Impacto e Benefícios do Uso de Sequences**

A técnica de **sequences** substitui o controle manual de IDs (Hot Spot) por uma solução eficiente e sem bloqueios, resultando em melhorias notáveis no desempenho:

- **Menor Sobrecarga de I/O**: O uso de sequences elimina a necessidade de bloqueios na tabela de controle e, como consequência, reduz drasticamente o número de operações de I/O e o volume de dados processados. Observamos uma redução de **mais de 90% nas requisições de I/O** e bytes transferidos.
  
- **Melhor Concurrency (Concorrência)**: Como não há a necessidade de bloqueios na tabela de controle, múltiplas sessões podem executar o processo sem criar contenção de recursos. No Hot Spot, havia uma contenção severa ao tentar acessar e modificar a mesma linha, mas com sequences, cada sessão trabalha de maneira independente, sem impactar as outras.

- **Tempo de Execução Drasticamente Reduzido**: O tempo de execução por sessão com sequences é cerca de **10 minutos**, em comparação às mais de **1.06 horas no Hot Spot**. Isso se deve à eliminação dos bloqueios e do overhead gerado por múltiplas transações concorrentes.

- **Uso Eficiente de PL/SQL**: O tempo dedicado ao processamento PL/SQL caiu de **54.1ms no Hot Spot** para apenas **13.4ms por execução com sequences**, o que é um reflexo da eficiência desse método para gerar IDs de maneira automática.

---

### 1.3. Comparação entre Hot Spot e Sequence

- **Hot Spot:**
![alt text](image-7.png)
![alt text](image-8.png)

- **Sequence:**
![alt text](image-15.png)
![alt text](image-14.png)

- **Desempenho**: O tempo de execução com sequences é **drasticamente menor** (aproximadamente 10 minutos) comparado ao Hot Spot (mais de 1 hora).
- **Uso de I/O**: O número de operações de entrada/saída e o volume de dados processados são significativamente menores com sequences, o que demonstra a superioridade dessa técnica para ambientes de alta concorrência.
- **Concorrência**: O uso de sequences elimina o problema de contenção de bloqueios presente no Hot Spot, permitindo que múltiplas sessões operem simultaneamente sem comprometer o desempenho.
- **Escalabilidade**: Sequences são muito mais escaláveis em cenários de alto volume e concorrência, enquanto Hot Spot gera gargalos severos devido ao uso de bloqueios.

### 1.4. **Recomendações para Otimização**

- **Uso Padrão de Sequences**: O uso de **sequences** é altamente recomendado em sistemas de banco de dados que precisam gerar valores únicos de maneira concorrente. Ele reduz a necessidade de bloqueios e melhora a escalabilidade do sistema.
  
- **Redução de I/O e Contenção**: A redução de I/O e eliminação de contenção de bloqueios com sequences melhora o desempenho global do sistema e permite o processamento mais rápido das operações.

A análise de desempenho mostra que o uso de **sequences** é uma técnica muito mais eficiente do que o **Hot Spot** para geração de IDs e manipulação de dados em um ambiente concorrente. O uso de sequences reduziu significativamente o tempo de execução, a quantidade de operações de I/O e o volume de dados processados, permitindo maior escalabilidade e eficiência.