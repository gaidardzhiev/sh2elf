A=/tmp/sh2elf_mv_xa
B=/var/tmp/sh2elf_mv_xb
/bin/rm -rf $A $B
/bin/mkdir -p $A/d/sub $B
cd $A
printf 'hello\n' > a
printf 'in d\n' > d/f1
printf 'sub\n' > d/sub/f2
ln -s f1 d/lnk
ln d/f1 d/hard
/usr/bin/touch -d @981173106 a d/f1 d/sub/f2 d/sub d
/bin/chmod 750 d/sub
mv -v a $B
stat -c '%n %a %Y' $B/a
mv -v d $B | sort
stat -c '%n %a %Y %h' $B/d $B/d/sub $B/d/f1 $B/d/hard $B/d/sub/f2
stat -c '%n %F' $B/d/lnk
ls
mv -v $B/d $A/d2 | sort
ls -R $A/d2
printf 'x\n' > b; printf 'y\n' > $B/b
mv -bv b $B
ls $B
printf 'x\n' > c; /bin/mkdir $B/c
mv c $B 2>&1; echo rc=$?
/bin/mkdir -p ro/s; printf 'r\n' > ro/s/f; /bin/chmod 555 ro/s
mv ro $B 2>&1; echo rc=$?
/bin/chmod -R u+w ro $B/ro
ls ro/s $B/ro/s
mv --no-copy c $B/z 2>&1; echo rc=$?
cd /
/bin/rm -rf $A $B
