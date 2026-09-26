#!/bin/sh
F=/tmp/sh2elf_nl.txt
printf 'alpha\n\nbeta\n\n\ngamma\n' > $F
nl $F
nl -ba $F
nl -ba -l2 $F
nl -ba -nln -w3 -s'| ' $F
nl -ba -nrz -v-2 -i3 -w4 $F
nl -bn $F
printf 'intro\n\\:\\:\\:\nhead\n\\:\\:\nbody1\nbody2\n\\:\nfoot\n' > $F.d
nl -ha -fa $F.d
nl -p $F.d
nl --body-numbering=a --number-width=2 --number-separator=: $F $F.d
echo "piped line" | nl
rm -f $F
rm -f $F.d
