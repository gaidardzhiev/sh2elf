kill -0 0 && echo kill-passed
kill -l 15
kill -l 137
kill -l 34
kill -l | /usr/bin/wc -l
sleep 5 & kill $!; wait $!; echo "term=$?"
sleep 5 & kill -s int $!; wait $!; echo "int=$?"
sleep 5 & kill -KILL %1; wait $!; echo "job=$?"
sleep 5 & p1=$!; sleep 5 & p2=$!; kill -9 %-; wait $p1; echo "prev=$?"; kill %%; wait $p2; echo "cur=$?"
kill -s 0 $$; echo "zero=$?"
kill 999999 2>&1 | /usr/bin/sed 's/^.*kill: /kill: /'
kill -s SIGTERM 999999 2>&1 | /usr/bin/sed 's/^.*kill: /kill: /'
kill %7 2>&1 | /usr/bin/sed 's/^.*kill: /kill: /'
kill -l 99; echo "badnum=$?"
kill 2>/dev/null; echo "noarg=$?"
