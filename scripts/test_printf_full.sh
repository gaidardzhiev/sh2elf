#!/bin/sh
printf '%s-%s\n' a b c d
printf '%5d|%-5d|%05d|%x|%X|%o|%#x\n' 42 42 42 255 255 8 255
printf '%.2f %e %g\n' 3.14159 12345.678 0.0001
printf '%c%c\n' hello world
printf '%10s|%-10s|%.3s\n' right left truncate
printf 'oct\101\102é\n'
printf '%b\n' 'tab\there' 'nl\nx'
printf '%d\n' "'A"
printf '%s\n'
printf 'stop\c after\n'
printf '%b|' 'stop\c' after
echo
printf '%*d|%-*s|\n' 6 7 4 ab
printf 'no args %%\n'
printf '[%3c]\n' z
printf '%2$s %1$s\n' world hello
printf '%2$s=%1$d;' 1 a 2 b
echo
printf '%1$s%1$s\n' x y
printf '%1$*2$d|\n' 7 4
printf '%b\n' '\0101\0102' '\101' '\x41' '\e'
printf '\x41\e\n'
printf '%d %u %x\n' 0x10 010 -1
printf '%+d % d %+.3d\n' 5 5 5
printf '%d\n' 12x 2>&1
echo rc=$?
printf '%d\n' abc 2>&1
echo rc=$?
printf '%d\n' 99999999999999999999 2>&1
echo rc=$?
printf 'a%qb\n' x 2>&1
echo rc=$?
printf '%a\n' 1 2>&1
echo rc=$?
printf -- '%s\n' dash
printf '%s\n' -v
printf 2>&1
echo rc=$?
printf '%s %s %s\n' 1 2 3 4
printf '%.0f %.1f %5.2e\n' 2.5 0.05 123.456
printf '%5s|%-3c|\n' '' a
