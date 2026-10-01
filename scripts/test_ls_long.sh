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
TZ=UTC ls -og a big huge exe sgid suid sticky lnk dangling hard
TZ=UTC ls -og -F exe lnk dangling a
TZ=UTC ls -og -p lnk a
TZ=UTC ls -og -L lnk
TZ=UTC ls -ogL lnk dangling 2>&1
echo "rc=$?"
TZ=UTC ls -og -i a hard | /bin/sed 's/^ *[0-9]* //'
TZ=UTC ls -gon a
TZ=UTC ls -og -S a big huge exe
TZ=UTC ls -og -Sr a big huge exe
TZ=UTC ls -og -t a big huge exe
/usr/bin/touch -d '2001-02-03 04:05:06 UTC' big
/usr/bin/touch -d '1969-12-31 23:59:59 UTC' huge
TZ=UTC ls -og a big huge
TZ=UTC ls -og -t a big huge
TZ=UTC ls -og -rt a big huge
TZ=Asia/Kolkata ls -og a big huge
TZ=UTC ls -log a 2>&1
echo "rc=$?"
for o in -h --si --full-time --time-style=+%s --block-size=1K --author -lZ --time=ctime -D --dired --sort=size --numeric-uid-gid -lG; do
	ls -og $o a 2>&1
	echo "rc=$?"
done
cd ..
/bin/rm -rf ls_l
