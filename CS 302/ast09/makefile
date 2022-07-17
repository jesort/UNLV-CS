OBJS = main.o 
	CC  = g++ -Wall -pedantic -Wextra -std=c++11 -g

all: main

main: $(OBJS)
		$(CC) -o main $(OBJS)

main.o: main.cpp
		$(CC) -c main.cpp

clean:
		rm  $(OBJS)