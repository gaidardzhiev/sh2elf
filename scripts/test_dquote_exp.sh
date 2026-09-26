#!/bin/sh
X=5
echo "sum=$((X + 2)) cmd=$(echo inner) bt=`echo back`"
false
echo "st=$? done"
