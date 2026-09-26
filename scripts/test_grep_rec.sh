#!/bin/sh
D=/tmp/sh2elf_greprec
/bin/rm -rf $D
/bin/mkdir -p $D/d1/d2
cd $D
printf 'hello\n' > a.txt
printf 'hello x\n' > d1/b.c
printf 'nohello\n' > d1/d2/c.txt
grep -r hello . | sort
grep -r hello | sort
grep -rc hello d1 | sort
grep -r --include='*.c' hello .
grep -r --exclude='*.c' hello | sort
grep -r --exclude-dir=d2 hello | sort
grep -rh hello d1 | sort
grep -rl hello . | sort
grep hello d1; echo rc=$?
grep -d skip hello d1 a.txt
grep -r --exclude=a.txt hello a.txt ./a.txt; echo rc=$?
