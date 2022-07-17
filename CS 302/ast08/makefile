OBJS = main.o 
	CC  = g++ -Wall -pedantic -Wextra -std=c++11 -g
DEPS1 = priorityQ.h

all: main

main: $(OBJS)
		$(CC) -o main $(OBJS)

main.o: main.cpp $(DEPS1) 
		$(CC) -c main.cpp

clean:
		rm  $(OBJS)