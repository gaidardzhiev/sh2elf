#!/bin/sh
F=/tmp/sh2elf_tac.txt
printf 'first\nsecond\nthird\n' > $F
tac $F
printf 'x\ny\nz' | tac
echo
tac <<< "a:b:c"
printf '\n\nx\n' | tac | od -c
tac -s : $F 2>&1
echo "rc=$?"
tac $F $F
tac /tmp/sh2elf_tac_missing 2>/dev/null || echo "missing-status $?"
rm -f $F
