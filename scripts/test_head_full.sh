#!/bin/sh
D=/tmp/sh2elf_head
/bin/rm -rf $D
mkdir -p $D
cd $D
seq 20 > h1
printf 'a\nb\nc' > h2
mkdir dir
head h1
head -n 3 h1 h2
head -c 5 h2
echo
head -n3 h1
head -c5 h2
echo
head -n 2 -n 1 h1
head -- h2
echo
head -n 1 -- h1 h2
head -n 0 h1
head -n 100 h2
echo
head -n 99999999999999999999 h2
echo
head -n1 nosuch h1 2>&1
echo "missing-rc=$?"
head dir h2 2>&1
echo "dir-rc=$?"
seq 3 | head -n 1 - h2
echo
head -c 1024 h1 | cksum
head -n 3 < h1
seq 10 > h3
head -n 2 < h3
head -c 3 < h3; echo
seq 100000 | head -n 99999 | cksum
seq 100000 | head -c 50000 | cksum
head h1 -n 2 2>&1
echo "perm-rc=$?"
for o in -q -v -z -3 --lines=2 --help; do
	head $o h1 2>&1
	echo "rc=$?"
done
head -n 2>&1
echo "rc=$?"
for n in -3 +2 1k abc '' ' 2' 0x10; do
	head -n "$n" h1 2>&1
	echo "rc=$?"
done
head -c -3 h2 2>&1
echo "rc=$?"
head -c 1k h2 2>&1
echo "rc=$?"
head -c 5 -n 2 h1 2>&1
echo "rc=$?"
cd /tmp
/bin/rm -rf $D
