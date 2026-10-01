T=/tmp/sh2elf_chown_full
/bin/rm -rf $T
/bin/mkdir -p $T
cd $T
mkdir -p d/e
printf 'f\n' > f
printf 'g\n' > d/e/g
ln -s f sl
ln -s nowhere dg
ln -s d dl
U=$(id -u)
G=$(id -g)
chown $U d; echo rc=$?
chown -R $U:$G d; echo rc=$?
chgrp $G d f; echo rc=$?
chgrp -R $G d; echo rc=$?
chown -h $U:$G sl dg; echo rc=$?
chgrp -h $G sl dg; echo rc=$?
chown $U:$G sl; echo rc=$?
chown $U dg 2>&1; echo rc=$?
chgrp $G dg 2>&1; echo rc=$?
chown -RH $U dl; echo rc=$?
chown -RL $U:$G dl d; echo rc=$?
chown -RP $U dl; echo rc=$?
chown -RLP $U dl; echo rc=$?
chown -hR $U d; echo rc=$?
chgrp -RHh $G dl; echo rc=$?
chown -- $U f; echo rc=$?
chown $U -- f 2>&1; echo rc=$?
chown $U nonexist 2>&1; echo rc=$?
chown $U nonexist f nonexist2 2>&1; echo rc=$?
chgrp $G nonexist 2>&1; echo rc=$?
mkdir 'sp ace'
chown $U 'sp ace' "q'uote" 2>&1; echo rc=$?
chown 2>&1; echo rc=$?
chown -R 2>&1; echo rc=$?
chown root 2>&1; echo rc=$?
chgrp 2>&1; echo rc=$?
chgrp root 2>&1; echo rc=$?
for o in -k -v -c -f -Rv --from=root --reference=f --dereference --no-dereference --preserve-root --recursive --help --version; do
	chown $o $U f 2>&1; echo rc=$?
done
for o in -v -c -f --reference=f --help; do
	chgrp $o $G f 2>&1; echo rc=$?
done
for s in '' : :root root: root.root root:root:x +0 ' 0' 0x nosuchuser_x nosuchuser_x: root:nosuchgroup_x 4294967295 0:4294967295 'sp ace'; do
	chown "$s" f 2>&1; echo rc=$?
done
for s in '' :root root: +0 4294967296 nosuchgroup_x 'sp ace'; do
	chgrp "$s" f 2>&1; echo rc=$?
done
