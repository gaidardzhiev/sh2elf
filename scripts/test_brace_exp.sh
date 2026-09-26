#!/bin/sh
echo {a,b,c}
echo pre{1,2,3}post
echo {1..5}
echo {5..1}
echo {a..e}
echo {1..10..3}
echo {01..03}
echo x{a,b{1,2},c}y
echo {x,y}{1,2}
for f in file{A,B}.txt; do echo "$f"; done
echo "{not,expanded}"
echo {single}
