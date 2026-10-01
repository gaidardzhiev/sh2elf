/bin/rm -rf findr_t
/bin/mkdir findr_t
cd findr_t
/usr/bin/touch abc abd a1 a22 Abc 'x y' file.txt file.tar.gz aaa abab 'éclair' README '*star' 'q?m' '[br]' .hid
find . -name 'a*' | sort
find . -name 'a?' | sort
find . -name '[a-c]b*' | sort
find . -name '[!a]*' | sort
find . -name '[[:upper:]]*' | sort
find . -name '[[:digit:]]*' | sort
find . -name '*[[:space:]]*'
find . -name '\*star'
find . -name '*\?*'
find . -name '[[]br]'
find . -name '*.*' | sort
find . -name '.*' | sort
find . -name '*' ! -name '*a*' | sort
find . -iname 'abc' | sort
find . -iname 'ÉCLAIR'
find . -iname '[A]B[C]' | sort
find . -path './a*' | sort
find . -path '*/*.gz'
find . -path '.' 
find . -path '*b' | sort
for p in -regex -iregex -regextype -wholename -iwholename -ipath -lname -ilname; do
	find . $p x 2>&1 | /usr/bin/head -1
done
cd ..
/bin/rm -rf findr_t
