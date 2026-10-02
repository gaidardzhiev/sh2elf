sleep 1 && echo sleep-done
sleep 0 && echo zero-done
sleep -- 0 && echo dashdash-done
sleep 0.5 2>&1
echo "frac-rc=$?"
sleep 1m 2>&1
echo "suffix-rc=$?"
sleep 1 2 2>&1
echo "extra-rc=$?"
sleep 2>&1
echo "missing-rc=$?"
sleep 5 & p=$!
kill $p
wait $p
echo "killed=$?"
(trap 'echo trapped' USR1; sleep 5; echo "after=$?") & p=$!
/usr/bin/sleep 0.3
kill -USR1 $p
wait $p
echo "sub=$?"
