#!/bin/sh
#Copyright (C) 2026 Ivan Gaydardzhiev
#Licensed under the GPL-3.0-only

flatex() {
	printf "do you want to build the LaTeX document form source? (y/n)\n"
	read X
	case "${X}" in
		[y]*)
			printf "building LaTeX from source...\nplease choose pdflatex or xelatex:\n"
			while :; do
				read Y
				case "${Y}" in
					xelatex)
						xelatex "${1}" && xelatex "${1}" || return 8
						cp "${1%.tex}.pdf" /home/tower/Downloads || return 16
						break
						;;
					pdflatex)
						pdflatex "${1}" && pdflatex "${1}" || return 32
						cp "${1%.tex}.pdf" /home/tower/Downloads || return 64
						break
						;;
					*)
						printf "invalid response...\nchoose: xelatex/pdflatex\n"
						;;
				esac
			done
			;;
		[n]*)
			printf "you chose NOT to build LaTeX from source...\n"
			;;
		*)
			printf "invalid response...\n"
			printf "(yes/no)\n"
			;;
	esac
}

{ flatex; RET="${?}"; } || exit 1

[ "${RET}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RET}"
