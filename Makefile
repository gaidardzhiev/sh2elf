CC=gcc
CFLAGS=-O2 -Wall -Wextra -std=c11
LDFLAGS=-no-pie
BIN=sh2elf

all: $(BIN) sh2elf-lsp test_diff fuzz_sh

$(BIN): sh2elf.c
	$(CC) $(CFLAGS) -o $@ $< $(LDFLAGS)

sh2elf-lsp: sh2elf-lsp.c
	$(CC) $(CFLAGS) -o $@ $<

test_diff: test_diff.c
	$(CC) $(CFLAGS) -o $@ $<

fuzz_sh: fuzz_sh.c
	$(CC) $(CFLAGS) -o $@ $<

test: all
	./verify.sh
	./test_diff
	./fuzz_sh 100

fuzz: all
	./fuzz_sh 500

strip:
	strip -S \
		--strip-unneeded \
		--remove-section=.note.gnu.gold-version \
		--remove-section=.comment \
		--remove-section=.note \
		--remove-section=.note.gnu.build-id \
		--remove-section=.note.ABI-tag $(BIN)

install:
	cp $(BIN) /usr/bin/$(BIN)
	cp $(BIN).1 /usr/share/man/man1/

clean:
	rm -f $(BIN) sh2elf-lsp test_diff fuzz_sh *.elf *.o
