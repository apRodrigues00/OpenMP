# Trabalho Prático de OpenMP - IPPD

Este repositório contém a implementação de soluções paralelas utilizando OpenMP para problemas de balanceamento de carga e sincronização.

## Integrantes
*André Pereira Rodrigues (19102468)*

## Estrutura do Projeto
- `src/`: Códigos fonte em C++
  - `tarefaA.cpp`: Cálculo de Fibonacci (Laços Irregulares)
  - `tarefaB.cpp`: Histograma (Sincronização e Atomicidade)
- `dados_A.csv`: Resultados dos testes da Tarefa A
- `dados_B.csv`: Resultados dos testes da Tarefa B
- `grafico_tarefa_A.png`: Gráfico com os testes da Tarefa A
- `grafico_tarefa_B.png`: Gráfico com os testes da Tarefa B
- `Makefile`: Automação de compilação
- `plot.py`: Script para geração de gráficos
- `run.sh`: Script de automação de testes

## Dependências
- Compilador C++ com suporte a OpenMP (GCC ou Clang)
- Python 3 (para plotagem, requer `pandas`, `matplotlib`, `seaborn`)
- Instalação: `pip install pandas matplotlib seaborn`

## Como Compilar e Executar

1. **Compilar o projeto:**
    ```bash
    make all
    ```

2. **Executar a bateria de testes automatizada:** Este comando roda todos os casos de teste e gera os arquivos CSV (dados_A.csv e dados_B.csv).
    ```bash
    ./run.sh
    ```

3. **Gerar os gráficos:** 
    ```bash
    python3 plot.py
    ```

## Tarefas definidas e descrição

**Tarefa A: Load Balancing**
Calcula Fibonacci de forma intensiva para simular carga irregular. Compara políticas de escalonamento:

- static: Divisão fixa.

- dynamic: Alocação sob demanda (vários chunks).

- guided: Chunks decrescentes.

**Tarefa B: Contenção de Memória**
Calcula histograma de um vetor. Compara estratégias de proteção de memória:

- critical: Bloqueio global (alta contenção).

- atomic: Bloqueio por posição de memória.

- local: Agregação em buffers locais (privatização).