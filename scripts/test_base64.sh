#!/bin/sh
F=/tmp/sh2elf_b64.txt
printf 'The quick brown fox jumps over the lazy dog. 0123456789 !@#$%%^&*()' > $F
base64 $F
base64 -w 0 $F
echo
base64 --wrap=16 $F
printf 'hello world' | base64
printf 'a' | base64
base64 $F | base64 -d
echo
echo YQ | base64 -d
echo
echo 'aGVs#bG8=' | base64 -d 2>/dev/null
echo " rc=$?"
echo 'aGVs#bG8=' | base64 -di
echo
echo 'aGVsbG8=aGk=' | base64 --decode
echo
echo 'aGVsbG8===' | base64 -d 2>/dev/null
echo " rc=$?"
rm -f $F
