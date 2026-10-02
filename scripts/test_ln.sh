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
ln f h2
ln -s f d
/bin/ls d
ln nosuch x 2>&1
echo "missing-rc=$?"
ln -s f l1 h1 e
/bin/ls e
ln -s h2 e
readlink e/h2
ln -f f f 2>&1
echo "same-rc=$?"
ln -f f h1
stat -c %h f
ln f h1 nodir 2>&1
echo "target-rc=$?"
ln -sf f e/l1 2>&1
mkdir e/dir
ln -f f e/dir 2>&1
ln -s f e/dir 2>&1
ln -sf f e/sub 2>&1
mkdir g; ln -sf f g/dd; mkdir g/x; ln -f f g/x/.. 2>&1
echo "dir-rc=$?"
ln -L l1 hl
stat -c %h f
ln -P l1 hp
stat -c %h hp
ln d dd 2>&1
echo "dirlink-rc=$?"
for o in -v -n -i -b -r -T '-t e' --symbolic --help; do
	ln $o f zz </dev/null 2>&1
	echo "rc=$?"
done
ln 2>&1
echo "rc=$?"
ln f 2>&1
echo "rc=$?"
read -r L <<X
ln
X
$L -s f lr
readlink lr
N=nosuch
$L "$N" y 2>&1
echo "rc=$?"
cd /tmp
/bin/rm -rf $D
