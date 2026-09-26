#!/bin/sh
cat <<< "here string"
V="with var"
cat <<< "$V"
/usr/bin/tr a-z A-Z <<< hello
cat <<< piped | cat
