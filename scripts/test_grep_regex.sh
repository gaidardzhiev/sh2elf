#!/bin/sh
D=/tmp/sh2elf_grepr
/bin/rm -rf $D
mkdir -p $D
cd $D
printf 'abc\naXc\nab\nabab\naaaa\nhello world\nfoo_bar baz\n12:30\né café\nÉCOLE\nk K\nss ß\n' > t
grep 'a.c' t
grep 'a*b' t
grep 'a\{2,\}' t
grep -E 'a{2,}' t
grep -E '(ab)+$' t
grep '\(ab\)\1' t
grep -E '(a)\1\1' t
grep '[[:upper:]]' t
grep '[[:digit:]]\{2\}:' t
grep '[^a-z ]' t
grep '\<b' t
grep 'o\>' t
grep '\bbar' t
grep 'o\Bo' t
grep '\w\+_\w\+' t
grep -o '\s[a-z]*' t
grep '^a' t
grep 'c$' t
grep -E '^(hello|foo)' t
grep -i 'école' t
grep -i 'CAFÉ' t
grep -o '[[:alpha:]]*é' t
grep '[[=e=]]' t
grep -c '.' t
grep -E 'a|' t | head -2
grep -E '*abc' t
grep 'a\{1' t; echo rc=$?
grep '\(' t; echo rc=$?
grep '[[:foo:]]' t; echo rc=$?
grep '[:space:]' t; echo rc=$?
grep -E 'x{2,1}' t; echo rc=$?
grep '\1' t; echo rc=$?
grep -w -o 'a*' t
grep -x -o 'ab' t
