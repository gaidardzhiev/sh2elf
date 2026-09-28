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
rmdir --ignore-fail-on-non-empty e; echo rc=$?
rmdir -v y
rmdir -pv a/b/c
ls
mkdir -p p/q/r
rmdir -p p//q///r// ; ls
mkdir -p e/h/i
rmdir -pv e/h/i 2>&1; echo rc=$?
mkdir -p e/h/i
rmdir -pv --ignore-fail-on-non-empty e/h/i; echo rc=$?
ln -s e se
rmdir se/ 2>&1; echo rc=$?
rmdir se 2>&1; echo rc=$?
rmdir file/ 2>&1; echo rc=$?
rmdir . 2>&1; echo rc=$?
mkdir 'sp ace' "q'uote"
rmdir -v 'sp ace' "q'uote"
cd /
/bin/rm -rf $T
