#!/bin/sh
/usr/bin/nproc > /tmp/sh2elf_np
nproc | cmp -s - /tmp/sh2elf_np && echo "nproc-ok"
/usr/bin/nproc --all > /tmp/sh2elf_np
nproc --all | cmp -s - /tmp/sh2elf_np && echo "all-ok"
nproc --ignore=100000
nproc --ignore 100000
rm -f /tmp/sh2elf_np
