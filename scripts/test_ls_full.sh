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
ls -a
ls -A
ls -1
ls -C -w 40
ls -x -w 40
ls -m -w 40
ls -F
ls -p
ls --file-type
ls -r
ls -S
ls -t apple banana cherry.txt date.c
ls -tr apple banana cherry.txt date.c
ls -X
ls -v
ls -U -1 apple
ls -B
ls -a -B
ls -I '*.txt' -I 'f*'
ls --hide='d*'
ls -a --hide='d*'
ls -d dir1 dir2
ls --group-directories-first
ls --sort=width
ls -C -w 30 -T 0
ls --format=commas -w 20
ls --zero apple banana | tr '\0' '|'
echo
ls nofile
echo "rc=$?"
ls apple nofile banana
echo "rc=$?"
ls -y
echo "rc=$?"
ls --sort=bogus
echo "rc=$?"
ls --form=v
echo "rc=$?"
cd ..
/bin/rm -rf ls_t
