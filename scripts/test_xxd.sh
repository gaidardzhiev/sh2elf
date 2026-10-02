#!/bin/sh
F=/tmp/sh2elf_xxd.bin
printf 'hello\nworld, this is xxd test\001\377' > $F
xxd $F
xxd -g1 -c8 $F
xxd -g4 $F
xxd -p $F
xxd -p -c 4 $F
xxd -s 3 -l 10 $F
xxd -o 16 -l 4 $F
xxd -e $F
printf 'abcdefg' | xxd -e
xxd -i $F
xxd -i -c 4 < $F
xxd -c 4 -l 9 $F
xxd -u $F 2>&1
echo "rc=$?"
xxd -p $F | xxd -r -p | xxd -g 0
xxd $F | xxd -r | xxd -p
rm -f $F
