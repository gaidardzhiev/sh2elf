#!/bin/sh
D=/tmp/sh2elf_grep
/bin/rm -rf $D
mkdir -p $D
printf 'a fox\nerror\nerr\n' > $D/p
grep -f scripts/grep_pats.txt $D/p
cd $D
printf 'the quick brown fox\njumps over\nthe lazy dog\nERROR: disk\nerror: net\n\nfox and dog\n' > a
printf 'one\ntwo fox\nthree\n' > b
grep fox a
grep -n fox a b
grep -c o a b
grep -v o a
grep -i error a
grep -x 'jumps over' a
grep -l fox a b
grep -e fox -e net a
grep -F 'err' a
grep -E 'fox|net' a
grep -q fox a; echo rc=$?
grep -q nothing a; echo rc=$?
grep fox nosuch a; echo rc=$?
grep -s fox nosuch; echo rc=$?
/usr/bin/printf 'a\0b\nab\n' > bin
grep ab bin; echo rc=$?
grep -c a bin
grep -vc '' a
grep -k x a; echo rc=$?
for o in -w -o -b -H -h -L -m1 -A1 -B1 -C1 -2 -T -Z -a -z -r -R -P -G -V --color --label=x --help; do
	grep $o fox a 2>&1
	echo "rc=$?"
done
grep -c -l fox a 2>&1; echo rc=$?
grep -E -F fox a 2>&1; echo rc=$?
grep 2>&1; echo rc=$?
grep -ivn FOX a b
grep -cv o a b
grep -lv o a b
grep -x -F 'jumps over' a
grep -e fox -e '' a | grep -c .
P=fox
grep "$P" a
O=-n
grep $O "$P" a b
G=grep
$G -i "ERROR" a
cd /tmp
/bin/rm -rf $D
