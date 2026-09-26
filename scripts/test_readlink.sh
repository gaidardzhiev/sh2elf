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
readlink l1 l2
readlink f
echo "plain-rc=$?"
readlink -f l2
readlink -e l2 dang
echo "e-rc=$?"
readlink -f dang
readlink -f d/../f
readlink -f nothere
readlink -m a/b/c
readlink -m ../x/./y/../z
readlink -n l1
echo "|"
readlink -v f 2>&1
readlink -z l1 | od -c
readlink -f nothere/x
echo "f-rc=$?"
readlink -f ///usr/./bin/..
cd /tmp
/bin/rm -rf $D
