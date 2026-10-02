#!/bin/sh
D=/tmp/sh2elf_uniq
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'a
a
b
c
c
c
d
a
' > f
uniq f
uniq -c f
uniq -d f
uniq -u f
printf 'x 1 a\ny 2 a\nz 2 b\n' | uniq -f1
printf 'xa\nya\nzb\n' | uniq -s1
uniq f out.txt
cat out.txt
printf 'a\na' | uniq
uniq -c -d f 2>&1
echo rc=$?
uniq -cu f 2>&1
echo rc=$?
uniq -D f 2>&1
echo rc=$?
uniq nosuch 2>&1
echo rc=$?
uniq a b c 2>&1
echo rc=$?
seq 100000 | uniq -c | tail -n 1
printf 'x\302\240a\ny\302\240a\n' | uniq -f1
printf 'x\ta\ny a\n' | uniq -f1
/usr/bin/printf '\xffa\n\xfea\n' | uniq -s1 | od -c
uniq -s x f 2>&1
uniq -f -1 f 2>&1
printf 'a  b\nc  b\n' | uniq -f 1
printf 'abc\nabd\n' | uniq -s 99
printf 'x y\n' | uniq -f 5 -c
printf 'a\n\n\nb\n' | uniq -c
printf '' | uniq -c
for o in -i -z '-w 3' --count --group -2; do
	uniq $o f 2>&1
	echo "rc=$?"
done
printf 'aa\nba\n' | uniq -s 1 -c
printf 'a b\na c\n' | uniq -f 1 -s 1
uniq f +1
cat +1
uniq nosuch out2 2>&1
echo rc=$?
ls out2 2>&1
U=uniq
$U -c f
F=-f1
printf 'x 1\ny 1\n' | $U $F -c
uniq -s 1k f 2>&1
echo rc=$?
cd /tmp
/bin/rm -rf $D
