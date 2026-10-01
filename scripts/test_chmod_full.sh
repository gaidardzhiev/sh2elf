T=/tmp/sh2elf_chmod_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
mkdir -p d/e
printf 'f\n' > d/f
printf 'g\n' > d/e/g
ln -s f d/sl
ln -s nowhere d/dg
chmod 775 d d/e
chmod 664 d/f d/e/g
chmod -R go-w d; echo rc=$?
stat -c '%n %a' d d/e d/f d/e/g
chmod u+s,g+s d/f; stat -c '%n %a' d/f
chmod a=r d/sl; echo rc=$?; stat -c '%n %a' d/f
chmod 700 d/dg 2>&1; echo rc=$?
chmod 0 d/f; stat -c '%n %a' d/f
chmod u=rw,go=r d/f; stat -c '%n %a' d/f
chmod a+X d/f d/e; stat -c '%n %a' d/f d/e
chmod a-x+X d/e/g; stat -c '%n %a' d/e/g
chmod g=u,o= d/e/g; stat -c '%n %a' d/e/g
chmod u+t,g+t d/e; stat -c '%n %a' d/e
chmod 7777 d/e/g; stat -c '%n %a' d/e/g
chmod 00755 d/e; stat -c '%n %a' d/e
chmod 1777 d/e/g; stat -c '%n %a' d/e/g
chmod go+-w,uo=g d/f; stat -c '%n %a' d/f
chmod g=o-w d/f; stat -c '%n %a' d/f
chmod a+= d/f; stat -c '%n %a' d/f
chmod -- -w d/f; stat -c '%n %a' d/f
chmod -- -r,+w,u+r d/f; stat -c '%n %a' d/f
chmod -RR 755 d; echo rc=$?; stat -c '%n %a' d d/e d/f d/e/g
chmod 2>&1; echo rc=$?
chmod -R 2>&1; echo rc=$?
chmod 755 2>&1; echo rc=$?
chmod -- 755 2>&1; echo rc=$?
chmod xyz d 2>&1; echo rc=$?
chmod u+q d 2>&1; echo rc=$?
chmod ,u+x d 2>&1; echo rc=$?
chmod +755 d 2>&1; echo rc=$?
chmod u=7 d 2>&1; echo rc=$?
chmod 017777 d 2>&1; echo rc=$?
for o in -k -w -x -v -c -f -h -H -L -P -Rv --reference=d --preserve-root --recursive --help --version; do
	chmod $o 755 d 2>&1; echo rc=$?
done
chmod 755 nonexist 2>&1; echo rc=$?
chmod 755 d nonexist d/f 2>&1; echo rc=$?
chmod 755 -R 2>&1; echo rc=$?
chmod -Rv 700 d 2>&1; echo rc=$?; stat -c '%n %a' d
chmod -R go-rwx d; echo rc=$?; stat -c '%n %a' d d/e d/f d/e/g
mkdir 'sp ace'; chmod 755 'sp ace'
chmod 700 'sp ace' "q'uote" 2>&1; echo rc=$?
stat -c '%n %a' d d/e d/f d/e/g 'sp ace'
