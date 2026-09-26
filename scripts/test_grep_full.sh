#!/bin/sh
D=/tmp/sh2elf_grep
/bin/rm -rf $D
mkdir -p $D
printf 'a fox\nerror\nerr\n' > $D/p
grep -f scripts/grep_pats.txt $D/p
cd $D
printf 'the quick brown fox\njumps over\nthe lazy dog\nERROR: disk\nerror: net\n\nfox and dog\n' > a
printf 'one\ntwo fox\nthree\n' > b
grep fox a
grep -n fox a b
grep -c o a b
grep -v o a
grep -i error a
grep -w dog a
grep -x 'jumps over' a
grep -o 'o[a-z]' a
grep -b fox a
grep -H -n -b the a
grep -h fox a b
grep -l fox a b
grep -L quick a b
grep -m1 the a
grep -A1 quick a
grep -B1 lazy a
grep -C1 -n ERROR a
grep -2 net a
grep --group-separator=XX -A0 fox a
grep --no-group-separator -A0 fox a
grep -e fox -e net a
grep -F 'err' a
grep -E 'fox|net' a
grep -T -n fox a b
grep -Z -l fox a b | od -c
grep --color=always -n fox a
grep --label=in -H fox < a
grep -q fox a; echo rc=$?
grep -q nothing a; echo rc=$?
grep fox nosuch a; echo rc=$?
grep -s fox nosuch; echo rc=$?
/usr/bin/printf 'a\0b\nab\n' > bin
grep ab bin; echo rc=$?
grep -c a bin
grep -a b bin | od -c
/usr/bin/printf 'x\0y\0x\0' | grep -z x | od -c
grep -ob 'o' b
grep -vc '' a
grep -m2 -c o a
grep -k x a; echo rc=$?
grep --line x a; echo rc=$?
grep -A x y a; echo rc=$?
