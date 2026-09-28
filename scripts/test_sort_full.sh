#!/bin/sh
D=/tmp/sh2elf_sort
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'banana\nApple\napple\ncherry\n10\n9\n-3\neclair\n  zed\nb a\n10:30\n1:05\n0:a\n0 :a\n' > f
printf '3 Mar x\n1 jan y\n2 FEB z\n10 dec w\n2 feb a\n' > m
printf '1.5K\n2M\n-1K\n300\n1G\n0\n' > h
printf 'v1.10\nv1.9\nv1.9a\nfile-1.2.tar.gz\nfile-1.10.tar.gz\n.a\n' > v
printf 'x:3:b\ny:1:a\nz:2:c\nw:1:d\n' > c
printf ',5M\n0,5M\n5,M\n0001M\n5,,5M\n1,0001M\n.5M\n-,5M\n0M\n3K\n-5K\n1,5.5M\n2\n' > hu
printf 'nan\n1e3\n-inf\n0x10\nfoo\n-nan\n2.5\ninf\n' > g
printf 'a\nb\nb\nc\n' > s1
printf 'a\nc\nd\n' > s2
sort f
sort -r f
sort -u f
sort -f f
sort -n f
sort -b f
sort -d f
sort -k2M m
sort -k2,2M -k1,1nr m
sort -h h
sort -rh h
sort -h hu
printf '1e3\n2E1\n5k\n3K\n1M\n' | sort -fh
sort -V v
sort -g g
sort -t: -k2,2n -k3r c
sort -t: -k2,2 -s c
sort -t: -k2,2 -u c
sort -n -k1.2 m
sort +1 -2 m
sort -m s1 s2
sort -mu s1 s2
sort s1 s2 -r
sort -c s1
echo rc=$?
sort -c f 2>&1
echo rc=$?
sort -C f
echo rc=$?
sort --check=quiet s2
echo rc=$?
sort -o out f
cat out
/usr/bin/printf 'b\0a\0c\0' | sort -z | od -c
/usr/bin/printf 'x\0b\na\0c\nx\0a\n' | sort | od -c
printf 'b\na' | sort
sort -R f | sort -R | sort
sort --sort=numeric -r c
sort -k0 f 2>&1
echo rc=$?
sort -k1x f 2>&1
sort -k1.0 f 2>&1
sort -gn f 2>&1
sort -tab f 2>&1
sort -t: -t, f 2>&1
sort -c s1 s2 2>&1
sort nosuch 2>&1
echo rc=$?
sort --sort=foo f 2>&1
echo rc=$?
