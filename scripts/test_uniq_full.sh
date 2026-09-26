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
uniq -D f
uniq --all-repeated=separate f
uniq --all-repeated=prepend f
uniq --group f
uniq --group=both f
uniq --group=prepend f
uniq --group=append f
printf 'x 1 a\ny 2 a\nz 2 b\n' | uniq -f1
printf 'xa\nya\nzb\n' | uniq -s1
printf 'A\na\nB\n' | uniq -i
printf 'abc1\nabc2\nabd\n' | uniq -w3
/usr/bin/printf 'a\0a\0b\0' | uniq -z | od -c
uniq f out.txt
cat out.txt
printf 'a\na' | uniq
uniq -c -d f
uniq -cu f
uniq --count --repeated f
uniq -dD f
uniq -c -D f 2>&1
echo rc=$?
uniq nosuch 2>&1
echo rc=$?
uniq a b c 2>&1
echo rc=$?
seq 100000 | uniq -c | tail -1
printf 'x\xc2\xa0a\ny\xc2\xa0a\n' | uniq -f1
printf 'x\ta\ny a\n' | uniq -f1
/usr/bin/printf '\xffa\n\xfea\n' | uniq -s1 | od -c
printf 'aé\naÉ\n' | uniq -i
uniq -c --group f 2>&1
uniq --all-repeated=foo f 2>&1
uniq --group=foo f 2>&1
uniq -s x f 2>&1
uniq -f -1 f 2>&1
printf 'a  b\nc  b\n' | uniq -f 1
printf 'abc\nabd\n' | uniq -s 99
printf 'x y\n' | uniq -f 5 -c
printf 'a\n\n\nb\n' | uniq -c
uniq -2 f
printf 'a x\nb x\nc y\n' | uniq -1
printf 'aa\nba\n' | uniq +1
printf '' | uniq -c
uniq -w0 f
uniq -ciu f
printf 'Ab\naB\nab\nAc\n' | uniq -ic
printf 'a\na\nb\nb\nb\nc\n' | uniq -D --all-repeated=separate
seq 5 | uniq -D
cd /tmp
/bin/rm -rf $D
