uname -m
uname -s
[ "$(uname -n)" = "$(/usr/bin/uname -n)" ] && echo "node-ok"
[ "$(uname -r)" = "$(/usr/bin/uname -r)" ] && echo "release-ok"
[ "$(uname -a)" = "$(/usr/bin/uname -snrvm)" ] && echo "all-ok"
[ "$(uname -ms)" = "$(/usr/bin/uname -s) $(/usr/bin/uname -m)" ] && echo "order-ok"
uname -p 2>&1
echo "rc=$?"
uname x 2>&1
echo "rc=$?"
