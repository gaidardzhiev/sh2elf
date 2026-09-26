#!/bin/sh
F=/tmp/sh2elf_tf.txt
printf 'one\ntwo\n' > $F
/bin/sh -c "sleep 0.3; echo three >> $F; sleep 0.3; echo four >> $F; sleep 0.3" &
tail -f -s 0.1 --pid=$! -n 1 $F
echo "follow-done rc=$?"
printf 'aaaa\nbbbb\n' > $F
/bin/sh -c "sleep 0.3; printf 'x\n' > $F; sleep 0.4" &
tail -f -s 0.1 --pid=$! $F 2>&1
printf 'old\n' > $F
/bin/sh -c "sleep 0.3; printf 'new1\n' > $F.n; mv $F.n $F; sleep 0.3; echo new2 >> $F; sleep 0.4" &
tail -F -s 0.1 --pid=$! $F 2>&1
printf 'p\n' > $F.b
/bin/sh -c "sleep 0.3; echo q >> $F.b; sleep 0.3; echo r >> $F; sleep 0.3" &
tail -f -s 0.1 --pid=$! -n 1 $F $F.b
echo piped | tail -f
echo "pipe-follow rc=$?"
rm -f $F $F.b
