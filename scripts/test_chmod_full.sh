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
chmod -R -v go-w d; echo rc=$?
chmod -c u+s,g+s d/f; echo rc=$?
stat -c '%n %a' d d/e d/f d/e/g
chmod -v a=r d/sl d/dg; echo rc=$?
chmod -h -v 700 d/sl d/dg; echo rc=$?
chmod -v 0 d/f
chmod -v u=rw,go=r d/f
chmod -c a+X d/f d/e
chmod -v a-x+X d/e/g
chmod -v g=u,o= d/e/g
chmod -v u+t,g+t d/e
chmod -v 7777 d/e/g
chmod -v 00755 d/e
chmod -v 1777 d/e/g
chmod --reference=d/e -v d/e/g
chmod --reference=nonexist d 2>&1; echo rc=$?
chmod 2>&1; echo rc=$?
chmod 755 2>&1; echo rc=$?
chmod xyz d 2>&1; echo rc=$?
chmod u+q d 2>&1; echo rc=$?
chmod -k 755 d 2>&1; echo rc=$?
chmod 755 nonexist 2>&1; echo rc=$?
chmod -f 755 nonexist; echo rc=$?
chmod -v 755 nonexist 2>&1; echo rc=$?
chmod -R --dereference -P 755 d 2>&1; echo rc=$?
chmod --reference=d 755 d 2>&1; echo rc=$?
chmod -R --preserve-root 755 / 2>&1; echo rc=$?
chmod -v a-w d/f; chmod -v a+w d/f; echo rc=$?
chmod -Rc go-rwx d; echo rc=$?
chmod -RLv u+w d 2>&1; echo rc=$?
chmod -RPv a+rx d 2>&1; echo rc=$?
mkdir 'sp ace'; chmod 755 'sp ace'
chmod -v 700 'sp ace' 2>&1
stat -c '%n %a' d d/e d/f d/e/g 'sp ace'
