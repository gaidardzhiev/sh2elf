#!/bin/sh
F=/tmp/sh2elf_test_ext
rm -f $F
rm -f $F.l
echo data > $F
[ -f $F ] && echo "is-file"
[ -s $F ] && echo "non-empty"
[ -r $F -a -w $F ] && echo "rw"
[ -x $F ] || echo "not-exec"
chmod 755 $F
[ -x $F ] && echo "exec-now"
[ ! -d $F ] && echo "not-dir"
[ -d /tmp -o -f /nonexistent ] && echo "or-ok"
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
[ \( 1 -eq 1 \) -a \( 2 -eq 3 \) ] || echo "paren-group"
rm -f $F
rm -f $F.l
