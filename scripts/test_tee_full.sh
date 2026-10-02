#!/bin/sh
D=/tmp/sh2elf_teef
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'one\ntwo\n' | tee a b
cat a b
printf 'three\n' | tee -a a
cat a
printf 'x\n' | tee -- -
cat ./-
printf 'x\n' | tee nodir/f a 2>&1
echo "rc=$?"
cat a
mkdir dd
printf 'x\n' | tee dd 2>&1
echo "rc=$?"
printf 'x\n' | tee a > /dev/full 2>&1
echo "rc=$?"
printf 'x\n' | tee /dev/full b 2>&1
echo "rc=$?"
cat b
tee c < dd 2>&1
echo "rc=$?"
printf '' | tee e
echo "rc=$?"
wc -c < e
seq 100000 | tee s1 s2 | cksum
cksum < s1
(printf 'x\n'; /usr/bin/sleep 0.4; printf 'y\n') | tee -i i1 & p=$!
/usr/bin/sleep 0.2
kill -INT $p
wait $p
echo "int-rc=$?"
cat i1
for o in -p -x --append --help --output-error=warn; do
	printf 'x\n' | tee $o f 2>&1
	echo "rc=$?"
done
printf 'x\n' | tee f -a
cat ./-a
read -r T <<X
tee
X
printf 'rt\n' | $T -a g
cat g
cd /tmp
/bin/rm -rf $D
