/bin/rm -rf findt_t
/bin/mkdir findt_t
cd findt_t
/usr/bin/touch -d '2020-01-02 03:04:05' old
/usr/bin/touch -d '2020-01-02 03:04:06' old2
/usr/bin/touch -d '2021-07-04 12:00:00' mid
/usr/bin/touch -d '2021-07-04 12:00:00.5' midns
/usr/bin/touch -d '1969-07-20 20:17:40 UTC' moon
/usr/bin/touch -d '2037-12-31 23:59:59' future
find . -newermt '2020-01-02 03:04:05' ! -name . | sort
find . -newermt '2020-01-02 03:04:04' ! -name . | sort
find . -newermt '2021-07-04 12:00:00' ! -name . | sort
find . -newermt '2021-07-04 16:00:00 UTC' ! -name . | sort
find . -newermt '@1625400000' ! -name . | sort
find . ! -newermt '1970-01-01' ! -name .
find . -newermt '2021-07-04 12:00:00 +1 day' ! -name .
find . -newermt 'Jul 4 2021 11:59:59' ! -name . | sort
find . -newermt '2021-02-30' 2>&1
find . -newermt 'garbage' 2>&1
find . -newer old ! -name . | sort
find . -anewer mid -name 'm*' | sort
find . -mtime +1000 | sort
find . ! -name . -printf '%p %TY %Tm %Td %TH %TM\n' | sort
cd ..
/bin/rm -rf findt_t
