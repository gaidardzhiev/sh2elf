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
cmp -b a b
cmp -l a b 2>&1
echo "rc=$?"
cmp -lb a b 2>&1
cmp a c 2>&1
cmp e a 2>&1
cmp -s a b
echo "rc=$?"
cmp a a
echo "rc=$?"
cmp -n 7 a b
echo "rc=$?"
cmp -i 2:3 a b
cmp a b 7 7
cmp --print-bytes --ignore-initial=1 a b
cat a | cmp - b
cmp a missing 2>&1
echo "rc=$?"
cd /tmp
/bin/rm -rf $D
