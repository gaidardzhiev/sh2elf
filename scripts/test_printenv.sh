#!/bin/sh
echo "$HOME" > /tmp/sh2elf_pe
printenv HOME | cmp -s - /tmp/sh2elf_pe && echo "home-ok"
echo "$PATH" > /tmp/sh2elf_pe
printenv -0 PATH | /usr/bin/tr '\0' '\n' | cmp -s - /tmp/sh2elf_pe && echo "null-ok"
printenv HOME SH2ELF_SURELY_UNSET_VAR > /dev/null
echo "missing-rc=$?"
printenv | /usr/bin/grep -c '^PATH='
rm -f /tmp/sh2elf_pe
