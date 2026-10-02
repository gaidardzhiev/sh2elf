#!/bin/sh
echo -n "no newline"
echo " done"
echo -e "a\tb\nc"
echo "a\tb\nc"
echo "stop\c here"
echo next
echo
echo -E "raw\tstay"
echo -ne "x\0101y"
echo -- "-dash"
echo "\0101\0102\0103"
echo "back\\\\slash"
echo "octal\0012end"
echo "\q unknown"
echo a "\c" b
echo next2
printf '%s\n' "no-newline-way:"
printf '%s' "via printf"
echo
E=-n
echo $E value
