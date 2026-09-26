#!/bin/sh
printf 'hello\nworld\n' > /tmp/sh2elf_rev.txt
rev /tmp/sh2elf_rev.txt
echo "stressed desserts" | rev
echo "añb€" | rev
printf 'no-newline' > /tmp/sh2elf_rev2.txt
rev /tmp/sh2elf_rev2.txt /tmp/sh2elf_rev.txt
rev /tmp/sh2elf_rev_missing 2>/dev/null || echo "missing-status $?"
rm -f /tmp/sh2elf_rev.txt
rm -f /tmp/sh2elf_rev2.txt
