#!/bin/sh
echo "err_append_1" 2>> /tmp/test_err_append.log
echo "err_append_2" 2>> /tmp/test_err_append.log
cat /tmp/test_err_append.log
rm -f /tmp/test_err_append.log

echo "stdout_and_stderr" > /tmp/test_dup.log 2>&1
cat /tmp/test_dup.log
rm -f /tmp/test_dup.log

echo "close_stderr" 2>&-
