#!/bin/sh

mkdir -p /tmp/sh2elf_huge
cd /tmp/sh2elf_huge

export MAIN_VAR="sh2elf_test_value"
echo "Starting huge test: $MAIN_VAR" > test_out.txt
pwd >> test_out.txt
true && echo "TRUE_PASS" >> test_out.txt
false || echo "FALSE_PASS" >> test_out.txt

mkdir -p sub1/sub2
touch sub1/file1.txt
touch sub1/sub2/file2.txt
chmod 755 sub1/file1.txt
cp sub1/file1.txt sub1/file1_copy.txt
mv sub1/file1_copy.txt sub1/file1_moved.txt
ls sub1 >> test_out.txt
dirname sub1/file1.txt >> test_out.txt
basename sub1/file1.txt >> test_out.txt

cat test_out.txt | grep -v "FALSE" | tr 'a-z' 'A-Z' | sort | uniq | head -n 10 | tail -n 5 > filtered.txt
wc -l filtered.txt >> test_out.txt
wc -w filtered.txt >> test_out.txt
wc -c filtered.txt >> test_out.txt

STR="archive_data.tar.gz"
echo "LEN=${#STR}" >> test_out.txt
echo "PREFIX_STRIP=${STR#archive_}" >> test_out.txt
echo "PREFIX_LONG=${STR##*_}" >> test_out.txt
echo "SUFFIX_STRIP=${STR%.gz}" >> test_out.txt
echo "SUFFIX_LONG=${STR%%.*}" >> test_out.txt
echo "REPLACE_FIRST=${STR/data/info}" >> test_out.txt
echo "REPLACE_ALL=${STR//a/X}" >> test_out.txt
echo "DEFAULT_VAL=${UNSET_VAR:-default_str}" >> test_out.txt

A=15
B=4
SUM=$(( A + B ))
DIFF=$(( A - B ))
MUL=$(( A * B ))
DIV=$(( A / B ))
MOD=$(( A % B ))
echo "ARITH=$SUM $DIFF $MUL $DIV $MOD" >> test_out.txt
expr $A + $B >> test_out.txt

if [ "$A" -gt "$B" ]; then
    echo "IF_GT_PASS" >> test_out.txt
elif [ "$A" -eq "$B" ]; then
    echo "IF_EQ_FAIL" >> test_out.txt
else
    echo "IF_ELSE_FAIL" >> test_out.txt
fi

I=0
while [ $I -lt 3 ]; do
    echo "WHILE_$I" >> test_out.txt
    I=$(( I + 1 ))
done

for ITEM in alpha beta gamma; do
    echo "FOR_$ITEM" >> test_out.txt
done

J=3
until [ $J -eq 0 ]; do
    echo "UNTIL_$J" >> test_out.txt
    J=$(( J - 1 ))
done

VAL="pattern_test"
case "$VAL" in
    pattern_*)
        echo "CASE_PASS" >> test_out.txt
        ;;
    *)
        echo "CASE_FAIL" >> test_out.txt
        ;;
esac

my_func() {
    local LOCAL_VAR="func_val"
    echo "FUNC_$LOCAL_VAR" >> test_out.txt
    return 0
}
my_func

(
    SUB_VAR="subshell_val"
    echo "SUBSHELL_$SUB_VAR" >> test_out.txt
)

{
    echo "GROUP_PASS" >> test_out.txt
}

DATE_OUT=$(uname)
echo "UNAME=$DATE_OUT" >> test_out.txt

cat << EOF >> test_out.txt
HEREDOC_LINE_1
HEREDOC_LINE_2
EOF

echo "apple:red:1" > data.csv
echo "banana:yellow:2" >> data.csv
cat data.csv | cut -d: -f1,2 | sed 's/red/crimson/' | awk '{print $1}' | tee csv_processed.txt >> test_out.txt
find sub1 -name "*.txt" | xargs -n 1 basename >> test_out.txt

echo "compress me" > compress.txt
gzip compress.txt
gunzip compress.txt.gz
tar -cf arch.tar compress.txt
tar -tf arch.tar >> test_out.txt

getopts "a:" OPT_VAR -a test_opt
echo "GETOPTS_VAR=$OPT_VAR" >> test_out.txt
eval "echo EVAL_OUTPUT" >> test_out.txt

SHIFT_VAR="dummy"
shift
unset SHIFT_VAR

whoami > /dev/null
id > /dev/null
env > /dev/null
ps > /dev/null
time

cd /tmp
rm -rf /tmp/sh2elf_huge

echo "HUGE_TEST_COMPLETE"
