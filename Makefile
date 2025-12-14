CXX = g++
CXXFLAGS = -O3 -fopenmp -Wall
TARGETS = taskA taskB

all: $(TARGETS)

taskA: src/tarefaA.cpp
	$(CXX) $(CXXFLAGS) -o taskA src/tarefaA.cpp

taskB: src/tarefaB.cpp
	$(CXX) $(CXXFLAGS) -o taskB src/tarefaB.cpp

clean:
	rm -f taskA taskB *.o