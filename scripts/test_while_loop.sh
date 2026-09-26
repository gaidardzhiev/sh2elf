#!/bin/sh
I=0
while [ $I -lt 4 ]; do
	echo "while $I"
	I=$(( I + 1 ))
done
J=3
until [ $J -eq 0 ]; do
	echo "until $J"
	J=$(( J - 1 ))
done
K=1
while (( K <= 16 )); do
	echo "pow $K"
	(( K *= 2 ))
done
S=""
while [ "$S" != "xxx" ]; do
	S="${S}x"
	echo "$S"
done
for o in a b; do
	n=0
	while [ $n -lt 2 ]; do
		echo "$o$n"
		n=$(( n + 1 ))
	done
done
