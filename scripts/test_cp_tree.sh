T=/tmp/sh2elf_cp_tree
/bin/rm -rf $T
/bin/mkdir -p $T/d/sub/deep $T/e
cd $T
printf 'hello\n' > a
printf 'in d\n' > d/f1
printf 'sub\n' > d/sub/f2
printf 'deep\n' > d/sub/deep/f3
ln -s f1 d/lnk
ln d/f1 d/hard
/usr/bin/touch -d @981173106 a d/f1 d/sub/f2 d/sub
/bin/chmod 750 d/sub
cp -a d z2; stat -c '%n %a %Y %h' z2/f1 z2/sub z2/hard z2/sub/f2; stat -c '%n %F' z2/lnk
cp -r d z1; ls -R z1
cp -rv d e | sort
cp -r d d/sub 2>&1; echo rc=$?
cp -rL d z3; stat -c '%n %F' z3/lnk
cp -p a z4; stat -c '%a %Y' z4
cp -b a z4; ls | grep '^z4'
cp --backup=numbered a z4; cp --backup=numbered a z4; ls | grep '^z4'
cp -S .bak -b a z4; ls | grep '^z4'
cp --parents -v d/sub/f2 e
ls -R e/d
cp -l a hl; stat -c '%h' a
cp -s a sy; stat -c '%N' sy
cp -ru d e; cp -ruv d e
cp -r d/ z5; ls z5
cp -r d e/d/f1 2>&1; echo rc=$?
cp -r --strip-trailing-slashes d/// z6; ls z6
cp -t e -r d a; ls e
cd /
/bin/rm -rf $T
