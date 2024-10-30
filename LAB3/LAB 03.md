Relatório de Laboratório – Lab 03: Refatoração de SQL com Hot Spot
1. Experimentos Realizados
1.1. Implementação com Controle Sequencial Manual (Hot Spot)
Descrição: Foi implementada uma rotina em PL/SQL utilizando controle sequencial manual (Hot Spot) para gerar inserções em uma tabela.

Procedimento:

Criou-se a tabela tabela para armazenar os dados.

Criou-se uma tabela de controle tab_controla_id para gerenciar o sequencial.

Implementou-se a rotina que, em um loop, faz uso de FOR UPDATE para obter e atualizar IDs, inserindo dados na tabela.

A rotina foi executada em múltiplas abas do SQL Developer para gerar concorrência.
Resultados:

Tempo de Execução: Aproximadamente 7m 30s.
I/O Requests: 1.927 requisições de I/O.
Bytes de I/O: 490.9MB transferidos.
Tempo total no banco: 10.7 segundos.
Problemas Identificados:

Sobrecarga no Banco de Dados: O uso de bloqueios gerou contenção e alta utilização de I/O.
Gargalo de I/O: O alto número de sessões causou congestionamento, resultando em um tempo de execução prolongado.
1.2. Implementação com Controle via Sequence do Oracle
Descrição: Implementou-se uma rotina em PL/SQL que utiliza uma sequence para gerar inserções em uma tabela.

Procedimento:

Criou-se uma sequence no Oracle para gerenciar IDs.

A rotina foi executada em múltiplas abas do SQL Developer para gerar concorrência.
Resultados:

Tempo de Execução: Aproximadamente 5m 30s.
I/O Requests: Variou entre 41 e 164 requisições de I/O.
Bytes de I/O: 20.9MB processados por execução.
Tempo total no banco: 10.42m.
Benefícios Identificados:

Menor Sobrecarga de I/O: O uso de sequences eliminou a necessidade de bloqueios, reduzindo significativamente o número de operações de I/O e o volume de dados processados.
Melhor Concurrency: As múltiplas sessões operaram independentemente, sem comprometer o desempenho.

1.3. Comparação entre Hot Spot e Sequence
Desempenho: O tempo de execução com sequences foi drasticamente menor (aproximadamente 5m 30s) comparado ao Hot Spot (7m 30s).
Uso de I/O: As operações de I/O e o volume de dados processados foram significativamente menores com sequences.
Concorrência: O uso de sequences eliminou a contenção de bloqueios presente no Hot Spot.

1.4. Recomendações
Uso de Sequences: Recomenda-se o uso de sequences para geração de IDs em sistemas de banco de dados que exigem alta concorrência, devido à sua eficiência e escalabilidade.
Conclusão
A comparação entre as abordagens de controle sequencial manual (Hot Spot) e o uso de sequences demonstra claramente que a implementação de sequences oferece vantagens significativas em ambientes de alta concorrência. A escolha de uma abordagem adequada pode ter um impacto substancial no desempenho e na eficiência do sistema de banco de dado