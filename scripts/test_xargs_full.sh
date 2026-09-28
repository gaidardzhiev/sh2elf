printf 'a b\nc\n' | xargs
printf 'a b\nc\n' | xargs echo X
printf 'a b c d e\n' | xargs -n 2 echo N
printf 'l1 a\nl2 b\n\nl3 c\n' | xargs -L 1 echo L
printf 'l1 a \nl2 b\nl3 c\n' | xargs -L 1 echo L
printf 'l1\nl2\nl3\n' | xargs -l2 echo L
printf "'a b' \"c d\" e\\\\ f\n" | xargs -n1 echo
printf 'a"b c"d e\n' | xargs -n1 echo
/usr/bin/printf 'a\0b c\0d\0' | xargs -0 -n1 echo
printf 'a,b,c' | xargs -d , -n1 echo
printf 'a:b' | xargs -d '\x3a' echo
printf 'a b END c d\n' | xargs -E END echo
printf 'a b\nEND\nc d\n' | xargs -E END echo
printf '' | xargs echo empty
printf '' | xargs -r echo empty
printf '\n\n  \n' | xargs echo blank
printf 'aaaa bbbb cccc\n' | xargs -s 15 echo
printf 'a b c\n' | xargs -t echo 2>&1
printf "a b\n'c d'\n" | xargs -t echo 2>&1
printf 'a\n' | xargs -x -s 5 echo 2>&1
printf 'aaaa bbbb cccc\n' | xargs -s 14 -x echo 2>&1
printf 'a b\n' | xargs -s 0 echo 2>&1
printf 'a b\n' | xargs -n 0 echo 2>&1
printf 'a b\n' | xargs -q echo 2>&1
printf 'a b\n' | xargs --ma=1 echo 2>&1
printf 'a b\n' | xargs -n1 -L1 echo 2>&1
printf 'a b\n' | xargs -0 -E x echo 2>&1
printf 'a"b\n' | xargs echo 2>&1
printf 'a b\n' | xargs -d '\q' echo 2>&1
/usr/bin/printf 'x\0y\n' | xargs echo 2>&1
printf 'a b\n' | xargs nosuchcmd 2>&1; echo rc=$?
printf 'a b\n' | xargs false; echo rc=$?
printf 'a b\n' | xargs sh -c 'exit 255' 2>&1; echo rc=$?
printf 'a b\n' | xargs sh -c 'kill -TERM $$' 2>&1; echo rc=$?
printf 'a b\n' | xargs ./ 2>&1; echo rc=$?
printf 'a b\n' | xargs -a /nonexistent echo 2>&1; echo rc=$?
