#!/bin/sh
/usr/bin/nproc > /tmp/sh2elf_np
nproc | cmp -s - /tmp/sh2elf_np && echo "nproc-ok"
/usr/bin/nproc --all > /tmp/sh2elf_np
nproc -a | cmp -s - /tmp/sh2elf_np && echo "all-ok"
nproc --all 2>/dev/null || echo "long-opt-rc=$?"
rm -f /tmp/sh2elf_np
