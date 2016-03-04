CC=gcc
CFLAGS=-I. -Wall -g -O2 -std=c99

DES_SOURCE=des.h des.c
MAIN_SOURCE=main.c

NVCC=nvcc
NVCCFLAGS=-g

EXEC=des_c
OBJ=des.o main.o
HEADER=des.h.gch

CUDA_EXEC=des_cuda
CUDA_SOURCE=des_cuda.cu

all: $(CUDA_EXEC) $(EXEC)
	
$(CUDA_EXEC):
	$(NVCC) $(NVCCFLAGS) $(CUDA_SOURCE) -o $(CUDA_EXEC)

$(EXEC): $(OBJ)
	$(CC) $(CGLAGS) -o $(EXEC) $(OBJ)

des.o:
	$(CC) $(CFLAGS) -c $(DES_SOURCE)

main.o:
	$(CC) $(CFLAGS) -c $(MAIN_SOURCE)

clean:
	rm $(EXEC) $(OBJ) $(CUDA_EXEC) $(HEADER)
