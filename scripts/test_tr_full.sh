#!/bin/sh
echo 'Hello World 123' | tr a-z A-Z
echo 'hello' | tr -d l
echo 'aabbccdd' | tr -s a-c
echo 'hello world' | tr -s 'lo' 'xy'
echo 'abc123' | tr -c a-z X
echo
echo 'abc123' | tr -cd 0-9
echo
echo 'a b  c' | tr -s ' ' '\n'
echo 'abc' | tr abc x
echo 'abcdef' | tr 'a-f' 'xy'
echo 'abc' | tr '[:lower:]' '[:upper:]'
echo 'a1 b2' | tr -d '[:digit:][:space:]'
echo
echo 'aaa' | tr 'a' '[x*]'
echo 'abcd' | tr 'abcd' '[x*2]yz'
echo 'tab	x' | tr '\t' '_'
echo 'abc' | tr '\141' 'Z'
echo 'a=b' | tr '[=a=]' 'x'
echo 'hello' | tr -s l
echo 'ABC' | tr '[:upper:]' 'a-c'
echo 'abc' | tr '[:upper:]' '[:lower:]'
echo 'a-b' | tr 'a-' 'xy'
echo 'a\b' | tr '\\' 'Q'
echo aaa | tr aa xy
echo 'hello, world!! foo' | tr -cs 'a-z' '\n'
echo 'aabbcc' | tr -s ab xx
echo 'aabbccaa' | tr -ds a b
echo 'aAbB' | tr -s '[:upper:]' '[:lower:]'
echo 'abc' | tr -d '[:alpha:]'
/usr/bin/printf 'x\x80\xffy\n' | tr '\200-\377' '_'
printf 'a-b\n' | tr a-b- 1-3
echo abc | tr 'a-' 'x'
echo 'a-z' | tr -- '-a' '_x'
echo abcd | tr -t 'abcd' 'xy'
echo 'a*b' | tr '*' x
echo 'a[b' | tr '[' x
echo 'a]b' | tr ']' x
echo 'abc' | tr '[:alpha:]' '[x*]'
echo 'aBc' | tr '[:lower:][:upper:]' '[:upper:][:lower:]'
echo x | tr 2>&1
echo x | tr a 2>&1
echo x | tr -d 2>&1
echo x | tr -d a b 2>&1
echo x | tr a b c 2>&1
echo abc | tr 'c-a' x 2>&1
echo abc | tr a-z '[:digit:]' 2>&1
echo abc | tr '[a*]' x 2>&1
echo abc | tr '[:foo:]' x 2>&1
echo abc | tr a '' 2>&1
echo abc | tr '[:lower:]x' '[:upper:]' 2>&1
echo abc | tr -ds a 2>&1
echo abc | tr a '[:upper:]' 2>&1
echo abc | tr a-c '[=b=]' 2>&1
echo abcABC123 | tr '[:upper:]' '[:lower:]x'
echo abcABC123 | tr abc '[x*1]y'
echo abcABC123 | tr -c ab xy
echo
echo 'hello world' | tr '[:space:]' '\n'
echo 'Mixed CASE 99' | tr '[:upper:][:lower:]' '[:lower:][:upper:]'
echo 'x   y' | tr -s '[:blank:]'
echo 'a:b;c' | tr '[:punct:]' ' '
echo 'deadBEEF' | tr -d '[:xdigit:]'
echo
echo abc | tr -s abc
seq 200000 | tr 0-9 a-j | cksum
seq 200000 | tr -d 0 | cksum
seq 200000 | tr -s '1' | cksum
seq 200000 | tr '\n' ' ' | cksum
