#!/bin/sh
D=/tmp/sh2elf_rl
/bin/rm -rf $D
mkdir -p $D
cd $D
echo x > f
ln -s f l1
ln -s l1 l2
ln -s nowhere dang
mkdir d
readlink l1
readlink l2
readlink dang
readlink f 2>&1
echo "plain-rc=$?"
readlink nothere 2>&1
echo "missing-rc=$?"
readlink -f l2 2>&1
echo "f-rc=$?"
readlink -n l1
echo "|"
readlink -n l1 | od -c
readlink l1 l2 2>&1
echo "two-rc=$?"
cd /tmp
/bin/rm -rf $D
