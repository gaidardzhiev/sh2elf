#!/bin/sh
D=/tmp/sh2elf_cut
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'a:b:c:d
1:2:3
nodelim
:x:
' > f
cut -d: -f2 f
cut -d: -f1,3 f
cut -d: -f2- f
cut -d: -f-2 f
cut -d: -f2 -s f
cut -d: -f1,3 --output-delimiter=-- f
cut -d: --complement -f2 f
cut -b2-4 f
cut -b 3,1 f
cut -b1-2,2-3 f
cut -f2 f
printf 'a\tb\tc\n' | cut -f2
cut -d: -f3-,1 f
cut -b5- f
cut -b -2 f
cut -c2 --complement f
echo rc=$?
cut -f0 f 2>&1
cut -d:: -f1 f 2>&1
cut -b3-1 f 2>&1
cut -f1 -b1 f 2>&1
/usr/bin/printf 'a:b\0c:d\0' | cut -z -d: -f2 | od -c
printf 'a:b' | cut -d: -f2
echo rc=$?
cut -d '' -f1 f
cut -s -f1 f
cut -d: -f 1,2 f -s
echo abcdefgh | cut -b1-2,4-5,7 --output-delimiter=:
echo abcdefgh | cut -b1-2,3-4 --output-delimiter=:
echo abcdefgh | cut --complement -b2-3 --output-delimiter=:
echo 'a b c' | cut -d' ' -f '1 3'
echo 'abcdef' | cut -b '1 3'
echo abcdef:gh:ij | cut -b 1-2,3-4,6- --output-delimiter=+
echo abcdef:gh:ij | cut -f 2,1 -d:
echo abcdef:gh:ij | cut -b 99999999999999999999 2>&1
echo abcdef:gh:ij | cut -b 1-3 --complement --output-delimiter=+
echo a | cut -f 99999999999999999999 2>&1
echo a | cut -f1 -f2 2>&1
printf "a\tb\n" | cut -f1,2 --output-delimiter= | od -c
echo a | cut -z -f1 | od -c
echo abc | cut -b3,1 --complement
echo 'x:y:z' | cut -d: -f5
echo 'x:y:z' | cut -d: -f3-7
echo 'x:y:z' | cut -d: -f2 --complement -s
cut -b 1 -d: f 2>&1
cut -b 1 -s f 2>&1
echo 'a,b' | cut -f 1,,3 2>&1
echo 'abc' | cut -b x 2>&1
echo 'abc' | cut -f 1-x 2>&1
echo 'abc' | cut -f - 2>&1
cut -d: -f1 nosuch f 2>&1
echo "missing-rc=$?"
seq 100000 | cut -b2- | cksum
seq 100000 | /usr/bin/awk '{print $1":a:"$1*2":b"}' | cut -d: -f1,3 | cksum
cd /tmp
/bin/rm -rf $D
