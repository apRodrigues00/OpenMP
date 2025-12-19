#!/bin/bash
set -euo pipefail

UV_ENV_DIR="${UV_ENV_DIR:-.venv}"
UV_PYTHON="${UV_PYTHON:-python3}"

if ! command -v uv >/dev/null 2>&1; then
    echo "Erro: uv nao encontrado. Instale uv para rodar este script." >&2
    exit 1
fi

if [ ! -d "$UV_ENV_DIR" ]; then
    uv venv --no-managed-python --no-python-downloads -p "$UV_PYTHON" "$UV_ENV_DIR"
fi

UV_RUN=(uv run --no-project --python "$UV_ENV_DIR/bin/python" --)

RESULTS_DIR="results/integration"
DATA_A="$RESULTS_DIR/dados_A.csv"
DATA_B="$RESULTS_DIR/dados_B.csv"
PLOT_A="$RESULTS_DIR/grafico_tarefa_A.png"
PLOT_B="$RESULTS_DIR/grafico_tarefa_B.png"

# Cria/Limpa os arquivos de saída
mkdir -p "$RESULTS_DIR"
echo "Type,N,K,Sched,Chunk,Threads,Time" > "$DATA_A"
echo "Type,N,B,Variant,Threads,Time" > "$DATA_B"

# Compila para garantir
CXX="${CXX:-}"
if [ -z "$CXX" ]; then
    for candidate in g++-15 g++-14 g++-13 g++-12 g++; do
        if command -v "$candidate" >/dev/null 2>&1; then
            CXX="$candidate"
            break
        fi
    done
fi

if [ -z "$CXX" ]; then
    echo "Erro: g++ nao encontrado. Instale GCC (ex: brew install gcc)." >&2
    exit 1
fi

make CXX="$CXX" all

echo "=== Iniciando Integration Test ==="

# --- TAREFA A ---
# Parâmetros reduzidos: N, K, Schedule (0=static, 1=dynamic, 2=guided), Chunk, Threads
NS="1000 5000"
KS="10 14"
THREADS="1 2"
CHUNKS="1 4"
REPS=1

echo "Rodando Tarefa A (integration)..."

for N in $NS; do
    for K in $KS; do
        for T in $THREADS; do
            for REP in $(seq 1 $REPS); do
                # 1. Static (Sched=0, Chunk=0 - ignorado)
                "${UV_RUN[@]}" ./taskA $N $K 0 0 $T >> "$DATA_A"

                # 2. Dynamic (Sched=1) com variacao de chunks
                for C in $CHUNKS; do
                    "${UV_RUN[@]}" ./taskA $N $K 1 $C $T >> "$DATA_A"
                done

                # 3. Guided (Sched=2) com variacao de chunks
                for C in $CHUNKS; do
                    "${UV_RUN[@]}" ./taskA $N $K 2 $C $T >> "$DATA_A"
                done
            done
        done
    done
done

# --- TAREFA B ---
# Parâmetros reduzidos: N, B, Variant (1=crit, 2=atom, 3=local), Threads
NS_B="1000 5000"
BS="32 128"

echo "Rodando Tarefa B (integration)..."

for N in $NS_B; do
    for B in $BS; do
        for T in $THREADS; do
            for REP in $(seq 1 $REPS); do
                # Variante 1: Critical
                "${UV_RUN[@]}" ./taskB $N $B 1 $T >> "$DATA_B"

                # Variante 2: Atomic
                "${UV_RUN[@]}" ./taskB $N $B 2 $T >> "$DATA_B"

                # Variante 3: Local
                "${UV_RUN[@]}" ./taskB $N $B 3 $T >> "$DATA_B"
            done
        done
    done
done

echo "Concluido! Dados salvos em $DATA_A e $DATA_B"

echo "Gerando graficos (integration)..."
if ! "${UV_RUN[@]}" python - <<'PY'
import pandas
import matplotlib
import seaborn
PY
then
    uv pip install --python "$UV_ENV_DIR/bin/python" pandas matplotlib seaborn
fi

DATA_A_PATH="$DATA_A" DATA_B_PATH="$DATA_B" \
PLOT_A_PATH="$PLOT_A" PLOT_B_PATH="$PLOT_B" \
"${UV_RUN[@]}" python plot.py
