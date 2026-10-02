#!/bin/sh
F=/tmp/sh2elf_cksum.txt
printf 'The quick brown fox jumps over the lazy dog\n' > $F
cksum $F
cksum < $F
printf '' | cksum
echo "abc" | cksum
cksum $F - < $F
cksum -a crc $F 2>&1
echo "rc=$?"
cksum /tmp/sh2elf_cksum_missing 2>/dev/null
echo "rc=$?"
rm -f $F
