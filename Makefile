CC=gcc
CFLAGS=-O2 -Wall -Wextra -std=c11
LDFLAGS=-no-pie
BIN=sh2elf

all: $(BIN)

$(BIN): sh2elf.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -f $(BIN)

strip:
	strip -S --strip-unneeded --remove-section=.note.gnu.gold-version --remove-section=.comment --remove-section=.note --remove-section=.note.gnu.build-id --remove-section=.note.ABI-tag $(BIN)

install:
	cp $(BIN) /usr/bin/$(BIN)
	cp $(BIN).1 /usr/share/man/man1/
