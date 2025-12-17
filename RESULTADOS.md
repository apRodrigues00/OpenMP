# Análise Experimental

## Ambiente de Testes
- **CPU:** Intel Core i5-1235U
- **Threads:** Testes variando de 1 a 16 threads.
- **Compilador:** GCC com flag `-O3 -fopenmp`.

---

## Tarefa A: Laços e Escalonamento (Fibonacci)

O objetivo foi avaliar o comportamento de diferentes escalonadores (*schedules*) em um cenário de carga irregular (cálculo de Fibonacci dependente do índice).

### Gráfico de Desempenho
![Gráfico Tarefa A](grafico_tarefa_A.png)
*(Eixo Y representa o tempo em segundos - quanto menor, melhor)*

### Análise
1. **Schedule Static:** Apresentou o pior desempenho em cargas desbalanceadas. Como o tempo de processamento de `fib(i)` varia drasticamente, algumas threads terminam cedo e ficam ociosas esperando as que pegaram iterações pesadas.
2. **Schedule Dynamic:** Mostrou-se superior ao Static. A distribuição sob demanda permite que threads rápidas "ajudem" processando mais chunks, mantendo a ocupação da CPU alta.
3. **Schedule Guided:** Apresentou resultados competitivos com o Dynamic, sendo eficaz por reduzir o overhead de gerenciamento de chunks conforme o laço avança.

**Conclusão A:** Para cargas irregulares, o uso de `schedule(dynamic)` ou `guided` é mandatório para obter *speedup* real. O `static` sofre severamente com o desbalanceamento.

---

## Tarefa B: Sincronização e Histogramas

Avaliou-se o impacto de seções críticas e operações atômicas na construção de um histograma compartilhado.

### Gráfico de Desempenho (Escala Logarítmica)
![Gráfico Tarefa B](grafico_tarefa_B.png)
*(Atenção: Escala Logarítmica. A diferença real é de várias ordens de grandeza)*

### Análise
1. **Critical (v1):** Desempenho catastrófico. O uso de uma seção crítica nomeada serializa o acesso ao histograma inteiro. O tempo de execução não escala e, em muitos casos, é pior que a versão sequencial devido ao overhead de bloqueio.
2. **Atomic (v2):** Melhoria significativa sobre o Critical, pois o bloqueio ocorre a nível de instrução de hardware e apenas no endereço específico. Contudo, em vetores de histograma pequenos (B=32), a alta taxa de colisão (várias threads escrevendo no mesmo índice) ainda limita o ganho.
3. **Agregação Local (v3):** Desempenho excelente. Ao criar histogramas privados para cada thread e somá-los apenas no final, eliminamos quase totalmente a contenção. O *speedup* é quase linear.

**Conclusão B:** Evitar sincronização frequente é a regra de ouro. A estratégia de privatização (agragação local) é ordens de grandeza superior ao uso de primitivas de sincronização (`critical` ou `atomic`) dentro de laços quentes.