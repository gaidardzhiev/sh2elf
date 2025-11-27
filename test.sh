#!/bin/sh

G='\033[0;32m'
R='\033[0;31m'
N='\033[0m'

ARCH=$(uname -m)

[ ! "${ARCH}" = "x86_64" ] && { 
	printf "unsupported architecture %s...\n" "${ARCH}";
	exit 1;
}

[ ! -f sh2elf ] && { 
	make;
	printf "\n";
}

fprint() {
	 printf "[%s] Test: %-20s Result: %b\n" "$(date '+%Y-%m-%d %H:%M:%S')" "${1}" "${2}"
}

fcheck() {
	./sh2elf scripts/pipeline.sh -o pipe.elf >/dev/null
	if command -v strace >/dev/null 2>&1; then
		strace ./pipe.elf
		printf "\n\n"
	fi
	CAPTURE=$(./pipe.elf)
	EXPECTED="20"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Pipeline Test" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Pipeline Test" "${R}FAILED${N}";
		return 	32;
	}
}

fcheck_logic() {
	./sh2elf scripts/logic.sh -o logic.elf >/dev/null
	CAPTURE=$(./logic.elf)
	STATUS="${?}"
	EXPECTED=$(cat <<'EOF'
first
after-false
fallback-two
inline
EOF
)
	{ [ "${CAPTURE}" = "${EXPECTED}" ] && [ "${STATUS}" -eq 0 ]; } && {
		fprint "Logic Test" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Logic Test" "${R}FAILED${N}";
		printf "captured output:\n%s\nexpected output:\n%s\nstatus=%s\n" "${CAPTURE}" "${EXPECTED}" "${STATUS}"
		return 64;
	}
}

FAIL=0
fcheck || FAIL=1
fcheck_logic || FAIL=1

exit "${FAIL}"
