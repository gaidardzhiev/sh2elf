/bin/rm -rf findx_t
/bin/mkdir -p findx_t/d1/s1 findx_t/d2
cd findx_t
/usr/bin/touch a.txt b.txt d1/c.txt d1/s1/d.txt d2/e.txt
printf '#!/bin/sh\necho SCRIPT "$@"\n' > run.sh
/bin/chmod 755 run.sh
printf 'echo NOSHEBANG "$@"\n' > nosb
/bin/chmod 755 nosb
find . -name '*.txt' -exec echo X {} \; | sort
find . -name '*.txt' -exec echo {} + | /usr/bin/tr ' ' '\n' | sort
find d1 -name '*.txt' -execdir echo [{}] \; | sort
find d1 -name '*.txt' -execdir pwd \; | /usr/bin/sed 's|.*/findx_t|T|' | sort
find a.txt -exec echo x{}y {}{} \;
find a.txt -exec ./run.sh {} \;
find a.txt -exec ./nosb {} \;
find a.txt -exec nosuchcmd {} \; 2>&1
find a.txt -exec false \; -o -print
find a.txt -exec false {} +; echo rc=$?
find a.txt -exec sh -c 'exit 3' \; ; echo rc=$?
find . -exec echo {} {} + 2>&1
find . -execdir {} \; 2>&1
find . -exec echo {}x + 2>&1
find . -exec echo 2>&1
printf 'y\nn\n' | find a.txt b.txt -ok echo OK {} \; 2>&1
/usr/bin/printf 'a.txt\0d1\0' > list
find -files0-from list -maxdepth 0
/usr/bin/printf 'a.txt\0\0b.txt' > list2
find -files0-from list2 2>&1
find . -files0-from list 2>&1
find d2 -name e.txt -exec echo {} + -quit
cd ..
/bin/rm -rf findx_t
