id > /dev/null && echo "id-rc=0"
/usr/bin/id > /tmp/sh2elf_id; id | /usr/bin/cmp -s - /tmp/sh2elf_id && echo "full-ok"
/usr/bin/id -G > /tmp/sh2elf_id; id -G | /usr/bin/cmp -s - /tmp/sh2elf_id && echo "groups-ok"
/usr/bin/id -Gn > /tmp/sh2elf_id; id -Gn | /usr/bin/cmp -s - /tmp/sh2elf_id && echo "group-names-ok"
/usr/bin/id -un > /tmp/sh2elf_id; id -u -n | /usr/bin/cmp -s - /tmp/sh2elf_id && echo "user-name-ok"
[ "$(id -u)" = "$(/usr/bin/id -u)" ] && [ "$(id -gr)" = "$(/usr/bin/id -gr)" ] && echo "ids-ok"
id root
id -u root
id -un 0
id -g root
id -gn root
id sh2elf_no_such_user 2>&1
echo "rc=$?"
id -n 2>&1
echo "rc=$?"
id -u -g 2>&1
echo "rc=$?"
id -Z 2>&1
echo "rc=$?"
rm -f /tmp/sh2elf_id
