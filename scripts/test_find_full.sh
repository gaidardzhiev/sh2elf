/bin/rm -rf find_t
/bin/mkdir -p find_t/d1/s1/deep find_t/d2 find_t/empty
cd find_t
printf 'hello\n' > a.txt
/usr/bin/head -c 5000 /dev/zero > big.bin
/usr/bin/head -c 1234 /dev/zero > d1/mid.dat
printf 'x' > d1/s1/f1
printf 'yy' > d1/s1/deep/f2
/usr/bin/touch 'sp ace' "it's" 'Zeta' 'alpha' d2/.hid d2/vis 'x~'
/bin/ln -s a.txt lnk
/bin/ln -s nowhere dang
/bin/ln -s d1 dl
/bin/chmod 755 alpha
/bin/chmod 600 Zeta
/usr/bin/touch -d '2020-01-02 03:04:05' a.txt big.bin 'sp ace' "it's" Zeta alpha x~ d2/.hid d2/vis d1/mid.dat d1/s1/f1 d1/s1/deep/f2 d1/s1/deep d1/s1 d1 d2 empty
/usr/bin/touch -h -d '2019-06-07 08:09:10' lnk dang dl
find . | sort
find . -name '*.txt'
find . -iname 'ZETA' -o -name 'alpha'
find . -type d | sort
find . -type l | sort
find -L . -type l
find -H dl lnk dang -type l
find -L dl -type d | sort
find . ! -name . -prune -type f -size +1 | sort
find . -size -2 -type f | sort
find . -size 1234c
find . -size +4999c -size -5001c
find . -perm -u+x -type f
find . -perm 600
find . -perm -u=rw,g=r -type f | sort
find . -links +2 -type d | sort
find . -path './d1/*' -prune -o -type f -print | sort
find d1 -depth
find d1 -depth -name s1 -prune -o -print
find d1/. ! -name . -prune
find . -newer a.txt | sort
find . ! -newer a.txt -type f | sort
find . ! -type d -name '[a-z]*' | sort
find . \( -name 'a*' -o -name 'b*' \) -type f | sort
find . -name 'a*' -o -name 'b*' -type f | sort
find . ! \( -type d -o -type l \) -name '*i*' | sort
find d1 -name f1 -print0 | /usr/bin/od -c | /usr/bin/head -2
find . -nouser -o -nogroup
find a.txt -user 0 -o -print
find nonexist 2>&1
echo rc=$?
find . -name 2>&1
echo rc=$?
find . -badpred 2>&1
echo rc=$?
find . -type q 2>&1
find . '(' -name a 2>&1
find . -name a -o 2>&1
find . -size 1k 2>&1
find . -mtime 1.5 2>&1
find . -perm /4000 2>&1
find . -user no_such_user_x 2>&1
echo rc=$?
find . -newer nonexist 2>&1
echo rc=$?
find -HL dl -type d | sort
for p in -maxdepth -mindepth -xtype -empty -printf -quit -delete -regex -ls -fprint -samefile -inum -newermt -mmin -true -false -not -and -or -execdir -okdir -files0-from -readable -lname -wholename -ipath -fstype; do
	find . $p x 2>&1 | /usr/bin/head -1
done
find -D tree . 2>&1 | /usr/bin/head -1
find -O3 . 2>&1 | /usr/bin/head -1
find -P . 2>&1 | /usr/bin/head -1
cd ..
/bin/rm -rf find_t
