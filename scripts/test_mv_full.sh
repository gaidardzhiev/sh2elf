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
mv -- e/a a2; cat a2
mv nonexist z 2>&1; echo rc=$?
mv 2>&1; echo rc=$?
mv b 2>&1; echo rc=$?
mv b b 2>&1; echo rc=$?
mv d d/sub 2>&1; echo rc=$?
mv e d/f1 2>&1; echo rc=$?
mv d/f1 e 2>&1; ls e
mv a2 nodir/ 2>&1; echo rc=$?
mv a2 b e 2>&1; echo rc=$?
mv e/f1 d; ls d
printf 'x\n' > n; printf 'y\n' > m
printf 'n\n' | mv -i n m 2>&1; echo; echo rc=$?; cat m
printf 'y\n' | mv -i n m 2>&1; echo; cat m
printf 'x\n' > n
printf 'n\n' | mv -f -i n m 2>&1; echo; cat m
mv -i -f n m 2>&1 </dev/null; cat m
printf 'r\n' > ro; /bin/chmod 444 ro; printf 'w\n' > w
mv w ro </dev/null 2>&1; cat ro
mv d/ y 2>&1; echo rc=$?
ls
for o in -b -n -u -v -T -Z -x -k --backup --no-clobber --update --verbose --exchange --no-copy --debug --strip-trailing-slashes --force --help --version; do
	mv $o y z 2>&1; echo rc=$?
done
mv -t e y 2>&1; echo rc=$?
cd /
/bin/rm -rf $T
