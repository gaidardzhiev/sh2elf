printf 'x y\nz\n' | xargs -I {} echo [{}] and {}
printf 'x y\nz\n' | xargs -I XX echo XXXX-XX
printf 'a  b\n  c\n' | xargs -I{} echo [{}]
printf 'one two\n' | xargs sh -c 'echo "$#: $@"' sh
printf 'a b c\n' | xargs -n1 sh -c 'test $0 = b && exit 3; echo $0'; echo rc=$?
printf 'a b c d\n' | xargs -n1 sh -c 'echo $0'
printf 'a\n' | xargs sh -c 'cat; echo done'
printf '1 2\n3\n' | xargs -n1 -t echo F 2>&1
printf 'a b\nc\n' | xargs -t -I{} echo [{}] 2>&1
/usr/bin/seq 1 100000 | xargs echo | wc -l
/usr/bin/seq 1 100000 | xargs echo | /usr/bin/md5sum
/usr/bin/seq 1 20000 | xargs -n 999 echo | /usr/bin/md5sum
/usr/bin/seq 1 3000 | xargs -L 7 echo | /usr/bin/md5sum
/usr/bin/seq 1 2000 | xargs -I{} echo x{}x | /usr/bin/md5sum
/usr/bin/seq 1 10 | xargs -s 20 -x echo 2>&1
/usr/bin/seq 1 10 | xargs -s 20 echo 2>&1
printf 'a b c\n' | xargs -n1 sh -c 'echo $0; exit 255' 2>&1; echo rc=$?
