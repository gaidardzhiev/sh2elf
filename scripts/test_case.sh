export X=hello
case $X in
	hi) echo is_hi ;;
	hel*) echo is_hello ;;
	*) echo default ;;
esac
