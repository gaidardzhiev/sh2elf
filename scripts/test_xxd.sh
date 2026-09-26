#!/bin/sh
F=/tmp/sh2elf_xxd.bin
printf 'hello\nworld, this is xxd test\001\377' > $F
xxd $F
xxd -g1 -c8 $F
xxd -g4 -u $F
xxd -p $F
xxd -p -c 4 $F
xxd -s 3 -l 10 $F
xxd -s -4 $F
xxd -o 16 -l 4 $F
xxd -e $F
printf 'abcdefg' | xxd -b
xxd -b -c 4 -l 8 $F
xxd -i $F
xxd -i -c 4 < $F
xxd -cols 4 -len 9 $F
xxd -p $F | xxd -r -p | xxd -g 0
xxd $F | xxd -r | xxd -p
rm -f $F
