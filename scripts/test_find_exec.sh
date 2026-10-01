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
find a.txt -exec echo x{}y {}{} \;
find a.txt -exec ./run.sh {} \;
find a.txt -exec ./nosb {} \;
find a.txt -exec nosuchcmd {} \; 2>&1
find a.txt -exec false \; -o -print
find a.txt -exec false {} +; echo rc=$?
find a.txt -exec sh -c 'exit 3' \; ; echo rc=$?
find a.txt -exec echo + \;
find a.txt d2 -exec echo {} + -exec echo E {} +
find d1 -type f -exec echo F {} \; -o -type d -exec echo D {} \; | sort
find . -exec echo {} {} + 2>&1
find . -exec echo {}x + 2>&1
find . -exec echo 2>&1
find . -exec 2>&1
printf 'y\nn\n' | find a.txt b.txt -ok echo OK {} \; 2>&1
printf 'n\n' | find a.txt -ok echo OK {} \; -o -print 2>&1
find . -ok echo {} + 2>&1
find . -execdir echo {} \; 2>&1
find -files0-from list 2>&1
cd ..
/bin/rm -rf findx_t
