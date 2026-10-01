/bin/rm -rf ls_t
/bin/mkdir ls_t
cd ls_t
/bin/mkdir dir1 dir2 emptyd
/usr/bin/touch apple banana cherry.txt date.c eggs.TXT fig10 fig9 file-1.2.10 file-1.2.9 .hidden x~ .y~
printf 'aaaaaaaaaa' > banana
printf 'aaaaa' > apple
printf '#!/bin/sh\n' > run.sh
/bin/chmod 755 run.sh
ln -s apple lnk
ln -s nowhere dangling
/usr/bin/touch -d @1000000000 apple
/usr/bin/touch -d @1100000000 banana
/usr/bin/touch -d @1200000000 cherry.txt
/usr/bin/touch -d @900000000 date.c
ls
ls
echo
ls -a
ls -A
ls -1
COLUMNS=40 ls -C
COLUMNS=40 ls -x
COLUMNS=40 ls -m
ls -m
ls -F
ls -p
ls -r
ls -S
ls -t apple banana cherry.txt date.c
ls -tr apple banana cherry.txt date.c
ls -u apple banana cherry.txt date.c
ls -tu apple banana cherry.txt date.c
ls -c -r apple banana cherry.txt date.c
ls -d dir1 dir2
ls -A -F dir1 dir2 run.sh
ls -1F lnk dangling run.sh
ls -Ap
ls -- apple
ls -a -A
ls -C -1
ls -m -x
ls nofile 2>&1
echo "rc=$?"
ls apple nofile banana 2>&1
echo "rc=$?"
ls apple -a 2>&1
echo "rc=$?"
for o in -y -X -v -U -B -h -Q -b -N -G -Z -D -I -w -T --all --sort=size --format=long --color=always --hide=x --group-directories-first --zero --file-type --help --version; do
	ls $o 2>&1
	echo "rc=$?"
done
cd ..
/bin/rm -rf ls_t
