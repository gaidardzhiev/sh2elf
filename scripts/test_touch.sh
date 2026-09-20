touch touch_test.txt
test -e touch_test.txt && echo touch-passed
unlink touch_test.txt
