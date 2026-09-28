T=/tmp/sh2elf_rm_full
/bin/rm -rf $T
/bin/mkdir -p $T/d/sub/deep $T/e $T/ed
cd $T
printf 'a\n' > a
printf 'b\n' > b
printf 'c\n' > c
printf 'f\n' > d/f1
printf 'g\n' > d/sub/f2
printf 'h\n' > d/sub/deep/f3
ln -s f1 d/lnk
rm a </dev/null; ls
rm nonexist </dev/null 2>&1; echo rc=$?
rm -f nonexist </dev/null; echo rc=$?
rm </dev/null 2>&1; echo rc=$?
rm -f </dev/null; echo rc=$?
rm -k b </dev/null 2>&1; echo rc=$?
rm --interactive=bad b </dev/null 2>&1; echo rc=$?
rm --no-preserve b </dev/null 2>&1; echo rc=$?
rm d </dev/null 2>&1; echo rc=$?
rm -d d </dev/null 2>&1; echo rc=$?
rm -dv ed </dev/null
rm -r . </dev/null 2>&1; echo rc=$?
rm -r d/.. </dev/null 2>&1; echo rc=$?
rm -rv d/sub </dev/null | sort
printf 'n\n' | rm -i b 2>&1; echo; ls
printf 'y\n' | rm -iv b 2>&1; echo; ls
printf 'x\n' > p; printf 'y\n' > q; printf 'z\n' > r; printf 'w\n' > s
printf 'n\n' | rm -I p q r s 2>&1; echo; ls
printf 'y\n' | rm -Iv p q r s 2>&1
printf 'x\n' > ro; /bin/chmod 444 ro
printf 'n\n' | rm ---presume-input-tty ro 2>&1; echo; ls
rm -v ro </dev/null
/bin/mkdir -p w/x; printf 'k\n' > w/x/k; /bin/chmod 555 w/x
rm -rv w </dev/null 2>&1; echo rc=$?
/bin/chmod 755 w/x
rm -rfv w </dev/null
/usr/bin/touch -- -foo
rm -foo </dev/null 2>&1; echo rc=$?
rm -v -- -foo </dev/null
rm -rv d e </dev/null
ls
cd /
/bin/rm -rf $T
