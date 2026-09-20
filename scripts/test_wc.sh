echo line1 > wc_test.txt
echo line2 >> wc_test.txt
wc -l wc_test.txt
unlink wc_test.txt
