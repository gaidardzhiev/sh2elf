/bin/rm -rf ls_q
/bin/mkdir ls_q
cd ls_q
/usr/bin/touch plain 'sp ace' "it's" 'dq"x' 'back\sl' 'st*r' 'q?m' 'tab	x' $'nl\nx' 'éte' 'a:b' '#h' 'x=y'
ls
ls -Q
ls -b
ls -N
ls -q
ls --quoting-style=shell
ls --quoting-style=shell-always
ls --quoting-style=shell-escape
ls --quoting-style=shell-escape-always
ls --quoting-style=c
ls --quoting-style=c-maybe
ls --quoting-style=escape
ls --quoting-style=literal
ls --quoting-style=locale
ls --quoting-style=clocale
ls -C -w 50 --quoting-style=shell-escape
ls -x -w 50 -q
ls -m -w 40 -b
cd ..
/bin/rm -rf ls_q
