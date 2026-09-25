#!/bin/sh
FOO="${UNSET_VAR:=default_val}"
echo "assign_foo:$FOO"
ALT="${FOO:+alt_val}"
echo "alt_val:$ALT"
EMPTY_ALT="${UNSET_ALT:+not_shown}"
echo "empty_alt:$EMPTY_ALT"
echo "star_quoted:$*"
echo "at_quoted:$@"
