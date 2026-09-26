#!/bin/sh
D=/tmp/sh2elf_tr
/bin/rm -rf $D
mkdir -p $D
cd $D
truncate -s 100 t1
stat -c %s t1
truncate -s +50 t1
stat -c %s t1
truncate -s -30 t1
stat -c %s t1
truncate -s '<50' t1
stat -c %s t1
truncate -s '>70' t1
stat -c %s t1
truncate -s /16 t1
stat -c %s t1
truncate -s %20 t1
stat -c %s t1
truncate -s 1K t1
stat -c %s t1
truncate -s 2KB t1
stat -c %s t1
truncate --size=1M t1
stat -c %s t1
truncate -c -s 10 nope
echo "nocreate-rc=$?"
/bin/ls
echo abc > f
truncate -r f t2
stat -c %s t2
truncate -r t1 -s +1 t2
stat -c %s t2
truncate -s -99999 t2
stat -c %s t2
truncate -s 5 nodir/x 2>&1
truncate -s 1.5K t3 2>&1
echo "invalid-rc=$?"
cd /tmp
/bin/rm -rf $D
