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
find . -xtype l
find -L . -type l
find . -maxdepth 1 -type f -size +1k
find . -size -2 -type f | sort
find . -empty | sort
find . -perm -u+x -type f
find . -perm 600
find . -path './d1/*' -prune -o -type f -print | sort
find d1 -depth
find d1 -mindepth 2 -maxdepth 2
find . -newer a.txt | sort
find . ! -type d -name '[a-z]*' | sort
find . \( -name 'a*' -o -name 'b*' \) -type f | sort
find d1 -printf '%p|%f|%h|%P|%d|%y|%s|%m|%M\n'
find a.txt -printf '%t|%TY-%Tm-%Td %TH:%TM:%TS|%T@|%AF|%A+\n'
find big.bin -printf '%10s|%-8f|%.3p|%k|%b|%S\n'
find . -maxdepth 1 -name 'sp*' -printf '[%p]\n'
find dl lnk dang -printf '%p -> %l %Y\n'
find d1 -name f1 -print0 | /usr/bin/od -c | /usr/bin/head -2
find d1 -quit -print
find nonexist 2>&1
find . -name 2>&1
find . -badpred 2>&1
find . -type q 2>&1
find -D tree . -maxdepth 0 -name x -o -print 2>&1
find -D search d2 2>&1 | sort
find -O3 -D opt d1 -maxdepth 0 -type f -name x -size +1 2>&1
find . -maxdepth 1 -name 'x~' -delete
find . -maxdepth 1 -name 'x~'
cd ..
/bin/rm -rf find_t
