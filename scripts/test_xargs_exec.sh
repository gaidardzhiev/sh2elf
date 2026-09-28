printf 'x y\nz\n' | xargs -I {} echo [{}] and {}
printf 'x y\nz\n' | xargs -I XX echo XXXX-XX
printf 'x y\nz\n' | xargs -i echo [{}]
printf 'a  b\n  c\n' | xargs -I{} echo [{}]
printf 'one two\n' | xargs sh -c 'echo "$#: $@"' sh
printf 'a b c\n' | xargs -n1 sh -c 'test $0 = b && exit 3; echo $0'; echo rc=$?
printf 'a b c d\n' | xargs -P 2 -n1 sh -c 'echo $0' | sort
printf 'a b\n' | xargs --process-slot-var=SLOT -n1 sh -c 'echo $SLOT $0'
printf 'a\n' | xargs sh -c 'cat; echo done'
printf '1 2\n3\n' > xargs_in.txt
xargs -a xargs_in.txt echo F
xargs -a xargs_in.txt sh -c 'cat; echo done' < xargs_in.txt
/bin/rm -f xargs_in.txt
/usr/bin/seq 1 100000 | xargs echo | wc -l
/usr/bin/seq 1 100000 | xargs echo | /usr/bin/md5sum
/usr/bin/seq 1 20000 | xargs -n 999 echo | /usr/bin/md5sum
/usr/bin/seq 1 3000 | xargs -L 7 echo | /usr/bin/md5sum
/usr/bin/seq 1 2000 | xargs -I{} echo x{}x | /usr/bin/md5sum
/usr/bin/seq 1 10 | xargs -s 20 -x echo 2>&1
