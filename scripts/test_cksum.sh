#!/bin/sh
F=/tmp/sh2elf_cksum.txt
printf 'The quick brown fox jumps over the lazy dog\n' > $F
cksum $F
cksum < $F
printf '' | cksum
cksum -a crc32b $F
cksum -a sysv $F
cksum -a bsd $F
cksum --algorithm=bsd < $F
echo "abc" | cksum -a sysv
cksum /tmp/sh2elf_cksum_missing 2>/dev/null
echo "rc=$?"
rm -f $F
