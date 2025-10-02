CC=gcc
CFLAGS=-O2 -Wall -Wextra -std=c11
LDFLAGS=-no-pie
BIN=sh2elf

all: $(BIN)

$(BIN): sh2elf.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f $(BIN)
