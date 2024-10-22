# Relatório de Laboratório – Lab 06: Pool de Conexões

## 1. Experimentos Realizados

### 1.1. Abertura de Conexões Ilimitadas

#### 1.1.1. Descrição:
Nesta etapa, será implementado um programa que abre conexões ilimitadas ao banco de dados, monitorando o número de sessões abertas até que o banco atinja o limite de conexões.

#### 1.1.2. Procedimento:
1. Implementar o código que abre conexões ilimitadas ao banco de dados:
   ```python
    def open_unlimited_connections():
        connections = []
        try:
            while True:
                # Abre uma nova conexão
                conn = engine.connect()
                connections.append(conn)
                print(f"Conexões abertas: {len(connections)}")
                time.sleep(0.5)  # Atraso para monitoramento
        except Exception as e:
            print(f"Erro ao abrir conexões: {e}")
        finally:
            # Fecha todas as conexões
            for conn in connections:
                conn.close()
            print("Todas as conexões foram fechadas.")
   ```

2. **Execução:** Executar o programa e monitorar o número de conexões abertas.

- **Número de conexões abertas:** O script abriu até 15 conexões antes de encontrar o erro relacionado ao limite de conexões do pool configurado no SQLAlchemy.
O programa tenta abrir novas conexões de forma contínua e, com um intervalo de 0,5 segundos, ele alcançou rapidamente o limite de conexões configurado pelo QueuePool.

3. **Print:** ![alt text](image.png)

4. **Comportamento do banco ao atingir o limite de conexões:** 

- O erro QueuePool limit of size 5 overflow 10 reached indica que o SQLAlchemy está configurado com um pool de conexões de tamanho 5, e que permite um excedente de até 10 conexões. Ou seja, o sistema pode abrir um total de até 15 conexões (5 do pool + 10 extras). Ao tentar abrir a 16ª conexão, o script encontrou um erro de timeout: `connection timed out`. Isso significa que o SQLAlchemy atingiu o limite de conexões permitidas e não conseguiu abrir uma nova conexão dentro do tempo limite configurado.

- O comportamento do banco de dados ao atingir o limite é esperado. O sistema de gerenciamento de conexões (pool de conexões) impõe um limite para evitar que um número excessivo de conexões sobrecarregue o banco. O banco de dados não "crashou" ou teve falhas maiores, mas recusou a criação de novas conexões quando o limite foi atingido. Nenhuma das conexões existentes foi fechada abruptamente; o código foi capaz de detectar o erro e fechar as conexões abertas com sucesso após o limite ser atingido.

### 1.2. Modificação do Programa para Utilizar Apenas uma Conexão

#### 1.2.1. Descrição:
Modificar o programa para utilizar apenas uma conexão compartilhada, evitando a abertura indefinida de novas conexões.

#### 1.2.2. Procedimento:
1. Modificar o código para usar uma única conexão:
   ```python
    def single_connection():
        try:
            # Abre uma única conexão
            conn = engine.connect()
            print("Conexão aberta com sucesso.")

            # Realiza operações dentro da mesma conexão
            for i in range(1000):
                conn.execute(text("SELECT 1 from dual"))
                if i % 100 == 0:
                    print(f"Executando query {i}...")

        except Exception as e:
            print(f"Erro: {e}")
        finally:
            conn.close()
            print("Conexão fechada.")
   ```

2. **Execução:** Executar o programa modificado e monitorar o número de conexões.

- **Tempo de execução:** O tempo total para executar as 1.000 consultas foi 0,250 segundos, o que é muito rápido comparado ao script de conexões ilimitadas, que levou 38,44 segundos antes de atingir o limite de conexões. O tempo de execução extremamente baixo reflete a eficiência do uso de uma conexão única para todas as operações.

3. **Print:** ![alt text](image-1.png)
4. **Comportamento da conexão após a modificação:** 

- **Estabilidade da Conexão:** A conexão única foi aberta com sucesso, permaneceu aberta durante todo o loop de consultas e foi fechada corretamente no final. Não houve erros relacionados ao limite de conexões, como ocorreu no script anterior.

- **Eficiência:** O uso de uma única conexão reduziu significativamente o overhead associado à abertura e fechamento de conexões repetidamente. Em vez de criar uma nova conexão para cada query, o script utilizou uma conexão persistente, resultando em um tempo de execução muito menor.

- **Recursos de I/O e Pool de Conexões:** Com uma única conexão ativa, o script evitou o consumo excessivo de recursos de I/O e também não sobrecarregou o pool de conexões, diferentemente do primeiro experimento. Isso é uma prática ideal para sistemas que precisam de alta eficiência.

O uso de conexões ilimitadas resulta em alta sobrecarga e problemas de escalabilidade, enquanto o uso de uma única conexão provou ser muito mais eficiente, tanto em termos de tempo de execução quanto no consumo de recursos. Esse padrão de conexão única deve ser o preferido em situações onde múltiplas operações são realizadas no banco de dados dentro de uma única sessão.

### 1.3. Implementação de Pool de Conexões

#### 1.3.1. Descrição:
Implementar um pool de conexões no programa para gerenciar as conexões ao banco de dados de maneira eficiente.

#### 1.3.2. Procedimento:
1. Implementar o código que utiliza pool de conexões:
   ```python
    def connection_pool():
        try:
            for i in range(1000):
                # Obtém uma conexão do pool
                with engine.connect() as conn:
                    conn.execute(text("SELECT 1 from dual"))
                    if i % 100 == 0:
                        print(f"Executando query {i} com pool de conexões...")

        except Exception as e:
            print(f"Erro: {e}")
   ```

2. **Execução:** Executar o programa utilizando o pool de conexões.

- **Número de Conexões:** O pool de conexões gerencia de forma eficiente a abertura e fechamento das conexões. Durante a execução, o script obtém uma conexão do pool a cada query e a libera de volta ao pool após o uso (usando o bloco with).

- **Tempo de Execução:** O tempo total de execução foi 0,455 segundos, o que é um pouco mais lento que o script de conexão única (0,25 segundos), mas ainda significativamente mais eficiente do que o script de conexões ilimitadas (38,44 segundos).

3. **Print:** ![alt text](image-2.png)

4. **Como o pool gerencia a liberação das conexões:** 

- O pool de conexões reutiliza conexões abertas, evitando o overhead de criação e fechamento de novas conexões repetidamente. Após o uso de cada conexão, ela é devolvida ao pool automaticamente (graças ao uso do bloco with), garantindo que os recursos sejam utilizados de forma eficiente e controlada.
- Ao contrário do script de conexões ilimitadas, que cria múltiplas conexões até atingir o limite, o pool de conexões garante que um número fixo de conexões seja aberto, e elas são reutilizadas conforme necessário.

5. **Comparação entre as Três Técnicas**

![alt text](image-3.png)

- **Conexões Ilimitadas:** Esta abordagem é ineficiente em termos de uso de memória e recursos, atingindo rapidamente o limite de conexões e resultando em longos tempos de execução. Ela não gerencia a liberação das conexões adequadamente.
- **Conexão Única:** Esta abordagem foi a mais rápida porque abriu apenas uma conexão e a manteve aberta durante toda a execução. Isso evita a sobrecarga de criar novas conexões repetidamente. No entanto, ela não é adequada para cenários de alta concorrência ou múltiplas consultas simultâneas.
- **Pool de Conexões:** O pool de conexões equilibra bem a reutilização de conexões e a eficiência de recursos. Embora o tempo de execução tenha sido ligeiramente superior ao da conexão única, ele ainda foi bastante eficiente. Essa abordagem é ideal para sistemas com alta concorrência e múltiplas queries simultâneas.

### 1.4. Pesquisa sobre Parâmetros do Pool de Conexões

#### 1.4.1. Descrição:
Pesquisar e documentar os parâmetros principais de configuração do pool de conexões utilizado no experimento.

#### 1.4.2. Procedimento:
1. Parâmetros do pool de conexões:
- `pool_size`: Define o número máximo de conexões que o pool pode manter abertas simultaneamente.
- `max_overflow`: Determina quantas conexões extras podem ser criadas além do valor de pool_size quando todas as conexões estão em uso.
- `timeout`: Tempo que o pool de conexões aguardará antes de retornar um erro ao tentar obter uma conexão quando o pool estiver cheio.
- `recycle`: Determina a vida útil de uma conexão no pool antes que ela seja reciclada, garantindo que as conexões sejam periodicamente fechadas e reabertas para evitar problemas de longa duração.

2. O impacto desses parâmetros no desempenho e gerenciamento das conexões no banco de dados:
- `pool_size`: Um valor maior permite mais conexões simultâneas, o que aumenta a capacidade de atender a várias consultas ao mesmo tempo. Um valor muito pequeno pode causar congestionamento e aumentar o tempo de resposta.
- `max_overflow`: Ajuda a lidar com picos de tráfego, permitindo que mais conexões sejam criadas temporariamente. No entanto, valores altos podem sobrecarregar o banco de dados.
- `timeout`: Garante que as consultas não fiquem aguardando indefinidamente por uma conexão. Valores muito curtos podem resultar em falhas frequentes, enquanto valores longos podem atrasar a detecção de problemas.
- `recycle`: Evita que as conexões fiquem abertas por muito tempo, o que pode causar problemas de desempenho a longo prazo. Esse parâmetro garante que as conexões sejam recicladas periodicamente.

O pool de conexões oferece uma excelente combinação de eficiência e escalabilidade, permitindo que o sistema gerencie conexões de forma inteligente, reutilizando recursos e garantindo um desempenho consistente. Com o ajuste correto dos parâmetros do pool, o desempenho e a estabilidade do sistema podem ser otimizados para diferentes cenários de carga.