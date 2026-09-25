#!/bin/sh
for i in 1 2 3 4; do
	if [ "$i" = "3" ]; then
		break
	fi
	echo "break_noarg_$i"
done

for j in 1 2 3 4; do
	if [ "$j" = "2" ]; then
		continue
	fi
	echo "continue_noarg_$j"
done

for o in 1 2 3; do
	for i in 10 20 30; do
		if [ "$i" = "20" ]; then
			break 2
		fi
		echo "break_multi_${o}_${i}"
	done
done

for o in 1 2 3; do
	for i in 10 20; do
		if [ "$i" = "20" ]; then
			continue 2
		fi
		echo "continue_multi_${o}_${i}"
	done
done
