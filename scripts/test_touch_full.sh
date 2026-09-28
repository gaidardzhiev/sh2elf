T=/tmp/sh2elf_touch_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
mkdir d
printf 'x\n' > a
touch -d @1000000000 a; stat -c '%n %X %Y' a
touch -m -d '2001-02-03 04:05:06 UTC' a; stat -c '%n %X %Y' a
touch -a -t 200102030405.06 a; TZ=UTC0 stat -c '%n %Y' a
touch -d '@1000000000.5' b; stat -c '%n %.1X %.1Y' b
touch -r b -d '+1 day' c; stat -c '%n %X %Y' c
touch -r a -m c; stat -c '%n %X %Y' c
touch -d '2020-01-01 00:00 UTC +3 weeks 2 days ago' e; stat -c '%n %Y' e
touch -d 'TZ="UTC" 2010-06-01 12:00' f; stat -c '%n %Y' f
touch -c -d @5 nonexist; echo rc=$?; ls
touch -d @7 -h d; stat -c '%n %Y' d
touch 2>&1; echo rc=$?
touch -k a 2>&1; echo rc=$?
touch -d bogus a 2>&1; echo rc=$?
touch -t 2005 a 2>&1; echo rc=$?
touch -t 200501010101.60 a 2>&1; echo rc=$?
touch -r nonexist a 2>&1; echo rc=$?
touch -r a -t 200501010101 a 2>&1; echo rc=$?
touch --time=bad a 2>&1; echo rc=$?
touch nodir/x 2>&1; echo rc=$?
touch a/ 2>&1; echo rc=$?
touch -d @9 d/ 'sp ace' "q'uote"; stat -c '%n %Y' d 'sp ace' "q'uote"
touch -d @11 - > out; stat -c '%n %Y' out
ls
