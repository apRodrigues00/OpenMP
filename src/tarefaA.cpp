#include <cstdlib>
#include <iostream>
#include <omp.h>
#include <string>
#include <vector>

/*
    Tarefa A - Conceito
    O objetivo aqui é simular um problema de Desbalanceamento de Carga.
    Como calcularemos fib(i % K), alguns índices i vão pedir um Fibonacci
   pequeno (rápido) e outros um Fibonacci grande (lento).

    * Se usar schedule(static), uma thread pode ter o azar de pegar todos os
   números "pesados" e demorar muito, enquanto as outras ficam ociosas esperando
   ela.
    * O dynamic e o guided servem justamente para distribuir essa "bucha" de
   forma mais inteligente sob demanda.
*/

// Function Fibonacci (custosa) -> O objetivo é gastar CPU
long long fib(int n)
{
    if (n < 2)
        return n;
    return fib(n - 1) + fib(n - 2);
}

int main(int argc, char *argv[])
{
    // Parâmetros esperados: N, K, schedule_type, chunk_size
    // schedule_type: 0=static, 1=dynamic, 2=guided
    if (argc < 5)
    {
        std::cerr << "Uso: " << argv[0]
                  << " <N> <K> <sched: 0=static, 1=dynamic, 2=guided> <chunk> "
                     "[threads]"
                  << std::endl;
        return 1;
    }

    int N = std::atoi(argv[1]);
    int K = std::atoi(argv[2]);
    int sched = std::atoi(argv[3]);
    int chunk = std::atoi(argv[4]);

    // Se passar o número de threads como 5º argumento, define. Senão, usa o
    // padrão do sistema
    if (argc >= 6)
    {
        omp_set_num_threads(std::atoi(argv[5]));
    }

    std::vector<long long> v(N);
    double start_time, end_time;

    start_time = omp_get_wtime();

    if (sched == 0)
    {
// Variante 1: Static
#pragma omp parallel for schedule(static)
        for (int i = 0; i < N; i++)
        {
            v[i] = fib(i % K);
        }
    }
    else if (sched == 1)
    {

// Variante 2: Dynamic com chunk variável
#pragma omp parallel for schedule(dynamic, chunk)
        for (int i = 0; i < N; i++)
        {
            v[i] = fib(i % K);
        }
    }
    else if (sched == 2)
    {
// Variante 3: Guided com chunk variável
#pragma omp parallel for schedule(guided, chunk)
        for (int i = 0; i < N; i++)
        {
            v[i] = fib(i % K);
        }
    }

    end_time = omp_get_wtime();

    // Formato da saída:  Type, N, K, Sched, Chunk, Threads, Time
    std::cout << "TASK_A," << N << "," << K << ","
              << (sched == 0 ? "static" : (sched == 1 ? "dynamic" : "guided"))
              << "," << chunk << "," << omp_get_max_threads() << ","
              << (end_time - start_time) << std::endl;

    return 0;
}