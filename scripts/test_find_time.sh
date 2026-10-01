/bin/rm -rf findt_t
/bin/mkdir findt_t
cd findt_t
/usr/bin/touch -d '2020-01-02 03:04:05' old
/usr/bin/touch -d '2020-01-02 03:04:06' old2
/usr/bin/touch -d '2021-07-04 12:00:00' mid
/usr/bin/touch -d '2021-07-04 12:00:00.5' midns
/usr/bin/touch -d '1969-07-20 20:17:40 UTC' moon
/usr/bin/touch -d '2037-12-31 23:59:59' future
/usr/bin/touch fresh
find . -newer old ! -name . ! -name fresh | sort
find . -newer old2 ! -name . ! -name fresh | sort
find . -newer mid ! -name . ! -name fresh | sort
find . ! -newer mid ! -name . | sort
find . -newer future ! -name .
find . -mtime +1000 | sort
find . -mtime -1 | sort
find . -name fresh -mtime 0
find . -name fresh -mtime -1
find . -name fresh -mtime +0
find . -name future -mtime -0
find . -name future -mtime 0
find . -name old -mtime +2000 -atime +2000
find . -ctime -1 | sort
find . -ctime +0
find . -mtime x 2>&1
find . -newermt '2020-01-02' 2>&1
find . -anewer old 2>&1
find . -daystart -mtime 0 2>&1
cd ..
/bin/rm -rf findt_t
