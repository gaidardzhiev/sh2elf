T=/tmp/sh2elf_mv_full
/bin/rm -rf $T
/bin/mkdir -p $T/d/sub $T/e
cd $T
printf 'hello\n' > a
printf 'world\n' > b
printf 'in d\n' > d/f1
mv a z; cat z
mv z a; mv a b; cat b
printf 'hello\n' > a
mv a d; ls d
mv d/a e/; ls e
mv nonexist z 2>&1; echo rc=$?
mv 2>&1; echo rc=$?
mv b 2>&1; echo rc=$?
mv -T b e/a d 2>&1; echo rc=$?
mv -k b z 2>&1; echo rc=$?
mv -n -b b z 2>&1; echo rc=$?
mv --update=x b z 2>&1; echo rc=$?
mv b b 2>&1; echo rc=$?
mv d d/sub 2>&1; echo rc=$?
mv e d/f1 2>&1; echo rc=$?
mv d/f1 e 2>&1; ls e
mv -v e/f1 d
mv -v b e/a
mv -t d -v e/a
printf 'x\n' > n; printf 'y\n' > m
mv -n n m; cat m
mv --update=none-fail n m 2>&1; echo rc=$?
printf 'n\n' | mv -i n m 2>&1; echo; echo rc=$?
printf 'y\n' | mv -i n m 2>&1; echo; cat m
printf 'x\n' > n; mv -b n m; ls | grep '^m'
printf 'x\n' > n; mv --backup=numbered n m; printf 'x\n' > n; mv --backup=numbered n m; ls | grep '^m'
printf 'x\n' > p; printf 'q\n' > m; mv --exchange p m; cat p; cat m
mv -v --no-copy d x
mv d/ y 2>&1; echo rc=$?
cd /
/bin/rm -rf $T
