/bin/rm -rf ls_l
/bin/mkdir ls_l
cd ls_l
printf 'hello\n' > a
head -c 5000 /dev/zero > big
head -c 3000000 /dev/zero > huge
printf '#!/bin/sh\n' > exe
/bin/chmod 755 exe
/bin/chmod 644 big huge
/usr/bin/touch sgid suid sticky
/bin/chmod 2755 sgid
/bin/chmod 4755 suid
/bin/chmod 1644 sticky
/bin/chmod 640 a
ln -s a lnk
ln -s nowhere dangling
ln a hard
/usr/bin/touch -d @1234567890 a big huge exe sgid suid sticky
/usr/bin/touch -h -d @1234567890 lnk dangling
ls -lgG --time-style=+%s a big huge exe sgid suid sticky lnk dangling hard
ls -lgG --time-style=+%s -h big huge
ls -lgG --time-style=+%s --si big huge
ls -lgG --time-style=+%s --block-size=1K big huge
ls -lgG --time-style=+%s --block-size=M huge
ls -lgG --time-style=+%s --block-size="'1" huge
ls -lgG --time-style=+%s -F exe lnk dangling a
ls -lgG --time-style=+%s -L lnk
ls -lgG --time-style=+%s -i a hard | /bin/sed 's/^ *[0-9]* //'
ls -lgG --time-style='+%s|%N|%3N|%-e|%%' a
ls -lgG --time-style='+[%10s][%-10s][%010s]' a
ls -og --time-style=+%s a
ls -l --time-style=+%s -n a | cut -d' ' -f1,2,5,6,7
ls -lgG --time-style=+%s --sort=size a big huge exe
ls -lgGr --time-style=+%s --sort=size a big huge exe
ls -lgG --time-style=bogus a
echo "rc=$?"
cd ..
/bin/rm -rf ls_l
