T=/tmp/sh2elf_rmdir_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
mkdir -p a/b/c e/f x y
printf 'f\n' > file
printf 'g\n' > e/g
rmdir x; ls
rmdir 2>&1; echo rc=$?
rmdir -k x 2>&1; echo rc=$?
rmdir nonexist 2>&1; echo rc=$?
rmdir file 2>&1; echo rc=$?
rmdir e 2>&1; echo rc=$?
for o in -v -k -x --parents --verbose --ignore-fail-on-non-empty --help --version; do
	rmdir $o y 2>&1; echo rc=$?
done
rmdir -p 2>&1; echo rc=$?
rmdir y
rmdir -p a/b/c
ls
mkdir -p p/q/r
rmdir -p p//q///r// ; ls
mkdir -p e/h/i
rmdir -p e/h/i 2>&1; echo rc=$?
ls e
ln -s e se
rmdir se/ 2>&1; echo rc=$?
rmdir se 2>&1; echo rc=$?
rmdir file/ 2>&1; echo rc=$?
rmdir . 2>&1; echo rc=$?
mkdir 'sp ace' "q'uote"
rmdir 'sp ace' "q'uote"; ls
rmdir 'sp ace' 2>&1; echo rc=$?
cd /
/bin/rm -rf $T
