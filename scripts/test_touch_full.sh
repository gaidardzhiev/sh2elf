T=/tmp/sh2elf_touch_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
mkdir d
printf 'x\n' > a
touch -d 2001-09-09T01:46:40Z a; stat -c '%n %X %Y' a
touch -m -d '2001-02-03 04:05:06Z' a; stat -c '%n %X %Y' a
touch -a -t 200102030405.06 a; stat -c %x a | cut -c1-19; stat -c '%n %Y' a
touch -d '2001-09-09T01:46:40.5Z' b; stat -c '%n %.1X %.1Y' b
touch -d '2001-09-09T01:46:40,25Z' b2; stat -c '%n %.2X %.2Y' b2
touch -d '2010-06-01T12:00:00' f; date -r f +%Y%m%d%H%M.%S
touch -t 1006011200 g; date -r g +%Y%m%d%H%M.%S
touch -t 201006011200 h; date -r h +%Y%m%d%H%M.%S
touch -t 6901011200 h2; date -r h2 +%Y%m%d%H%M.%S
touch -d 2016-12-31T23:59:60Z i; stat -c '%n %Y' i
touch -r b c; stat -c '%n %X %Y' c
touch -r a -m c; stat -c '%n %X %Y' c
touch -c -d 2001-01-01T00:00:00Z nonexist; echo rc=$?; ls
touch -cm -r a a b; stat -c '%n %Y' a b
touch -- -x; ls -- -x
touch -; ls -- -
touch 2>&1; echo rc=$?
touch -d 2>&1; echo rc=$?
for o in -h -f -k --time=mtime --date=x --reference=a --no-create --help --version; do
	touch $o a 2>&1; echo rc=$?
done
touch -d bogus a 2>&1; echo rc=$?
touch -d @1000000000 a 2>&1; echo rc=$?
touch -d 2001-01-01 a 2>&1; echo rc=$?
touch -d 2001-02-30T00:00:00 a 2>&1; echo rc=$?
touch -t 2005 a 2>&1; echo rc=$?
touch -t 200502290000 a 2>&1; echo rc=$?
touch -r nonexist a 2>&1; echo rc=$?
touch -r a -t 200501010101 a 2>&1; echo rc=$?
touch -r a -d 2001-01-01T00:00:00 a 2>&1; echo rc=$?
touch nodir/x 2>&1; echo rc=$?
touch a/ 2>&1; echo rc=$?
touch -d 1970-01-01T00:00:09Z d/ 'sp ace' "q'uote"; stat -c '%n %Y' d 'sp ace' "q'uote"
ls
