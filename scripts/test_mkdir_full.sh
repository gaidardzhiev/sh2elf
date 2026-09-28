T=/tmp/sh2elf_mkdir_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
printf 'f\n' > file
mkdir a; ls
mkdir a 2>&1; echo rc=$?
mkdir b c; ls
mkdir x/y 2>&1; echo rc=$?
mkdir 2>&1; echo rc=$?
mkdir -k z 2>&1; echo rc=$?
mkdir -m bad z 2>&1; echo rc=$?
mkdir -m 8 z 2>&1; echo rc=$?
mkdir -p a; echo rc=$?
mkdir -pv p/q/r
mkdir -pv p/q/s ./t/../u
mkdir -p file/x 2>&1; echo rc=$?
mkdir -p file 2>&1; echo rc=$?
mkdir -v v1 v2
mkdir -m 700 m1; stat -c '%n %a' m1
mkdir -m 1777 m2; stat -c '%n %a' m2
mkdir -m u=rwx,g=rx,o= m3; stat -c '%n %a' m3
mkdir -m a-w m4; stat -c '%n %a' m4
mkdir -m g+s m5; stat -c '%n %a' m5
mkdir -m a=rwx,o-rx m6; stat -c '%n %a' m6
mkdir -pm 700 n1/n2; stat -c '%n %a' n1/n2
mkdir -pm u+s,g-w n3/n4; stat -c '%n %a' n3/n4
mkdir -pm 000 n5/n6; stat -c '%n %a' n5/n6
mkdir -pv 'sp ace' "q'uote"
mkdir -- -dash; ls -d -- -dash
cd /
/bin/rm -rf $T
