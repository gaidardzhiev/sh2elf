#!/bin/sh
hostname | cmp -s - /proc/sys/kernel/hostname && echo "hostname-ok"
/usr/bin/hostname -s > /tmp/sh2elf_hn
hostname -s | cmp -s - /tmp/sh2elf_hn && echo "short-ok"
hostname --short 2>/dev/null || echo "long-opt-rc=$?"
rm -f /tmp/sh2elf_hn
hostname sh2elf-test-name 2>/dev/null
echo "set-rc=$?"
