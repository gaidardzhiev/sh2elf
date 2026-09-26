#!/bin/sh
echo $'tab\there'
echo $'line1\nline2'
echo $'quote\'s'
echo $'\x41\x42\x43'
echo $'\101\102'
H=~
[ "$H" = "$HOME" ] && echo "tilde-home"
T=~/sub
[ "$T" = "$HOME/sub" ] && echo "tilde-path"
[ ~root = /root ] && echo "tilde-user"
echo '~'
