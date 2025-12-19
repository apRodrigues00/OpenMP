# Informações de Reprodutibilidade

## Hardware
- **Processador:** 12th Gen Intel(R) Core(TM) i5-1235U
- **Memória:** 16GB
- **Sistema Operacional:** Linux

## Software
- **Compilador:** GCC g++ (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0
- **OpenMP:** Versão suportada pelo GCC instalado.

## Metodologia
- Cada ponto nos gráficos representa a média de 5 execuções.
- Os tempos foram medidos usando `omp_get_wtime()`.
- Semente aleatória fixa (42) para garantir a mesma sequência de números na Tarefa B.