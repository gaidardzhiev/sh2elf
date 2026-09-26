#!/bin/sh
for v in apple banana cherry kiwi; do
	case "$v" in
		apple|banana) echo "$v: common" ;;
		(cherry) echo "$v: paren" ;;
		*) echo "$v: other" ;;
	esac
done
