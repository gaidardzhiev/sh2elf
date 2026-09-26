#!/bin/sh
D=/tmp/sh2elf_head
/bin/rm -rf $D
mkdir -p $D
cd $D
seq 20 > h1
printf 'a\nb\nc' > h2
head h1
head -n 3 h1 h2
head -c 5 h2
echo
head -n -17 h1
head -c -3 h2
echo
head -3 h1
head -q -n1 h1 h2
head -v -n1 h1
head -n1 nosuch h1 2>&1
echo "missing-rc=$?"
head -n abc h1 2>&1
echo "invalid-rc=$?"
seq 3 | head -n 1 - h2
head -c 1k h1 | cksum
head --lines=2 --quiet h1
head -n +2 h1
head -n -1 h2
head -n -100 h1
head -n 0 h1
/usr/bin/printf 'x\0y\0z\0' | head -z -n 2 | od -c
seq 100000 | head -n 99999 | cksum
seq 100000 | head -n -99990
seq 100000 | head -c 50000 | cksum
head -n 3 < h1
cd /tmp
/bin/rm -rf $D
