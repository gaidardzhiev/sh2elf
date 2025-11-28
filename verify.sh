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

fhello() {
	./sh2elf scripts/hello.sh -o hello.elf >/dev/null
	CAPTURE=$(./hello.elf)
	EXPECTED="Hello World!"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Hello World" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Hello World" "${R}FAILED${N}";
		return 	8;
	}
}

fpipe() {
	./sh2elf scripts/pipeline.sh -o pipe.elf >/dev/null
	CAPTURE=$(./pipe.elf)
	EXPECTED="20"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Pipeline" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Pipeline" "${R}FAILED${N}";
		return 	16;
	}
}

flogic() {
	./sh2elf scripts/logic.sh -o logic.elf >/dev/null
	CAPTURE=$(./logic.elf)
	EXPECTED=$(cat <<'EOF'
first
after-false
fallback-two
inline
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Logic" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Logic" "${R}FAILED${N}";
		return 32;
	}
}

{ fhello && fpipe && flogic; RETURN="${?}"; } || exit 1

[ "${RETURN}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RETURN}"
