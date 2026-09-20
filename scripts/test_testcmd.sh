[ "abc" = "abc" ] && echo eq-pass
[ "abc" != "def" ] && echo neq-pass
test -d scripts && echo dir-pass
