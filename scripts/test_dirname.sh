dirname /usr/bin/gcc
dirname /a/b/c.txt
dirname a
dirname a/
dirname /a
dirname //a
dirname a//b//
dirname ///
dirname ''
P=/tmp/dir.d/file.tar.gz
dirname "$P"
dirname -- -x/y
dirname a b 2>&1
echo "rc=$?"
