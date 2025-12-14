#!/bin/bash

# Cria/Limpa os arquivos de saída
echo "Type,N,K,Sched,Chunk,Threads,Time" > dados_A.csv
echo "Type,N,B,Variant,Threads,Time" > dados_B.csv

# Compila para garantir
make all

echo "=== Iniciando Bateria de Testes ==="

# --- TAREFA A ---
# Parâmetros: N, K, Schedule (0=static, 1=dynamic, 2=guided), Chunk, Threads
NS="100000 500000 1000000"
KS="20 24 28"
THREADS="1 2 4 8 16"
CHUNKS="1 4 16 64"

echo "Rodando Tarefa A..."

for N in $NS; do
    for K in $KS; do
        for T in $THREADS; do
            # 5 Execuções para média
            for REP in {1..5}; do
                # 1. Static (Sched=0, Chunk=0 - ignorado)
                ./taskA $N $K 0 0 $T >> dados_A.csv
                
                # 2. Dynamic (Sched=1) com variação de chunks
                for C in $CHUNKS; do
                    ./taskA $N $K 1 $C $T >> dados_A.csv
                done
                
                # 3. Guided (Sched=2) com variação de chunks
                for C in $CHUNKS; do
                    ./taskA $N $K 2 $C $T >> dados_A.csv
                done
            done
        done
    done
done

# --- TAREFA B ---
# Parâmetros: N, B, Variant (1=crit, 2=atom, 3=local), Threads
NS_B="100000 500000 1000000"
BS="32 256 4096"

echo "Rodando Tarefa B..."

for N in $NS_B; do
    for B in $BS; do
        for T in $THREADS; do
             # 5 Execuções para média
            for REP in {1..5}; do
                # Variante 1: Critical
                ./taskB $N $B 1 $T >> dados_B.csv
                
                # Variante 2: Atomic
                ./taskB $N $B 2 $T >> dados_B.csv
                
                # Variante 3: Local
                ./taskB $N $B 3 $T >> dados_B.csv
            done
        done
    done
done

echo "Concluído! Dados salvos em dados_A.csv e dados_B.csv"