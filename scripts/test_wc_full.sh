#!/bin/sh
D=/tmp/sh2elf_wc
/bin/rm -rf $D
mkdir -p $D
cd $D
seq 20 > h1
printf 'a b\nc' > h2
printf 'h\303\251llo w\303\266rld\n\346\227\245\346\234\254 x\n' > u
printf '' > e
mkdir dd
seq 100000 > big
wc h1
wc h1 h2
wc -l h1
wc -w h2
wc -c h1 h2
wc -m u
wc -L u h1
wc < h1
cat h1 | wc
cat h1 | wc -l
wc e
wc nosuch h1 2>&1
echo "missing-rc=$?"
wc -lwc h1
wc -cl h1
wc --total=never h1 h2
wc --total=only h1 h2
wc --total=always h1
wc big h1
wc dd 2>&1
echo "dir-rc=$?"
cat h1 | wc -lw
wc -l - < h1
cat h1 | wc -l - h2
/usr/bin/printf 'a\302\240b\342\200\203c\343\200\200d\342\200\257e\n' | wc -w
/usr/bin/printf 'ab\377c\303\n' | wc -mw
/usr/bin/printf 'a\tb\n12345678901\rxy\n\346\227\245\346\234\254\n\001abc\n' | wc -L
/usr/bin/printf 'ab\fcd\vxyz\n' | wc -L
/usr/bin/printf '\372\273\221\207\221 \364\220\200\200\n' | wc -mwL
/usr/bin/printf 'x\0y z' | wc -w
printf 'x y' | wc
wc -m -w -l -c -L u h1 h2 e
wc --bytes --lines --words --chars --max-line-length u
seq 1 200000 | wc -lwmcL
head -c 300000 big | wc
cd /tmp
/bin/rm -rf $D
