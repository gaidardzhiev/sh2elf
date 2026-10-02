#!/bin/sh
expr 1 + 2 \* 3
expr \( 1 + 2 \) \* 3
expr -7 / 2
expr -7 % 3
expr 99999999999999999999 + 1
expr 123456789012345678901234567890 / 9876543210
expr 10 \< 9
expr 10 \< 9a
expr abc = abc
expr 1 = 01
expr a \& ''
expr '' \| fallback
expr 0 \| 0
echo "rc=$?"
expr abc : 'a\(.*\)'
expr abc : 'x\(.*\)'
echo "rc=$?"
expr hello : 'hel'
expr héllo : '.*'
expr /usr/lib/file : '.*/\(.*\)'
expr //file : '.*/\(.*\)'
expr abcabc : '\(abc\)\1'
expr X12 : 'X\(.*\)' + 1
expr -- -5 + 3
x=1
x=$(expr $x + 1)
echo "x=$x"
expr 1 / 0 2>&1
echo "rc=$?"
expr a + 1 2>&1
echo "rc=$?"
expr 1 \| 1 / 0
expr 2>&1
echo "rc=$?"
expr \( 1 2>&1
echo "rc=$?"
expr a : '\(' 2>&1
echo "rc=$?"
expr length abc 2>&1
echo "rc=$?"
expr substr abc 1 2 2>&1
echo "rc=$?"
expr a == a 2>&1
echo "rc=$?"
LC_ALL=C expr a \< B
LC_ALL=en_US.UTF-8 expr a \< B
