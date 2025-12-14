#include <iostream>
#include <vector>
#include <omp.h>
#include <cstdlib>
#include <random>

/*
    Tarefa B - Conceito
    Aqui temos um vetor gigante A cheio de números aleatórios e queremos contar quantas vezes cada número aparece (Histograma).

    * Problema: Várias threads tentarão incrementar a mesma posição do vetor de contagem H ao mesmo tempo. Ex: Thread 1 quer somar H[5]++ e Thread 2 também quer somar H[5]++.
    * v1 (Critical): Coloca um "porteiro" no vetor inteiro. Só uma thread mexe no histograma por vez. (Lentíssimo).
    * v2 (Atomic): O hardware protege apenas o endereço de memória específico. Melhor, mas se o vetor for pequeno (poucos baldes), ainda dá muita colisão.
    * v3 (Local): Cada thread tem seu próprio caderno de anotações (histograma local). Elas contam tudo sozinhas e, no final, somam seus cadernos no caderno oficial (Global). Consequência: é o mais rápido!
*/

int main(int argc, char *argv[])
{
    // Parâmetros: N, B, Variante (1=critical, 2=atomic, 3=local), Threads
    if (argc < 4)
    {
        std::cerr << "Uso: " << argv[0] << " <N> <B> <variante: 1=crit, 2=atom, 3=local> [threads]" << std::endl;
        return 1;
    }

    int N = std::atoi(argv[1]);
    int B = std::atoi(argv[2]); // Número de buckets (tamanho do histograma)
    int variant = std::atoi(argv[3]);

    if (argc >= 5)
    {
        omp_set_num_threads(std::atoi(argv[4]));
    }

    // Inicialização do vetor de dados A com valores aleatórios entre [0, B-1]
    std::vector<int> A(N);
    // Usando um gerador determinístico para garantir que todas as execuções sejam iguais
    std::mt19937 gen(42);
    std::uniform_int_distribution<> dis(0, B - 1);

    for (int i = 0; i < N; i++)
    {
        A[i] = dis(gen);
    }

    // Vetor de saída (Histograma)
    std::vector<int> H(B, 0);

    double start_time, end_time;
    start_time = omp_get_wtime();

    if (variant == 1)
    {
// v1: Critical (O pior caso)
// O critical protege o bloco inteiro. Nenhuma outra thread executa isso simultaneamente.
#pragma omp parallel for
        for (int i = 0; i < N; i++)
        {
#pragma omp critical
            {
                H[A[i]]++;
            }
        }
    }
    else if (variant == 2)
    {
// v2: Atomic (Melhor que critical)
// Protege apenas a atualização da memória específica.
#pragma omp parallel for
        for (int i = 0; i < N; i++)
        {
#pragma omp atomic
            H[A[i]]++;
        }
    }
    else if (variant == 3)
    {
// v3: Agregação Local (Geralmente a mais rápida)
#pragma omp parallel
        {
            // Histograma privado para cada thread
            std::vector<int> local_H(B, 0);

// Cada thread processa sua parte do loop e grava no local_H
// O 'nowait' é usado pois não é preciso sincronizar ao fim do for, apenas antes de mesclar
#pragma omp for nowait
            for (int i = 0; i < N; i++)
            {
                local_H[A[i]]++;
            }

// Região crítica apenas para somar o resultado local no global
#pragma omp critical
            {
                for (int j = 0; j < B; j++)
                {
                    H[j] += local_H[j];
                }
            }
        }
    }

    end_time = omp_get_wtime();

    // Verificação de sanidade (Total deve ser igual a N)
    long total_count = 0;
    for (int val : H)
        total_count += val;

    std::string var_name = (variant == 1 ? "critical" : (variant == 2 ? "atomic" : "local"));

    if (total_count != N)
    {
        std::cerr << "ERRO: Total contabilizado (" << total_count << ") != N (" << N << ")" << std::endl;
    }

    // Formtado da saída: Type, N, B, Variant, Threads, Time
    std::cout << "TASK_B,"
              << N << ","
              << B << ","
              << var_name << ","
              << omp_get_max_threads() << ","
              << (end_time - start_time) << std::endl;

    return 0;
}