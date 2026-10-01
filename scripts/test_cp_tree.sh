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
/usr/bin/mkfifo d/fifo
/usr/bin/touch -d @981173106 a d/f1 d/sub/f2 d/sub
/bin/chmod 750 d/sub
cp -RpP d z2; stat -c '%n %a %Y' z2/f1 z2/sub z2/hard z2/sub/f2; stat -c '%n %F' z2/lnk z2/fifo
cp -R d z1; ls -R z1
cp -R d e; ls -R e
cp -R d d/sub 2>&1; echo rc=$?
cp -RL d z3; stat -c '%n %F' z3/lnk
cp -RH d z3h; stat -c '%n %F' z3h/lnk
ln -s d dl
cp -RH dl z7; stat -c '%n %F' z7 z7/lnk
cp -RP dl z8; stat -c '%n %F' z8
cp -R -H -P dl z9; stat -c '%n %F' z9
cp -p a z4; stat -c '%a %Y' z4
cp -R d/ z5; ls z5
cp -R d e/d/f1 2>&1; echo rc=$?
cp -R a d/sub z6 2>&1; echo rc=$?
cp -R d a 2>&1; echo rc=$?
cp dl z10 2>&1; echo rc=$?
cp -P d/lnk z11; stat -c '%n %F' z11
cp d/lnk z12; stat -c '%n %F' z12
cd /
/bin/rm -rf $T
