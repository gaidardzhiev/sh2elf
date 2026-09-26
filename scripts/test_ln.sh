#!/bin/sh
D=/tmp/sh2elf_ln
/bin/rm -rf $D
mkdir -p $D
cd $D
echo x > f
mkdir d
mkdir e
ln -s f l1
readlink l1
ln -s f l1 2>&1
echo "exists-rc=$?"
ln -sf f l1 && echo "forced"
ln f h1 && stat -c %h f
ln -v f h2
ln -sv f d
/bin/ls d
ln nosuch x 2>&1
echo "missing-rc=$?"
ln -sT f d 2>&1
ln -s f l1 h1 e
/bin/ls e
ln -t e -sv h2
readlink e/h2
cd /tmp
/bin/rm -rf $D
