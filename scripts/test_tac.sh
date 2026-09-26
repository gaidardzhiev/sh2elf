#!/bin/sh
F=/tmp/sh2elf_tac.txt
printf 'first\nsecond\nthird\n' > $F
tac $F
printf 'x\ny\nz' | tac
echo
tac -s : <<< "a:b:c"
tac -b -s : <<< "a:b:c"
tac --separator=ab <<< "1ab2ab3ab"
tac $F $F
tac /tmp/sh2elf_tac_missing 2>/dev/null || echo "missing-status $?"
rm -f $F
