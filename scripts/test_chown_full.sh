T=/tmp/sh2elf_chown_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
mkdir -p d/e
printf 'f\n' > f
printf 'g\n' > d/e/g
ln -s f sl
ln -s nowhere dg
chown -c --reference=f d; echo rc=$?
chown -Rc --reference=f d; echo rc=$?
chgrp -c --reference=f d f; echo rc=$?
chgrp -Rc --reference=f d; echo rc=$?
chown -hc --reference=f sl dg; echo rc=$?
chown -c --reference=sl f; echo rc=$?
chown -v '' f; echo rc=$?
chown -v : f d; echo rc=$?
chown -Rv : d; echo rc=$?
chgrp -v '' f; echo rc=$?
chown -v --from=4294967294 : f; echo rc=$?
chown -v --from=:4294967294 : f; echo rc=$?
chown -Rv --from=4294967294 : d; echo rc=$?
chown -hv : sl dg; echo rc=$?
chown 2>&1; echo rc=$?
chown 0 2>&1; echo rc=$?
chgrp 2>&1; echo rc=$?
chgrp 0 2>&1; echo rc=$?
chown -k 0 f 2>&1; echo rc=$?
chown -v nosuchuser_x f 2>&1; echo rc=$?
chown -v nosuchuser_x: f 2>&1; echo rc=$?
chown -v :nosuchgroup_x f 2>&1; echo rc=$?
chown -v nosuch_x.nosuch_y f 2>&1; echo rc=$?
chown -v 4294967295 f 2>&1; echo rc=$?
chown -v +x f 2>&1; echo rc=$?
chgrp -v 4294967296 f 2>&1; echo rc=$?
chgrp -v nosuchgroup_x f 2>&1; echo rc=$?
chown --from=nosuchuser_x : f 2>&1; echo rc=$?
chown --from=: --from=nosuchuser_x -k : f 2>&1; echo rc=$?
chown : nonexist 2>&1; echo rc=$?
chown -f : nonexist; echo rc=$?
chown -v : nonexist 2>&1; echo rc=$?
chown : dg 2>&1; echo rc=$?
chown -R --dereference -P : d 2>&1; echo rc=$?
chown --reference=nonexist f 2>&1; echo rc=$?
chgrp --reference=nonexist f 2>&1; echo rc=$?
chown -R --preserve-root : / 2>&1; echo rc=$?
chgrp -R --preserve-root '' // 2>&1; echo rc=$?
chown -v : 'sp ace' 2>&1; echo rc=$?
