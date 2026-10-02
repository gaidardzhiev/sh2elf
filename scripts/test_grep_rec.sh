#!/bin/sh
D=/tmp/sh2elf_greprec
/bin/rm -rf $D
/bin/mkdir -p $D/d1/d2
cd $D
printf 'hello\n' > a.txt
printf 'hello x\n' > d1/b.c
printf 'nohello\n' > d1/d2/c.txt
find . -type f -exec grep hello {} + | sort
find d1 -type f -exec grep -c hello {} + | sort
find . -type f -name '*.c' -exec grep hello {} +
find . -type f ! -name '*.c' -exec grep hello {} + | sort
find . -path ./d1/d2 -prune -o -type f -exec grep hello {} + | sort
find . -type f -exec grep -l hello {} + | sort
grep hello d1; echo rc=$?
grep -s hello d1 a.txt; echo rc=$?
for o in -r -R '-d skip' --include=x --exclude=x --exclude-dir=x; do
	grep $o hello a.txt 2>&1
	echo "rc=$?"
done
cd /tmp
/bin/rm -rf $D
