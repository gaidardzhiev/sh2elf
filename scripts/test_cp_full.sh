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
cp -- a z0; cat z0
cp nonexist z 2>&1; echo rc=$?
cp d z2 2>&1; echo rc=$?
cp a a 2>&1; echo rc=$?
cp 2>&1; echo rc=$?
cp a 2>&1; echo rc=$?
cp a b c 2>&1; echo rc=$?
cp a nodir/ 2>&1; echo rc=$?
cp a b nodir 2>&1; echo rc=$?
cp d/f1 d/sub/f2 e; cat e/f1; cat e/f2
printf 'new\n' > n
printf 'y\n' | cp -i a n 2>&1; echo; cat n
printf 'n\n' | cp -i b n 2>&1; echo; echo rc=$?; cat n
cp -i a fresh </dev/null 2>&1; cat fresh
printf 'x\n' > ro; /bin/chmod 444 ro
cp a ro 2>&1; echo rc=$?
cp -f a ro; cat ro
ln -s nowhere dangle
cp a dangle 2>&1; echo rc=$?; cat nowhere
cp 'a' "q'uote"; cp "q'uote" 'sp ace'; cat 'sp ace'
for o in -a -r -b -d -l -n -s -T -u -v -x -Z -k --archive --recursive --parents --reflink --no-clobber --backup --update --debug --help --version --preserve=all --target-directory=e; do
	cp $o a zz 2>&1; echo rc=$?
done
cp -t e a 2>&1; echo rc=$?
cp -S .b a zz 2>&1; echo rc=$?
cd /
/bin/rm -rf $T
