#!/bin/sh
D=/tmp/sh2elf_cmp
mkdir -p $D
printf 'hello\nworld\n' > $D/a
printf 'hello\nwOrLd\nxyz\n' > $D/b
printf 'hello\n' > $D/c
printf '' > $D/e
cd $D
cmp a b
echo "rc=$?"
cmp -l a b 2>&1
echo "rc=$?"
cmp -s a c
echo "rc=$?"
cmp a c 2>&1
cmp e a 2>&1
cmp -s a b
echo "rc=$?"
cmp a a
echo "rc=$?"
cmp -l a c 2>&1
echo "rc=$?"
cmp -ls a b 2>&1
echo "rc=$?"
cmp a b c 2>&1
echo "rc=$?"
cat a | cmp - b
cmp a missing 2>&1
echo "rc=$?"
cd /tmp
/bin/rm -rf $D
