#!/bin/sh
D=/tmp/sh2elf_sortp
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'éb\nΩ\nÉa\na-b\nzeta\nßx\nΩa\nb\né\nÉ\n' > f
printf 'x→2→b\ny→1→a\nz→3→c\n' > t
printf 'aéb 2\nzΩa 1\nméa 3\n' > k
sort -d f
sort -f f
sort -fu f
sort -i f
sort -t→ -k2,2n t
sort -t→ -k3r t
sort -k1.2,1.2 k
sort -k1.3 k
