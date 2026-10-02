#!/bin/sh
D=/tmp/sh2elf_cat
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'one\ntwo\n' > a
printf 'three\n' > b
printf 'no newline' > c
: > e
mkdir dd
cat a
cat a b c
echo
cat e a e
cat -u b
cat -- a
printf 'in\n' | cat
printf 'in\n' | cat a - b
printf 'in\n' | cat - -
cat < b
cat nosuch a 2>&1
echo "rc=$?"
cat dd 2>&1
echo "rc=$?"
cat a >> a 2>&1
echo "rc=$?"
cat a
cat a b > f
cat f a >> f 2>&1
cat f
cat a > /dev/full 2>&1
echo "rc=$?"
for o in -n -b -s -v -A -e -t -E -T --number --help --version; do
	cat $o a 2>&1
	echo "rc=$?"
done
cat a -n 2>&1
echo "rc=$?"
seq 100000 | cat | cksum
seq 100000 > s
cat s s | cksum
read -r C <<X
cat
X
$C a b
F=b
$C "$F" - < a
cd /tmp
/bin/rm -rf $D
