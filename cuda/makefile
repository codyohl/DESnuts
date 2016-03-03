CC=gcc
CFLAGS=-I. -Wall -g -O2 -std=c99

EXEC=des_c_version

$(EXEC): des.o main.o
	$(CC) $(CGLAGS) -o $(EXEC) des.o main.o

des.o:
	$(CC) $(CFLAGS) -c des.h des.c

main.o:
	$(CC) $(CFLAGS) -c main.c

clean:
	rm des_c_version des.o main.o
