#!/bin/sh
greet() {
	echo "hello $1 from $2 ($# args)"
}
greet alice bob
greet "x y" z
sum() {
	echo $(( $1 + $2 ))
}
sum 3 4
all() {
	echo "all: $@"
}
all a b c
