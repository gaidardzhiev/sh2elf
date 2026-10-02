#!/bin/sh
F=/tmp/sh2elf_test_ext
rm -f $F
rm -f $F.l
echo data > $F
[ -f $F ] && echo "is-file"
[ -s $F ] && echo "non-empty"
[ -r $F ] && [ -w $F ] && echo "rw"
[ -x $F ] || echo "not-exec"
chmod 755 $F
[ -x $F ] && echo "exec-now"
[ ! -d $F ] && echo "not-dir"
{ [ -d /tmp ] || [ -f /nonexistent ]; } && echo "or-ok"
/bin/ln -s $F $F.l
[ -L $F.l ] && echo "symlink"
[ -e /nonexistent ] || echo "missing"
[ -z "" ] && [ -n "x" ] && echo "zn"
[ "abc" \< "abd" ] && echo "lt"
[[ abc == a* ]] && echo "glob-match"
[[ foo =~ ^f.o$ ]] && echo "regex-match"
[[ -f $F && -s $F ]] && echo "dbl-and"
[[ 1 -eq 2 || 3 -gt 2 ]] && echo "dbl-or"
[ -t 0 ] < /dev/null || echo "not-tty"
[ $F -ef $F ] && echo "same-file"
[ $F -nt /etc/passwd ] && echo "newer"
[ /etc/passwd -ot $F ] && echo "older"
{ [ 1 -eq 1 ] && [ 2 -eq 3 ]; } || echo "paren-group"
[ -r $F -a -w $F ] 2>/dev/null; echo "and-op=$?"
test x == x 2>/dev/null; echo "dbl-eq=$?"
test 1 -ne 2 && echo "ne-ok"
test 99999999999999999999 -gt 1 && echo "bigint"
test ' 7 ' -eq 007 && echo "blank-int"
test 1 -eq x 2>/dev/null; echo "badint=$?"
test -t x; echo "t-bad=$?"
LC_ALL=C test a \< B || echo "c-bytes"
LC_ALL=en_US.UTF-8 test a \< B && echo "collate"
test ! a = a; echo "neg3=$?"
test a b c d e 2>/dev/null; echo "five=$?"
rm -f $F
rm -f $F.l
