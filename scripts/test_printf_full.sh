#!/bin/sh
printf '%s-%s\n' a b c d
printf '%5d|%-5d|%05d|%x|%X|%o|%#x\n' 42 42 42 255 255 8 255
printf '%.2f %e %g\n' 3.14159 12345.678 0.0001
printf '%c%c\n' hello world
printf '%10s|%-10s|%.3s\n' right left truncate
printf 'oct\101\x42é\n'
printf '%b\n' 'tab\there' 'nl\nx'
printf '%d\n' "'A"
printf '%s\n'
printf 'stop\c after'
echo
printf '%*d|%-*s|\n' 6 7 4 ab
printf 'no args %%\n'
printf '[%3c]\n' z
