echo hello > file_to_remove.txt
unlink file_to_remove.txt
test -e file_to_remove.txt || echo unlink-passed
