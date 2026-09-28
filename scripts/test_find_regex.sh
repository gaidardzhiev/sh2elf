/bin/rm -rf findr_t
/bin/mkdir findr_t
cd findr_t
/usr/bin/touch abc abd a1 a22 Abc 'x y' file.txt file.tar.gz aaa abab 'éclair' README
find . -regex '\./a.*' | sort
find . -regex '\./a[0-9]+' | sort
find . -regex '\./a[0-9]\+' | sort
find . -regextype posix-extended -regex '\./a[0-9]+' | sort
find . -regextype posix-extended -regex '\./(ab)+' | sort
find . -regextype posix-basic -regex '\./\(a\)\1*' | sort
find . -regextype posix-extended -regex '.*/([a-z])\1.*' | sort
find . -regextype egrep -regex '.*\.(txt|gz)' | sort
find . -regextype awk -regex '.*[[:space:]].*'
find . -regextype sed -regex '.*/[[:upper:]]\{2,\}.*'
find . -iregex '.*/abc' | sort
find . -regex '.*\bfile\b.*' | sort
find . -regex '.*[^a-z0-9./ ].*'
find . -regextype posix-extended -regex '[' 2>&1
find . -regextype nosuch -regex x 2>&1 | /usr/bin/head -2
cd ..
/bin/rm -rf findr_t
