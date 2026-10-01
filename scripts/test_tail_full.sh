#!/bin/sh
D=/tmp/sh2elf_tail
/bin/rm -rf $D
mkdir -p $D
cd $D
seq 20 > h1
printf 'a\nb\nc' > h2
tail -n 3 h1
tail -c 5 h1
tail -n +18 h1
tail -c +50 h1
tail -n -3 h1
tail -n3 h1
tail -n 1 h2
echo
tail -n1 nosuch 2>&1
echo rc=$?
seq 30 | tail -n 2 -
seq 30 | tail -n 2
tail -c 1024 h1 | cksum
tail -n +0 h1 | head -n 2
printf '' | tail
tail -c5 h1
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
tail -c +3 h2
echo
tail -n -2 h1
tail -r h2
tail -r -n 3 h1
tail -rn 2 h3
tail -r h3 | cksum
seq 3 | tail -r
tail -- h2
echo
tail h1 h2 2>&1
echo rc=$?
for o in -q -v -z -F -3 --lines=2 --pid=1; do
	tail $o h1 2>&1
	echo rc=$?
done
tail -c 2 -n 2 h1 2>&1
echo rc=$?
tail -r -c 2 h1 2>&1
echo rc=$?
tail -r -f h1 2>&1
echo rc=$?
tail -r -n +2 h1 2>&1
echo rc=$?
for n in 1k abc '' x+2; do
	tail -n "$n" h1 2>&1
	echo rc=$?
done
N=4
tail -n "$N" h1
F=h2
tail -c 3 "$F"
echo
cd /tmp
/bin/rm -rf $D
