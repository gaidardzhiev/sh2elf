#!/bin/sh
fn_return_nonzero() {
	echo "fn_nonzero_start"
	return 42
	echo "should_not_reach"
}

fn_inner() {
	local var="inner_val"
	echo "inner:$var"
}

fn_outer() {
	local var="outer_val"
	echo "outer_before:$var"
	fn_inner
	echo "outer_after:$var"
}

fn_return_nonzero || echo "returned_status_$?"
fn_outer
