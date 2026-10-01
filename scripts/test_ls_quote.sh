/bin/rm -rf ls_q
/bin/mkdir ls_q
cd ls_q
/usr/bin/touch plain 'sp ace' "it's" 'dq"x' 'back\sl' 'st*r' 'q?m' 'tab	x' $'nl\nx' 'éte' 'a:b' '#h' 'x=y'
ls
ls -q
ls -1q
ls -Aq
ls -m -q
COLUMNS=50 ls -C -q
COLUMNS=50 ls -x -q
COLUMNS=40 ls -m -q
ls -Fq
for o in -Q -b -N --quoting-style=shell --quoting-style=c --show-control-chars --hide-control-chars --literal --escape --quote-name; do
	ls $o 2>&1
	echo "rc=$?"
done
cd ..
/bin/rm -rf ls_q
