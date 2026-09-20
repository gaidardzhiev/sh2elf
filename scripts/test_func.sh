trap 'echo trapped' EXIT
myfunc() {
	echo in_func
}
myfunc
