#!/bin/sh
F=/tmp/sh2elf_tf.txt
printf 'one\ntwo\n' > $F
tail -f -n 1 $F &
p=$!
sleep 0.3
echo three >> $F
sleep 0.3
echo four >> $F
sleep 0.3
kill $p
wait $p
echo "follow-done rc=$?"
printf 'aaaa\nbbbb\n' > $F
tail -f -c 3 $F &
p=$!
sleep 0.3
printf 'x\n' > $F
sleep 0.4
kill $p
wait $p
printf 'p\n' > $F
tail -f -n +1 $F &
p=$!
sleep 0.3
echo q >> $F
sleep 0.3
kill $p
wait $p
echo piped | tail -f
echo "pipe-follow rc=$?"
rm -f $F
