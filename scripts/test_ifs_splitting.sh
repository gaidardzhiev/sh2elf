#!/bin/sh
IFS=":"
LIST="one:two:three"
for item in $LIST; do
	echo "ifs_item:$item"
done
