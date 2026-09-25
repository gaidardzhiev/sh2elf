#!/bin/sh
{ echo "group_or_1"; } || echo "bad_or"
{ echo "group_and_1"; } && echo "group_and_2"
{ echo "group_pipe"; } | cat
( echo "subshell_or_1" ) || echo "bad_subshell_or"
( echo "subshell_and_1" ) && echo "subshell_and_2"
if true; then echo "if_then_1"; fi || echo "bad_if_or"
if false; then echo "bad_if"; fi || echo "if_or_2"
while false; do echo "bad_while"; done || echo "while_or_2"
for x in 1; do echo "for_x_$x"; done && echo "for_and_2"
