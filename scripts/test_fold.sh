#!/bin/sh
F=/tmp/sh2elf_fold.txt
printf 'a\tbcdefghij\nab cd ef gh ij kl\nthe quick brown fox jumps over the lazy dog\n日本語日本\näääääää\nlongwordwithoutspaces here\n' > $F
fold -w 5 $F
fold -s -w 10 $F
fold -b -w 4 $F
fold -bs -w 6 $F
fold -8 $F
fold --width=12 --spaces $F
printf 'no newline at end' | fold -w 7
echo
rm -f $F
