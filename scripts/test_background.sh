#!/bin/sh
sleep 1 &
echo "started"
wait
echo "waited"
/bin/sh -c 'exit 3' &
P=$!
wait $P
echo "bg status $?"
( echo "bg-sub" ) &
wait
echo "end"
