#!/bin/sh
D=/tmp/sh2elf_tail
/bin/rm -rf $D
mkdir -p $D
cd $D
seq 20 > h1
printf 'a\nb\nc' > h2
tail -n 3 h1 h2
echo "--"
tail -c 5 h1
tail -n +18 h1
tail -c +50 h1
tail -3 h1
tail +19 h1
tail -n 1 h2
echo
tail -q -n1 h1 h2
echo
tail -v -n1 h1
tail -n1 nosuch h1 2>&1
echo rc=$?
tail -n abc h1 2>&1
echo rc=$?
seq 30 | tail -n 2 - h2
echo
tail -c 1k h1 | cksum
tail -n +0 h1 | head -2
printf '' | tail
tail -5c h1
mkdir -p dd
tail dd 2>&1
echo rc=$?
tail h1
tail -n 0 h1
seq 100000 > h3
tail -n 99999 h3 | cksum
tail -n 1 h3
tail -c 100 h3 | cksum
tail -n +99990 h3
cat h3 | tail -n 3
cat h3 | tail -c 7
cat h3 | tail -n +99998
tail -n 50000 h3 | cksum
tail --lines=2 --quiet h1 h2
echo
tail -c +3 h2
echo
tail -n -2 h1
cd /tmp
/bin/rm -rf $D
