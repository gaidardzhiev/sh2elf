#!/bin/sh
N=5
(( N > 3 )) && echo "gt"
(( N < 3 )) || echo "not-lt"
(( N += 10 ))
echo $N
(( M = N * 2 ))
echo $M
for (( i = 0; i < 4; i++ )); do
	echo "iter $i"
done
for ((j=10; j>0; j-=3)); do echo "down $j"; done
