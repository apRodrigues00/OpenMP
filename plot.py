import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# Configuração de estilo
sns.set_theme(style="whitegrid")
plt.rcParams.update({"figure.max_open_warning": 0})

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
RESULTS_DIR = os.path.join(BASE_DIR, "results")
DATA_A_PATH = os.path.join(RESULTS_DIR, "dados_A.csv")
DATA_B_PATH = os.path.join(RESULTS_DIR, "dados_B.csv")
PLOT_A_PATH = os.path.join(RESULTS_DIR, "grafico_tarefa_A.png")
PLOT_B_PATH = os.path.join(RESULTS_DIR, "grafico_tarefa_B.png")


def plot_task_a():
    if not os.path.exists(DATA_A_PATH):
        print(f"Arquivo {DATA_A_PATH} não encontrado.")
        return

    df = pd.read_csv(DATA_A_PATH)

    # Pega o maior N e maior K para mostrar o cenário mais crítico
    max_N = df["N"].max()
    max_K = df["K"].max()

    subset = df[(df["N"] == max_N) & (df["K"] == max_K)]

    # Agrupar médias para deixar mais simples o gráfico
    # A ideia é comparar: Static vs Dynamic (Chunk 64) vs Guided (Chunk 64)
    subset_static = subset[subset["Sched"] == "static"]
    subset_dynamic = subset[(subset["Sched"] == "dynamic") & (subset["Chunk"] == 64)]
    subset_guided = subset[(subset["Sched"] == "guided") & (subset["Chunk"] == 64)]

    final_df = pd.concat([subset_static, subset_dynamic, subset_guided])

    plt.figure(figsize=(10, 6))
    sns.lineplot(
        data=final_df,
        x="Threads",
        y="Time",
        hue="Sched",
        style="Sched",
        markers=True,
        dashes=False,
    )

    plt.title(f"Tarefa A: Comparação de Schedules (N={max_N}, K={max_K})")
    plt.ylabel("Tempo (s)")
    plt.xlabel("Número de Threads")
    os.makedirs(RESULTS_DIR, exist_ok=True)
    plt.savefig(PLOT_A_PATH)
    print(f"Gerado: {PLOT_A_PATH}")


def plot_task_b():
    if not os.path.exists(DATA_B_PATH):
        print(f"Arquivo {DATA_B_PATH} não encontrado.")
        return

    df = pd.read_csv(DATA_B_PATH)

    # Pegar cenário com alta contenção (B pequeno) e muito trabalho (N grande)
    max_N = df["N"].max()
    min_B = df["B"].min()  # B=32 gera mais colisão

    subset = df[(df["N"] == max_N) & (df["B"] == min_B)]

    plt.figure(figsize=(10, 6))

    # Usa escala logarítmica, pois o "Local" é muito mais rápido que o "Critical"
    plot = sns.lineplot(
        data=subset,
        x="Threads",
        y="Time",
        hue="Variant",
        style="Variant",
        markers=True,
        dashes=False,
    )
    plot.set(yscale="log")

    plt.title(f"Tarefa B: Sincronização (N={max_N}, B={min_B}) - Escala Log")
    plt.ylabel("Tempo (s) - Log Scale")
    plt.xlabel("Número de Threads")
    os.makedirs(RESULTS_DIR, exist_ok=True)
    plt.savefig(PLOT_B_PATH)
    print(f"Gerado: {PLOT_B_PATH}")


if __name__ == "__main__":
    plot_task_a()
    plot_task_b()
