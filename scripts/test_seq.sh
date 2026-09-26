#!/bin/sh
seq 5
seq 3 7
seq 1 3 10
seq 10 -3 1
seq -w -3 3
seq -w 8 10
seq -s, 5
seq -s ', ' 1 3 10
seq --separator=- --equal-width 98 101
seq 5 1
seq 0
seq 1 0.5 3
seq -f '%03g' 3
seq 9223372036854775806 9223372036854775807
seq 18446744073709551614 18446744073709551615
seq 100000 | cksum
seq 1 0 5 2>/dev/null
echo "rc=$?"
