#!/bin/sh
F=/tmp/sh2elf_big.txt
seq 11000000 > $F
cksum $F
cksum -a crc32b < $F
tac $F | cksum
rev $F | cksum
nl $F | cksum
fold -w 5 $F | cksum
head -n -3 $F | cksum
base64 $F | base64 -d | cmp - $F && echo "roundtrip-ok"
rm -f $F
