# Simple Makefile for building a NASM + GCC program

ASM = nasm
CC  = gcc
SRC = countdown.asm
OBJ = countdown.o
OUT = countdown

all: $(OUT)

$(OUT): $(OBJ)
	$(CC) $(OBJ) -o $(OUT)

$(OBJ): $(SRC)
	$(ASM) -f elf64 $(SRC) -o $(OBJ)

run: $(OUT)
	./$(OUT)

clean:
	rm -f $(OBJ) $(OUT)

.PHONY: all clean
