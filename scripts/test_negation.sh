#!/bin/sh
! false && echo "neg-false-ok"
! true || echo "neg-true-ok"
if ! [ 1 -eq 2 ]; then echo "if-neg-ok"; fi
! false
echo "status $?"
! true
echo "status $?"
