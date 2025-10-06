#!/bin/sh

G='\033[0;32m'
R='\033[0;31m'
N='\033[0m'

ARCH=$(uname -m)

[ ! "${ARCH}" = "x86_64" ] && { printf "unsupported architecture %s...\n" "${ARCH}"; exit 1; }

[ ! -f sh2elf ] && { make; printf "\n"; }

[ ! -f pipe.elf ] && { ./sh2elf scripts/pipeline.sh -o pipe.elf; printf "\n"; }

fprint() {
	 printf "[%s] Test: %-20s Result: %b\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${1}" "${2}"
}

fcheck() {
	strace ./pipe.elf
	printf "\n\n"
	CAPTURE=$(./pipe.elf)
	EXPECTED="23"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Pipeline Test" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Pipeline Test" "${R}FAILED${N}";
		return 	32;
	}
}

{ fcheck; RETURN="${?}"; } || exit 1

[ "${RETURN}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RETURN}"
