basename /usr/bin/gcc
basename /a/b/c.txt .txt
basename /a/b/
basename //
basename /
basename .txt .txt
basename a.txt txt
basename x/y.c/// .c
P=/tmp/dir.d/file.tar.gz
basename "$P" .gz
basename -- -x.c .c
echo "[$(basename '')]"
basename -a x y 2>&1
echo "rc=$?"
basename a b c 2>&1
echo "rc=$?"
