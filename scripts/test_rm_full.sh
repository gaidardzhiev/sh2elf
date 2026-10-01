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
for o in -k -I -x --interactive --one-file-system --preserve-root --no-preserve-root --recursive --force --dir --verbose ---presume-input-tty --help --version; do
	rm $o b </dev/null 2>&1; echo rc=$?
done
rm -r </dev/null 2>&1; echo rc=$?
rm d </dev/null 2>&1; echo rc=$?
rm -d d </dev/null 2>&1; echo rc=$?
rm -dv ed </dev/null
rm -r . </dev/null 2>&1; echo rc=$?
rm -r d/.. </dev/null 2>&1; echo rc=$?
rm -rv d/sub </dev/null | sort
printf 'n\n' | rm -i b 2>&1; echo; ls
printf 'y\n' | rm -iv b 2>&1; echo; ls
printf 'x\n' > p; printf 'y\n' > q; printf 'z\n' > r; printf 'w\n' > s
printf 'n\n' | rm -i p q 2>&1; echo; ls
printf 'y\ny\n' | rm -fiv p q 2>&1
rm -if r s </dev/null 2>&1; echo; ls
printf 'x\n' > ro; /bin/chmod 444 ro
rm ro </dev/null 2>&1; echo rc=$?; ls
printf 'x\n' > ro; /bin/chmod 444 ro
rm -v ro </dev/null
/bin/mkdir -p w/x; printf 'k\n' > w/x/k; /bin/chmod 555 w/x
rm -rv w </dev/null 2>&1; echo rc=$?
/bin/chmod 755 w/x
rm -rfv w </dev/null
/usr/bin/touch -- -foo
printf 'x\n' > e/g
printf 'n\ny\n' | rm -ri e 2>&1; echo; ls e
rm -foo </dev/null 2>&1; echo rc=$?
rm -v -- -foo </dev/null
rm -rv d e </dev/null
ls
cd /
/bin/rm -rf $T
