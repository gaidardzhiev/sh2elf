#!/bin/sh
echo "argc=$#"
echo "first=$1 second=$2 third=$3"
echo "all=$@"
false
echo "status=$?"
true
echo "status=$?"
[ "$1" = "one" ] && echo "arg1-match"
[ $# -eq 3 ] && echo "argc-three"
[ -n "$PPID" ] && echo "ppid-set"
[ $$ -gt 1 ] && echo "pid-positive"
R=$RANDOM
[ $R -ge 0 ] && [ $R -le 32767 ] && echo "random-range"
/bin/echo "ext:$1:$2"
exit 7
