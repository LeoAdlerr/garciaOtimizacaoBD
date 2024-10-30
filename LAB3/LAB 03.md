# Relatório de Laboratório – Lab 03: Refatoração de SQL com Hot Spot
**Nome:** Leonardo Adler da Silva  
**Tema:** Otimização de Banco de Dados

---

## 1. Experimentos Realizados

### 1.1. Implementação com Controle Sequencial Manual (Hot Spot)

**Descrição:**  
Foi implementada uma rotina em PL/SQL que utiliza controle sequencial manual (Hot Spot) para realizar inserções em uma tabela.

**Procedimento:**
1. Criou-se a tabela `tabela` para armazenar os dados inseridos.
2. Criou-se uma tabela de controle `tab_controla_id` para gerenciar o sequencial de IDs.
3. Implementou-se uma rotina que, em um loop, usa `FOR UPDATE` para obter e atualizar IDs, inserindo os dados na tabela de destino.
4. A rotina foi executada em múltiplas abas do SQL Developer para simular um ambiente de concorrência.

**Resultados (com_hot_spot):**
- **Tempo Total de Execução:** 07m 31.285s
- **Tempo no Banco de Dados:** 1.4h
- **PL/SQL & Java:** 16.5s
- **Atividade (%):** 100%
- **I/O Requests:** 490 requisições de I/O
- **Buffer Gets:** 12M
- **I/O Bytes:** 302.7MB

**Problemas Identificados:**
- **Sobrecarga no Banco de Dados:** O uso de bloqueios (lockings) gerou alta contenção, resultando em uso excessivo de I/O.
- **Gargalo de I/O:** A execução simultânea em várias sessões gerou congestionamento no banco, impactando significativamente o tempo de execução.

### 1.2. Implementação com Controle via Sequence do Oracle

**Descrição:**  
Implementou-se uma rotina em PL/SQL utilizando uma `sequence` para gerenciar a geração de IDs de forma otimizada.

**Procedimento:**
1. Criou-se uma `sequence` no Oracle para gerenciar a atribuição de IDs de forma independente para cada sessão.
2. Implementou-se a rotina que utiliza `NEXTVAL` da `sequence` para gerar e inserir IDs na tabela, sem a necessidade de bloqueios.
3. A rotina foi executada em múltiplas abas do SQL Developer para simular concorrência.

**Resultados (com_seq):**
- **Tempo Total de Execução:** 05m 36.632s
- **Tempo no Banco de Dados:** 5.6m
- **PL/SQL & Java:** 9.8s
- **Atividade (%):** 100%
- **Buffer Gets:** 6,263K
- **I/O Requests:** 408 requisições de I/O
- **I/O Bytes:** 252.3MB

**Benefícios Identificados:**
- **Redução de Sobrecarga de I/O:** O uso de sequences eliminou a necessidade de bloqueios, resultando em um número reduzido de operações de I/O e menor volume de dados processados.
- **Melhor Concorrência:** A utilização de sequences permitiu que as sessões operassem independentemente, sem afetar negativamente o desempenho.

### 1.3. Comparação entre Hot Spot e Sequence

| Métrica             | Hot Spot (com_hot_spot) | Sequence (com_seq)  |
|---------------------|-------------------------|----------------------|
| Tempo de Execução   | 07m 31.285s             | 05m 36.632s         |
| Tempo no Banco      | 1.4h                    | 5.6m                |
| PL/SQL & Java       | 16.5s                   | 9.8s                |
| Atividade (%)       | 100%                    | 100%                |
| I/O Requests        | 490                     | 408                 |
| Buffer Gets         | 12M                     | 6,263K              |
| I/O Bytes           | 302.7MB                 | 252.3MB             |

**Conclusões da Comparação:**
- **Desempenho:** A implementação com sequences demonstrou um tempo de execução reduzido em comparação com o Hot Spot.
- **Uso de I/O:** A sequência apresentou uma significativa economia de I/O e volume de dados, o que também contribuiu para a diminuição do tempo total de execução.
- **Concorrência:** A eliminação de bloqueios pela implementação de sequences melhorou a capacidade de concorrência, reduzindo a contenção que ocorria no Hot Spot.

### 1.4. Recomendações

- **Uso de Sequences:** Com base nos experimentos, recomenda-se fortemente o uso de sequences para a geração de IDs em sistemas que exigem alta concorrência e eficiência no gerenciamento de I/O. A implementação com sequences oferece um ganho substancial de desempenho e escalabilidade em relação ao controle sequencial manual.

---

## Conclusão

A comparação entre as abordagens de controle sequencial manual (Hot Spot) e o uso de sequences demonstra claramente que sequences são superiores para ambientes de alta concorrência. A escolha da abordagem de sequence impacta positivamente o desempenho e a eficiência do banco de dados, reduzindo a sobrecarga de I/O e eliminando contenções de bloqueio.