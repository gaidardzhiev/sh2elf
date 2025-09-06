CC=musl-gcc
FLAGS=-O2 -Wall -Wextra -no-pie -static
BIN=sh2elf

all: $(BIN)

$(BIN): sh2elf.c
	$(CC) $(FLAGS) -o $@ $<

clean:
	rm -f $(BIN)
