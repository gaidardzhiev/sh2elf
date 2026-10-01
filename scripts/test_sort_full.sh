#!/bin/sh
D=/tmp/sh2elf_sort
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'banana\nApple\napple\ncherry\n10\n9\n-3\neclair\n  zed\nb a\n10:30\n1:05\n0:a\n0 :a\n' > f
printf '3 Mar x\n1 jan y\n2 FEB z\n10 dec w\n2 feb a\n' > m
printf 'x:3:b\ny:1:a\nz:2:c\nw:1:d\n' > c
printf 'a\nb\nb\nc\n' > s1
printf 'a\nc\nd\n' > s2
sort f
sort -r f
sort -u f
sort -f f
sort -n f
sort -b f
sort -d f
sort -t: -k2,2n -k3r c
sort -t: -k2,2 -u c
sort -n -k1.2 m
sort -m s1 s2
sort -mu s1 s2
sort -r s1 s2
sort s1 -r 2>&1
echo rc=$?
sort -c s1
echo rc=$?
sort -c f 2>&1
echo rc=$?
sort -C f
echo rc=$?
sort -o out f
cat out
/usr/bin/printf 'x\0b\na\0c\nx\0a\n' | sort | od -c
printf 'b\na' | sort
sort -k0 f 2>&1
echo rc=$?
sort -k1x f 2>&1
sort -k1.0 f 2>&1
sort -tab f 2>&1
sort -t: -t, f 2>&1
sort -c s1 s2 2>&1
sort nosuch 2>&1
echo rc=$?
for o in -g -h -M -V -R -s -z '-S 1M' --check=quiet --sort=numeric '+1'; do
	sort $o f 2>&1
	echo "rc=$?"
done
sort -dn f 2>&1
echo rc=$?
sort -k2,2 -k1,1nr m
sort -C s2
echo rc=$?
LC_ALL=C sort f
LANG=C.UTF-8 sort -f f
S=sort
$S -t: -k2,2n -k3r c
K=-k1,1nr
$S $K m
$S -c f 2>&1
echo rc=$?
