T=/tmp/sh2elf_cp_full
/bin/rm -rf $T
/bin/mkdir -p $T/d/sub $T/e
cd $T
printf 'hello\n' > a
printf 'world\n' > b
printf 'in d\n' > d/f1
printf 'sub\n' > d/sub/f2
cp a z; cat z
cp a b; cat b
cp a d; cat d/a
cp a e/; cat e/a
cp nonexist z 2>&1; echo rc=$?
cp d z2 2>&1; echo rc=$?
cp a a 2>&1; echo rc=$?
cp 2>&1; echo rc=$?
cp a 2>&1; echo rc=$?
cp a b c 2>&1; echo rc=$?
cp -T a b e 2>&1; echo rc=$?
cp -k a z 2>&1; echo rc=$?
cp --sparse=bogus a z 2>&1; echo rc=$?
cp --update=x a z 2>&1; echo rc=$?
cp -ls a z 2>&1; echo rc=$?
cp -n -b a b 2>&1; echo rc=$?
cp --preserve=context a z 2>&1; echo rc=$?
cp -v a z3
cp -v a b
cp -t e -v a b
cp a nodir/ 2>&1; echo rc=$?
cp a b nodir 2>&1; echo rc=$?
printf 'new\n' > n; cp -n a n 2>&1; echo rc=$?; cat n
cp --update=none-fail a n 2>&1; echo rc=$?
cp --debug a z4
printf 'y\n' | cp -i a n 2>&1; echo; cat n
printf 'n\n' | cp -i b n 2>&1; echo; echo rc=$?; cat n
printf 'x\n' > ro; /bin/chmod 444 ro
cp a ro 2>&1; echo rc=$?
cp -f a ro; cat ro
ln -s nowhere dangle
cp a dangle 2>&1; echo rc=$?
cp 'a' "q'uote"; cp -v "q'uote" 'sp ace'
cd /
/bin/rm -rf $T
