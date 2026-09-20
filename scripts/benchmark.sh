#!/bin/sh
set -e
echo "Creating 50MB test dataset..."
dd if=/dev/urandom of=/tmp/sh2elf_bench.dat bs=1M count=50 2>/dev/null
echo "Compiling test binary with sh2elf..."
./sh2elf scripts/bench_cat.sh -o bench_cat.elf >/dev/null
echo "Benchmarking streaming throughput (50MB)..."
/usr/bin/time -p ./bench_cat.elf > /dev/null
rm -f /tmp/sh2elf_bench.dat bench_cat.elf
