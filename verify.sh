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
	./sh2elf scripts/hello.sh -o hello.elf >/dev/null 2>&1
	CAPTURE=$(./hello.elf 2>/dev/null)
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
	./sh2elf scripts/pipeline.sh -o pipe.elf >/dev/null 2>&1
	CAPTURE=$(./pipe.elf 2>/dev/null)
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
	./sh2elf scripts/logic.sh -o logic.elf >/dev/null 2>&1
	CAPTURE=$(./logic.elf 2>/dev/null)
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

ftruefalse() {
	./sh2elf scripts/test_truefalse.sh -o tf.elf >/dev/null 2>&1
	CAPTURE=$(./tf.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
pass-true
pass-false
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "True / False" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "True / False" "${R}FAILED${N}";
		return 64;
	}
}

fpwd() {
	./sh2elf scripts/test_pwd.sh -o pwd.elf >/dev/null 2>&1
	CAPTURE=$(./pwd.elf 2>/dev/null)
	EXPECTED=$(pwd)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "PWD" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "PWD" "${R}FAILED${N}";
		return 128;
	}
}

fstderr() {
	./sh2elf scripts/test_stderr.sh -o err.elf >/dev/null 2>&1
	CAPTURE=$(./err.elf 2>/dev/null)
	EXPECTED="cat: non_existent_file_xyz: No such file or directory"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Stderr Redir" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Stderr Redir" "${R}FAILED${N}";
		return 256;
	}
}

fmkdir() {
	./sh2elf scripts/test_mkdir.sh -o mkdir.elf >/dev/null 2>&1
	CAPTURE=$(./mkdir.elf 2>/dev/null)
	EXPECTED="dir-created"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Mkdir" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Mkdir" "${R}FAILED${N}";
		return 512;
	}
}

frmdir() {
	./sh2elf scripts/test_rmdir.sh -o rmdir.elf >/dev/null 2>&1
	CAPTURE=$(./rmdir.elf 2>/dev/null)
	EXPECTED="rmdir-passed"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Rmdir" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Rmdir" "${R}FAILED${N}";
		return 1024;
	}
}

funlink() {
	./sh2elf scripts/test_unlink.sh -o unlink.elf >/dev/null 2>&1
	CAPTURE=$(./unlink.elf 2>/dev/null)
	EXPECTED="unlink-passed"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Unlink" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Unlink" "${R}FAILED${N}";
		return 2048;
	}
}

fsleep() {
	./sh2elf scripts/test_sleep.sh -o sleep.elf >/dev/null 2>&1
	CAPTURE=$(./sleep.elf 2>/dev/null)
	EXPECTED="sleep-done"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Sleep" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sleep" "${R}FAILED${N}";
		return 4096;
	}
}

ftestcmd() {
	./sh2elf scripts/test_testcmd.sh -o testcmd.elf >/dev/null 2>&1
	CAPTURE=$(./testcmd.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
eq-pass
neq-pass
dir-pass
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Test Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Test Cmd" "${R}FAILED${N}";
		return 8192;
	}
}

fexport() {
	./sh2elf scripts/test_export.sh -o export.elf >/dev/null 2>&1
	CAPTURE=$(./export.elf 2>/dev/null)
	EXPECTED="pass-export"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Export" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Export" "${R}FAILED${N}";
		return 16384;
	}
}

fcat() {
	./sh2elf scripts/test_cat.sh -o cat.elf >/dev/null 2>&1
	CAPTURE=$(./cat.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
cat-line-1
cat-line-2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cat" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cat" "${R}FAILED${N}";
		return 32768;
	}
}

fhead() {
	./sh2elf scripts/test_head.sh -o head.elf >/dev/null 2>&1
	CAPTURE=$(./head.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
line1
line2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Head" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Head" "${R}FAILED${N}";
		return 65536;
	}
}

fwc() {
	./sh2elf scripts/test_wc.sh -o wc.elf >/dev/null 2>&1
	CAPTURE=$(./wc.elf 2>/dev/null)
	EXPECTED="2 wc_test.txt"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Wc" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Wc" "${R}FAILED${N}";
		return 131072;
	}
}

fkill() {
	./sh2elf scripts/test_kill.sh -o kill.elf >/dev/null 2>&1
	CAPTURE=$(./kill.elf 2>/dev/null)
	EXPECTED="kill-passed"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Kill" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Kill" "${R}FAILED${N}";
		return 262144;
	}
}

ftouch() {
	./sh2elf scripts/test_touch.sh -o touch.elf >/dev/null 2>&1
	CAPTURE=$(./touch.elf 2>/dev/null)
	EXPECTED="touch-passed"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Touch" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Touch" "${R}FAILED${N}";
		return 524288;
	}
}

fchmod() {
	./sh2elf scripts/test_chmod.sh -o chmod.elf >/dev/null 2>&1
	CAPTURE=$(./chmod.elf 2>/dev/null)
	EXPECTED="chmod-passed"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Chmod" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Chmod" "${R}FAILED${N}";
		return 1048576;
	}
}

fbasename() {
	./sh2elf scripts/test_basename.sh -o base.elf >/dev/null 2>&1
	CAPTURE=$(./base.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
gcc
c
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Basename" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Basename" "${R}FAILED${N}";
		return 2097152;
	}
}

fvars() {
	./sh2elf scripts/test_vars.sh -o vars.elf >/dev/null 2>&1
	CAPTURE=$(./vars.elf 2>/dev/null)
	EXPECTED="hello_var"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Variables" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Variables" "${R}FAILED${N}";
		return 4194304;
	}
}

fdirname() {
	./sh2elf scripts/test_dirname.sh -o dirname.elf >/dev/null 2>&1
	CAPTURE=$(./dirname.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
/usr/bin
/a/b
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Dirname" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Dirname" "${R}FAILED${N}";
		return 8388608;
	}
}

fprintf() {
	./sh2elf scripts/test_printf.sh -o printf.elf >/dev/null 2>&1
	CAPTURE=$(./printf.elf 2>/dev/null)
	EXPECTED="Hello World!"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Printf" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Printf" "${R}FAILED${N}";
		return 16777216;
	}
}

fsubshell() {
	./sh2elf scripts/test_subshell.sh -o subshell.elf >/dev/null 2>&1
	CAPTURE=$(./subshell.elf 2>/dev/null)
	EXPECTED="subshell-pass"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Subshell" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Subshell" "${R}FAILED${N}";
		return 33554432;
	}
}

fgroup() {
	./sh2elf scripts/test_group.sh -o group.elf >/dev/null 2>&1
	CAPTURE=$(./group.elf 2>/dev/null)
	EXPECTED="group-pass"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Group" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Group" "${R}FAILED${N}";
		return 67108864;
	}
}

fif() {
	./sh2elf scripts/test_if.sh -o if.elf >/dev/null 2>&1
	CAPTURE=$(./if.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
if-true-pass
if-else-pass
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "If Stmt" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "If Stmt" "${R}FAILED${N}";
		return 134217728;
	}
}

fwhile() {
	./sh2elf scripts/test_while.sh -o while.elf >/dev/null 2>&1
	CAPTURE=$(./while.elf 2>/dev/null)
	EXPECTED="while-pass"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "While Loop" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "While Loop" "${R}FAILED${N}";
		return 268435456;
	}
}

ffor() {
	./sh2elf scripts/test_for.sh -o for.elf >/dev/null 2>&1
	CAPTURE=$(./for.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a
b
c
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "For Loop" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "For Loop" "${R}FAILED${N}";
		return 536870912;
	}
}

funtil() {
	./sh2elf scripts/test_until.sh -o until.elf >/dev/null 2>&1
	CAPTURE=$(./until.elf 2>/dev/null)
	EXPECTED="until_ok"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Until Loop" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Until Loop" "${R}FAILED${N}";
		return 1073741824;
	}
}

fread() {
	./sh2elf scripts/test_read.sh -o read.elf >/dev/null 2>&1
	echo "testinput" | ./read.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Read Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Read Cmd" "${R}FAILED${N}";
		return 1;
	}
}

funset() {
	./sh2elf scripts/test_unset.sh -o unset.elf >/dev/null 2>&1
	CAPTURE=$(./unset.elf 2>/dev/null)
	EXPECTED="done"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Unset Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Unset Cmd" "${R}FAILED${N}";
		return 2;
	}
}

fcp() {
	echo "cp_test_content" > /tmp/sh2elf_cp_src.txt
	./sh2elf scripts/test_cp.sh -o cp.elf >/dev/null 2>&1
	./cp.elf >/dev/null 2>&1
	CAPTURE=$(cat /tmp/sh2elf_cp_dst.txt 2>/dev/null)
	EXPECTED="cp_test_content"
	rm -f /tmp/sh2elf_cp_src.txt /tmp/sh2elf_cp_dst.txt
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cp Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cp Cmd" "${R}FAILED${N}";
		return 4;
	}
}

fmv() {
	echo "mv_test_content" > /tmp/sh2elf_mv_src.txt
	./sh2elf scripts/test_mv.sh -o mv.elf >/dev/null 2>&1
	./mv.elf >/dev/null 2>&1
	CAPTURE=$(cat /tmp/sh2elf_mv_dst.txt 2>/dev/null)
	EXPECTED="mv_test_content"
	rm -f /tmp/sh2elf_mv_src.txt /tmp/sh2elf_mv_dst.txt
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Mv Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Mv Cmd" "${R}FAILED${N}";
		return 8;
	}
}

frm() {
	touch /tmp/sh2elf_rm_file.txt
	./sh2elf scripts/test_rm.sh -o rm.elf >/dev/null 2>&1
	./rm.elf >/dev/null 2>&1
	[ ! -f /tmp/sh2elf_rm_file.txt ] && {
		fprint "Rm Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Rm Cmd" "${R}FAILED${N}";
		return 16;
	}
}

ftee() {
	./sh2elf scripts/test_tee.sh -o tee.elf >/dev/null 2>&1
	CAPTURE=$(echo "teedata" | ./tee.elf 2>/dev/null)
	FILE_DATA=$(cat /tmp/sh2elf_tee_out.txt 2>/dev/null)
	rm -f /tmp/sh2elf_tee_out.txt
	[ "${CAPTURE}" = "teedata" ] && [ "${FILE_DATA}" = "teedata" ] && {
		fprint "Tee Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tee Cmd" "${R}FAILED${N}";
		return 32;
	}
}

fexpr() {
	./sh2elf scripts/test_expr.sh -o expr.elf >/dev/null 2>&1
	CAPTURE=$(./expr.elf 2>/dev/null)
	EXPECTED="30"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Expr Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Expr Cmd" "${R}FAILED${N}";
		return 64;
	}
}

fparamexp() {
	./sh2elf scripts/test_param_exp.sh -o paramexp.elf >/dev/null 2>&1
	CAPTURE=$(./paramexp.elf 2>/dev/null)
	EXPECTED="default_val 5"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Param Exp" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Param Exp" "${R}FAILED${N}";
		return 128;
	}
}

fcase() {
	./sh2elf scripts/test_case.sh -o case.elf >/dev/null 2>&1
	CAPTURE=$(./case.elf 2>/dev/null)
	EXPECTED="is_hello"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Case Stmt" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Case Stmt" "${R}FAILED${N}";
		return 256;
	}
}

fheredoc() {
	./sh2elf scripts/test_heredoc.sh -o heredoc.elf >/dev/null 2>&1
	CAPTURE=$(./heredoc.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
heredoc_line1
heredoc_line2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Heredoc" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Heredoc" "${R}FAILED${N}";
		return 512;
	}
}

fcmdsub() {
	./sh2elf scripts/test_cmdsub.sh -o cmdsub.elf >/dev/null 2>&1
	CAPTURE=$(./cmdsub.elf 2>/dev/null)
	EXPECTED="subcmd1 subcmd2"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cmd Sub" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cmd Sub" "${R}FAILED${N}";
		return 1024;
	}
}

farith() {
	./sh2elf scripts/test_arith.sh -o arith.elf >/dev/null 2>&1
	CAPTURE=$(./arith.elf 2>/dev/null)
	EXPECTED="40"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Arith Exp" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Arith Exp" "${R}FAILED${N}";
		return 2048;
	}
}

fglob() {
	./sh2elf scripts/test_glob.sh -o glob.elf >/dev/null 2>&1
	CAPTURE=$(./glob.elf 2>/dev/null)
	EXPECTED="scripts/test_glob.sh"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Glob Exp" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Glob Exp" "${R}FAILED${N}";
		return 4096;
	}
}

ffunc() {
	./sh2elf scripts/test_func.sh -o func.elf >/dev/null 2>&1
	CAPTURE=$(./func.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
in_func
trapped
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Shell Func" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Shell Func" "${R}FAILED${N}";
		return 8192;
	}
}

funame() {
	./sh2elf scripts/test_uname.sh -o uname.elf >/dev/null 2>&1
	CAPTURE=$(./uname.elf 2>/dev/null)
	EXPECTED="x86_64"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Uname Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Uname Cmd" "${R}FAILED${N}";
		return 16384;
	}
}

fwhoami() {
	./sh2elf scripts/test_whoami.sh -o whoami.elf >/dev/null 2>&1
	./whoami.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Whoami Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Whoami Cmd" "${R}FAILED${N}";
		return 32768;
	}
}

fid() {
	./sh2elf scripts/test_id.sh -o id.elf >/dev/null 2>&1
	./id.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Id Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Id Cmd" "${R}FAILED${N}";
		return 65536;
	}
}

fenv() {
	./sh2elf scripts/test_env.sh -o env.elf >/dev/null 2>&1
	./env.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Env Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Env Cmd" "${R}FAILED${N}";
		return 131072;
	}
}

flscmd() {
	./sh2elf scripts/test_ls.sh -o ls.elf >/dev/null 2>&1
	./ls.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Ls Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Ls Cmd" "${R}FAILED${N}";
		return 262144;
	}
}

fgrep() {
	echo "match text" > /tmp/sh2elf_grep.txt
	./sh2elf scripts/test_grep.sh -o grep.elf >/dev/null 2>&1
	CAPTURE=$(./grep.elf 2>/dev/null)
	rm -f /tmp/sh2elf_grep.txt
	[ "${CAPTURE}" = "match text" ] && {
		fprint "Grep Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep Cmd" "${R}FAILED${N}";
		return 524288;
	}
}

ftr() {
	./sh2elf scripts/test_tr.sh -o tr.elf >/dev/null 2>&1
	CAPTURE=$(echo "abc" | ./tr.elf 2>/dev/null)
	[ "${CAPTURE}" = "zbc" ] && {
		fprint "Tr Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tr Cmd" "${R}FAILED${N}";
		return 1048576;
	}
}

fcut() {
	./sh2elf scripts/test_cut.sh -o cut.elf >/dev/null 2>&1
	CAPTURE=$(echo "col1 col2" | ./cut.elf 2>/dev/null)
	[ "${CAPTURE}" = "col1 col2" ] && {
		fprint "Cut Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cut Cmd" "${R}FAILED${N}";
		return 2097152;
	}
}

fsort() {
	./sh2elf scripts/test_sort.sh -o sort.elf >/dev/null 2>&1
	CAPTURE=$(echo "sorted" | ./sort.elf 2>/dev/null)
	[ "${CAPTURE}" = "sorted" ] && {
		fprint "Sort Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sort Cmd" "${R}FAILED${N}";
		return 4194304;
	}
}

funiq() {
	./sh2elf scripts/test_uniq.sh -o uniq.elf >/dev/null 2>&1
	CAPTURE=$(echo "unique" | ./uniq.elf 2>/dev/null)
	[ "${CAPTURE}" = "unique" ] && {
		fprint "Uniq Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Uniq Cmd" "${R}FAILED${N}";
		return 8388608;
	}
}

ffind() {
	./sh2elf scripts/test_find.sh -o find.elf >/dev/null 2>&1
	./find.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Find Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find Cmd" "${R}FAILED${N}";
		return 16777216;
	}
}

fxargs() {
	./sh2elf scripts/test_xargs.sh -o xargs.elf >/dev/null 2>&1
	CAPTURE=$(echo "xargs_test" | ./xargs.elf 2>/dev/null)
	[ "${CAPTURE}" = "xargs_test" ] && {
		fprint "Xargs Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Xargs Cmd" "${R}FAILED${N}";
		return 33554432;
	}
}

fsed() {
	./sh2elf scripts/test_sed.sh -o sed.elf >/dev/null 2>&1
	CAPTURE=$(echo "sed_test" | ./sed.elf 2>/dev/null)
	[ "${CAPTURE}" = "sed_test" ] && {
		fprint "Sed Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sed Cmd" "${R}FAILED${N}";
		return 67108864;
	}
}

fawk() {
	./sh2elf scripts/test_awk.sh -o awk.elf >/dev/null 2>&1
	CAPTURE=$(echo "awk_test" | ./awk.elf 2>/dev/null)
	[ "${CAPTURE}" = "awk_test" ] && {
		fprint "Awk Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Awk Cmd" "${R}FAILED${N}";
		return 134217728;
	}
}

ftail() {
	./sh2elf scripts/test_tail.sh -o tail.elf >/dev/null 2>&1
	CAPTURE=$(echo "tail_test" | ./tail.elf 2>/dev/null)
	[ "${CAPTURE}" = "tail_test" ] && {
		fprint "Tail Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tail Cmd" "${R}FAILED${N}";
		return 268435456;
	}
}

fchown() {
	touch /tmp/sh2elf_chown.txt
	./sh2elf scripts/test_chown.sh -o chown.elf >/dev/null 2>&1
	./chown.elf >/dev/null 2>&1
	RET=$?
	rm -f /tmp/sh2elf_chown.txt
	[ ${RET} -eq 0 ] && {
		fprint "Chown Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Chown Cmd" "${R}FAILED${N}";
		return 536870912;
	}
}

fchgrp() {
	touch /tmp/sh2elf_chgrp.txt
	./sh2elf scripts/test_chgrp.sh -o chgrp.elf >/dev/null 2>&1
	./chgrp.elf >/dev/null 2>&1
	RET=$?
	rm -f /tmp/sh2elf_chgrp.txt
	[ ${RET} -eq 0 ] && {
		fprint "Chgrp Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Chgrp Cmd" "${R}FAILED${N}";
		return 1073741824;
	}
}

fgrepi() {
	echo "MATCH TEXT" > /tmp/sh2elf_grep_i.txt
	./sh2elf scripts/test_grep_i.sh -o grepi.elf >/dev/null 2>&1
	CAPTURE=$(./grepi.elf 2>/dev/null)
	rm -f /tmp/sh2elf_grep_i.txt
	[ "${CAPTURE}" = "MATCH TEXT" ] && {
		fprint "Grep -i Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep -i Cmd" "${R}FAILED${N}";
		return 1;
	}
}

fgrepv() {
	echo "LINE TEXT" > /tmp/sh2elf_grep_v.txt
	./sh2elf scripts/test_grep_v.sh -o grepv.elf >/dev/null 2>&1
	CAPTURE=$(./grepv.elf 2>/dev/null)
	rm -f /tmp/sh2elf_grep_v.txt
	[ "${CAPTURE}" = "LINE TEXT" ] && {
		fprint "Grep -v Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep -v Cmd" "${R}FAILED${N}";
		return 2;
	}
}

fgrepn() {
	echo "MATCH LINE" > /tmp/sh2elf_grep_n.txt
	./sh2elf scripts/test_grep_n.sh -o grepn.elf >/dev/null 2>&1
	CAPTURE=$(./grepn.elf 2>/dev/null)
	rm -f /tmp/sh2elf_grep_n.txt
	[ "${CAPTURE}" = "1:MATCH LINE" ] && {
		fprint "Grep -n Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep -n Cmd" "${R}FAILED${N}";
		return 4;
	}
}

fgrepc() {
	echo "MATCH LINE" > /tmp/sh2elf_grep_c.txt
	./sh2elf scripts/test_grep_c.sh -o grepc.elf >/dev/null 2>&1
	CAPTURE=$(./grepc.elf 2>/dev/null)
	rm -f /tmp/sh2elf_grep_c.txt
	[ "${CAPTURE}" = "1" ] && {
		fprint "Grep -c Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep -c Cmd" "${R}FAILED${N}";
		return 8;
	}
}

fheadn() {
	echo "head line" > /tmp/sh2elf_head_n.txt
	./sh2elf scripts/test_head_n.sh -o headn.elf >/dev/null 2>&1
	CAPTURE=$(./headn.elf 2>/dev/null)
	rm -f /tmp/sh2elf_head_n.txt
	[ "${CAPTURE}" = "head line" ] && {
		fprint "Head -n Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Head -n Cmd" "${R}FAILED${N}";
		return 16;
	}
}

ftailn() {
	echo "tail line" > /tmp/sh2elf_tail_n.txt
	./sh2elf scripts/test_tail_n.sh -o tailn.elf >/dev/null 2>&1
	CAPTURE=$(./tailn.elf 2>/dev/null)
	rm -f /tmp/sh2elf_tail_n.txt
	[ "${CAPTURE}" = "tail line" ] && {
		fprint "Tail -n Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tail -n Cmd" "${R}FAILED${N}";
		return 32;
	}
}

fcutdf() {
	echo "val:sec" > /tmp/sh2elf_cut_df.txt
	./sh2elf scripts/test_cut_df.sh -o cutdf.elf >/dev/null 2>&1
	./cutdf.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_cut_df.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Cut -d -f Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cut -d -f Cmd" "${R}FAILED${N}";
		return 64;
	}
}

fsortr() {
	echo "sort line" > /tmp/sh2elf_sort_r.txt
	./sh2elf scripts/test_sort_r.sh -o sortr.elf >/dev/null 2>&1
	./sortr.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_sort_r.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Sort -r Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sort -r Cmd" "${R}FAILED${N}";
		return 128;
	}
}

fsortu() {
	echo "sort u" > /tmp/sh2elf_sort_u.txt
	./sh2elf scripts/test_sort_u.sh -o sortu.elf >/dev/null 2>&1
	./sortu.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_sort_u.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Sort -u Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sort -u Cmd" "${R}FAILED${N}";
		return 256;
	}
}

funiqc() {
	echo "uniq c" > /tmp/sh2elf_uniq_c.txt
	./sh2elf scripts/test_uniq_c.sh -o uniqc.elf >/dev/null 2>&1
	./uniqc.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_uniq_c.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Uniq -c Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Uniq -c Cmd" "${R}FAILED${N}";
		return 512;
	}
}

funiqd() {
	echo "uniq d" > /tmp/sh2elf_uniq_d.txt
	./sh2elf scripts/test_uniq_d.sh -o uniqd.elf >/dev/null 2>&1
	./uniqd.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_uniq_d.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Uniq -d Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Uniq -d Cmd" "${R}FAILED${N}";
		return 1024;
	}
}

fwcl() {
	echo "wc l" > /tmp/sh2elf_wc_l.txt
	./sh2elf scripts/test_wc_l.sh -o wcl.elf >/dev/null 2>&1
	./wcl.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_wc_l.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Wc -l Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Wc -l Cmd" "${R}FAILED${N}";
		return 2048;
	}
}

fwcw() {
	echo "wc w" > /tmp/sh2elf_wc_w.txt
	./sh2elf scripts/test_wc_w.sh -o wcw.elf >/dev/null 2>&1
	./wcw.elf >/dev/null 2>&1
	STAT=$?
	rm -f /tmp/sh2elf_wc_w.txt
	[ ${STAT} -eq 0 ] && {
		fprint "Wc -w Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Wc -w Cmd" "${R}FAILED${N}";
		return 4096;
	}
}

ffindname() {
	./sh2elf scripts/test_find_name.sh -o findname.elf >/dev/null 2>&1
	./findname.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Find -name Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find -name Cmd" "${R}FAILED${N}";
		return 8192;
	}
}

fps() {
	./sh2elf scripts/test_ps.sh -o ps.elf >/dev/null 2>&1
	./ps.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Ps Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Ps Cmd" "${R}FAILED${N}";
		return 16384;
	}
}

fkillall() {
	./sh2elf scripts/test_killall.sh -o killall.elf >/dev/null 2>&1
	./killall.elf >/dev/null 2>&1
	STAT=$?
	if [ ${STAT} -eq 0 ] || [ ${STAT} -eq 1 ]; then
		fprint "Killall Cmd" "${G}PASSED${N}";
		return 0;
	else
		fprint "Killall Cmd" "${R}FAILED${N}";
		return 32768;
	fi
}

fpgrep() {
	./sh2elf scripts/test_pgrep.sh -o pgrep.elf >/dev/null 2>&1
	./pgrep.elf >/dev/null 2>&1
	STAT=$?
	if [ ${STAT} -eq 0 ] || [ ${STAT} -eq 1 ]; then
		fprint "Pgrep Cmd" "${G}PASSED${N}";
		return 0;
	else
		fprint "Pgrep Cmd" "${R}FAILED${N}";
		return 65536;
	fi
}

fpkill() {
	./sh2elf scripts/test_pkill.sh -o pkill.elf >/dev/null 2>&1
	./pkill.elf >/dev/null 2>&1
	STAT=$?
	if [ ${STAT} -eq 0 ] || [ ${STAT} -eq 1 ]; then
		fprint "Pkill Cmd" "${G}PASSED${N}";
		return 0;
	else
		fprint "Pkill Cmd" "${R}FAILED${N}";
		return 131072;
	fi
}

fnice() {
	./sh2elf scripts/test_nice.sh -o nice.elf >/dev/null 2>&1
	./nice.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Nice Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Nice Cmd" "${R}FAILED${N}";
		return 262144;
	}
}

ftime() {
	./sh2elf scripts/test_time.sh -o time.elf >/dev/null 2>&1
	./time.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Time Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Time Cmd" "${R}FAILED${N}";
		return 524288;
	}
}

ftar() {
	echo "tar content" > /tmp/sh2elf_tar.txt
	./sh2elf scripts/test_tar.sh -o tar.elf >/dev/null 2>&1
	./tar.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Tar Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tar Cmd" "${R}FAILED${N}";
		return 1048576;
	}
}

fgzip() {
	rm -f /tmp/sh2elf_gzip.txt.gz
	echo "gzip content" > /tmp/sh2elf_gzip.txt
	./sh2elf scripts/test_gzip.sh -o gzip.elf >/dev/null 2>&1
	./gzip.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Gzip Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Gzip Cmd" "${R}FAILED${N}";
		return 2097152;
	}
}

fgunzip() {
	rm -f /tmp/sh2elf_gunzip.txt
	echo "gunzip content" | gzip > /tmp/sh2elf_gunzip.txt.gz
	./sh2elf scripts/test_gunzip.sh -o gunzip.elf >/dev/null 2>&1
	./gunzip.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Gunzip Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Gunzip Cmd" "${R}FAILED${N}";
		return 4194304;
	}
}

fexprops() {
	./sh2elf scripts/test_expr_ops.sh -o exprops.elf >/dev/null 2>&1
	CAPTURE=$(./exprops.elf 2>/dev/null)
	[ "${CAPTURE}" = "1" ] && {
		fprint "Expr Ops Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Expr Ops Cmd" "${R}FAILED${N}";
		return 8388608;
	}
}

fpatternexp() {
	./sh2elf scripts/test_pattern_exp.sh -o patternexp.elf >/dev/null 2>&1
	./patternexp.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Pattern Exp Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Pattern Exp Cmd" "${R}FAILED${N}";
		return 16777216;
	}
}

fgetopts() {
	./sh2elf scripts/test_getopts.sh -o getopts.elf >/dev/null 2>&1
	./getopts.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Getopts Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Getopts Cmd" "${R}FAILED${N}";
		return 33554432;
	}
}

feval() {
	./sh2elf scripts/test_eval.sh -o eval.elf >/dev/null 2>&1
	CAPTURE=$(./eval.elf 2>/dev/null)
	[ "${CAPTURE}" = "EVAL_SUCCESS" ] && {
		fprint "Eval Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Eval Cmd" "${R}FAILED${N}";
		return 67108864;
	}
}

fshift() {
	./sh2elf scripts/test_shift.sh -o shift.elf >/dev/null 2>&1
	CAPTURE=$(./shift.elf 2>/dev/null)
	[ "${CAPTURE}" = "SHIFT_OK" ] && {
		fprint "Shift Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Shift Cmd" "${R}FAILED${N}";
		return 134217728;
	}
}

fpathexec() {
	./sh2elf scripts/test_pathexec.sh -o pathexec.elf >/dev/null 2>&1
	CAPTURE=$(./pathexec.elf 2>/dev/null)
	[ "${CAPTURE}" = "PATH_EXEC_OK" ] && {
		fprint "Path Exec Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Path Exec Cmd" "${R}FAILED${N}";
		return 268435456;
	}
}

fhuge() {
	./sh2elf scripts/test_huge_comprehensive.sh -o huge.elf >/dev/null 2>&1
	./huge.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Huge Test Script" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Huge Test Script" "${R}FAILED${N}";
		return 536870912;
	}
}

fcompound_operands() {
	./sh2elf scripts/test_compound_operands.sh -o compound_operands.elf >/dev/null 2>&1
	./compound_operands.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Compound Operands" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Compound Operands" "${R}FAILED${N}";
		return 1;
	}
}

floop_control() {
	./sh2elf scripts/test_loop_control.sh -o loop_control.elf >/dev/null 2>&1
	./loop_control.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Loop Control" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Loop Control" "${R}FAILED${N}";
		return 2;
	}
}

ftrap_signals() {
	./sh2elf scripts/test_trap_signals.sh -o trap_signals.elf >/dev/null 2>&1
	./trap_signals.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Trap Signals" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Trap Signals" "${R}FAILED${N}";
		return 4;
	}
}

ffunc_return() {
	./sh2elf scripts/test_func_return.sh -o func_return.elf >/dev/null 2>&1
	./func_return.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Func Return" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Func Return" "${R}FAILED${N}";
		return 8;
	}
}

fset_flags() {
	./sh2elf scripts/test_set_flags.sh -o set_flags.elf >/dev/null 2>&1
	./set_flags.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Set Flags" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Set Flags" "${R}FAILED${N}";
		return 16;
	}
}

fparam_assign_alt() {
	./sh2elf scripts/test_param_assign_alt.sh -o param_assign_alt.elf >/dev/null 2>&1
	./param_assign_alt.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Param Assign Alt" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Param Assign Alt" "${R}FAILED${N}";
		return 32;
	}
}

ffd_redirs() {
	./sh2elf scripts/test_fd_redirs.sh -o fd_redirs.elf >/dev/null 2>&1
	./fd_redirs.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "FD Redirections" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "FD Redirections" "${R}FAILED${N}";
		return 64;
	}
}

fselect_loop() {
	./sh2elf scripts/test_select_loop.sh -o select_loop.elf >/dev/null 2>&1
	./select_loop.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Select Loop" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Select Loop" "${R}FAILED${N}";
		return 128;
	}
}

fproc_sub() {
	./sh2elf scripts/test_proc_sub.sh -o proc_sub.elf >/dev/null 2>&1
	./proc_sub.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "Process Substitution" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Process Substitution" "${R}FAILED${N}";
		return 256;
	}
}

fifs_splitting() {
	./sh2elf scripts/test_ifs_splitting.sh -o ifs_splitting.elf >/dev/null 2>&1
	./ifs_splitting.elf >/dev/null 2>&1
	[ $? -eq 0 ] && {
		fprint "IFS Splitting" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "IFS Splitting" "${R}FAILED${N}";
		return 512;
	}
}

farith_full() {
	./sh2elf scripts/test_arith_full.sh -o arith_full.elf >/dev/null 2>&1
	CAPTURE=$(./arith_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
23
20
49
1 2 -2
28 3 3 7 4 -8
1 0 1 0
0 1 0
7
31 15 11 255
10 10
15 15
15 16 17 17
17 15 15
28
8
10
700
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Arith Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Arith Full" "${R}FAILED${N}";
		return 1024;
	}
}

farith_cmd() {
	./sh2elf scripts/test_arith_cmd.sh -o arith_cmd.elf >/dev/null 2>&1
	CAPTURE=$(./arith_cmd.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
gt
not-lt
15
30
iter 0
iter 1
iter 2
iter 3
down 10
down 7
down 4
down 1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Arith Command" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Arith Command" "${R}FAILED${N}";
		return 2048;
	}
}

fwhile_loop() {
	./sh2elf scripts/test_while_loop.sh -o while_loop.elf >/dev/null 2>&1
	CAPTURE=$(./while_loop.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
while 0
while 1
while 2
while 3
until 3
until 2
until 1
pow 1
pow 2
pow 4
pow 8
pow 16
x
xx
xxx
a0
a1
b0
b1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "While Unroll" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "While Unroll" "${R}FAILED${N}";
		return 4096;
	}
}

fbrace_exp() {
	./sh2elf scripts/test_brace_exp.sh -o brace_exp.elf >/dev/null 2>&1
	CAPTURE=$(./brace_exp.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a b c
pre1post pre2post pre3post
1 2 3 4 5
5 4 3 2 1
a b c d e
1 4 7 10
01 02 03
xay xb1y xb2y xcy
x1 x2 y1 y2
fileA.txt
fileB.txt
{not,expanded}
{single}
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Brace Expansion" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Brace Expansion" "${R}FAILED${N}";
		return 8192;
	}
}

fparam_ext() {
	./sh2elf scripts/test_param_ext.sh -o param_ext.elf >/dev/null 2>&1
	CAPTURE=$(./param_ext.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
World
Hello
World
Wor
llo Wo
HELLO WORLD
hello world
Shell
sHELL
hELLO wORLD
Hello World
empty  unset
11
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Param Extended" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Param Extended" "${R}FAILED${N}";
		return 16384;
	}
}

fansi_quote() {
	./sh2elf scripts/test_ansi_quote.sh -o ansi_quote.elf >/dev/null 2>&1
	CAPTURE=$(./ansi_quote.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
tab	here
line1
line2
quote's
ABC
AB
tilde-home
tilde-path
tilde-user
~
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "ANSI-C Quote" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "ANSI-C Quote" "${R}FAILED${N}";
		return 32768;
	}
}

fherestring() {
	./sh2elf scripts/test_herestring.sh -o herestring.elf >/dev/null 2>&1
	CAPTURE=$(./herestring.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
here string
with var
HELLO
piped
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Here String" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Here String" "${R}FAILED${N}";
		return 65536;
	}
}

fnegation() {
	./sh2elf scripts/test_negation.sh -o negation.elf >/dev/null 2>&1
	CAPTURE=$(./negation.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
neg-false-ok
neg-true-ok
if-neg-ok
status 0
status 1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Negation" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Negation" "${R}FAILED${N}";
		return 131072;
	}
}

fbackground() {
	./sh2elf scripts/test_background.sh -o background.elf >/dev/null 2>&1
	CAPTURE=$(./background.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
started
waited
bg status 3
bg-sub
end
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Background Jobs" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Background Jobs" "${R}FAILED${N}";
		return 262144;
	}
}

fruntime_params() {
	./sh2elf scripts/test_runtime_params.sh -o runtime_params.elf >/dev/null 2>&1
	CAPTURE=$(./runtime_params.elf one two "three four" 2>/dev/null)
	STAT=$?
	EXPECTED=$(cat <<'EOF'
argc=3
first=one second=two third=three four
all=one two three four
status=1
status=0
arg1-match
argc-three
ppid-set
pid-positive
random-range
ext:one:two
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && [ ${STAT} -eq 7 ] && {
		fprint "Runtime Params" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Runtime Params" "${R}FAILED${N}";
		return 524288;
	}
}

ffunc_args() {
	./sh2elf scripts/test_func_args.sh -o func_args.elf >/dev/null 2>&1
	CAPTURE=$(./func_args.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
hello alice from bob (2 args)
hello x y from z (2 args)
7
all: a b c
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Func Args" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Func Args" "${R}FAILED${N}";
		return 1048576;
	}
}

fcase_alt() {
	./sh2elf scripts/test_case_alt.sh -o case_alt.elf >/dev/null 2>&1
	CAPTURE=$(./case_alt.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
apple: common
banana: common
cherry: paren
kiwi: other
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Case Alternation" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Case Alternation" "${R}FAILED${N}";
		return 2097152;
	}
}

ftest_ext() {
	./sh2elf scripts/test_test_ext.sh -o test_ext.elf >/dev/null 2>&1
	CAPTURE=$(./test_ext.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
is-file
non-empty
rw
not-exec
exec-now
not-dir
or-ok
symlink
missing
zn
lt
glob-match
regex-match
dbl-and
dbl-or
not-tty
same-file
newer
older
paren-group
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Test Extended" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Test Extended" "${R}FAILED${N}";
		return 4194304;
	}
}

fecho_opts() {
	./sh2elf scripts/test_echo_opts.sh -o echo_opts.elf >/dev/null 2>&1
	CAPTURE=$(./echo_opts.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
no newline done
a	b
c
stop
raw\tstay
xAy
-- -dash
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Echo Options" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Echo Options" "${R}FAILED${N}";
		return 8388608;
	}
}

fdquote_exp() {
	./sh2elf scripts/test_dquote_exp.sh -o dquote_exp.elf >/dev/null 2>&1
	CAPTURE=$(./dquote_exp.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
sum=7 cmd=inner bt=back
st=1 done
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Dquote Expansion" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Dquote Expansion" "${R}FAILED${N}";
		return 16777216;
	}
}

frev() {
	./sh2elf scripts/test_rev.sh -o rev.elf >/dev/null 2>&1
	CAPTURE=$(./rev.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
olleh
dlrow
stressed desserts
€bña
enilwen-onolleh
dlrow
missing-status 1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Rev Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Rev Cmd" "${R}FAILED${N}";
		return 33554432;
	}
}

fnl() {
	./sh2elf scripts/test_nl.sh -o nl.elf >/dev/null 2>&1
	CAPTURE=$(./nl.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
     1	alpha
       
     2	beta
       
       
     3	gamma
     1	alpha
     2	
     3	beta
     4	
     5	
     6	gamma
     1	alpha
       
     2	beta
       
     3	
     4	gamma
1  | alpha
2  | 
3  | beta
4  | 
5  | 
6  | gamma
-002	alpha
0001	
0004	beta
0007	
0010	
0013	gamma
       alpha
       
       beta
       
       
       gamma
     1	intro

     1	head

     1	body1
     2	body2

     1	foot
     1	intro

       head

     2	body1
     3	body2

       foot
 1:alpha
 2:
 3:beta
 4:
 5:
 6:gamma
 7:intro

   head

 1:body1
 2:body2

   foot
     1	piped line
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Nl Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Nl Cmd" "${R}FAILED${N}";
		return 67108864;
	}
}

ftac() {
	./sh2elf scripts/test_tac.sh -o tac.elf >/dev/null 2>&1
	CAPTURE=$(./tac.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
third
second
first
zy
x

c
b:a::c
:ba
3ab2ab1abthird
second
first
third
second
first
missing-status 1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Tac Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tac Cmd" "${R}FAILED${N}";
		return 134217728;
	}
}

ffold() {
	./sh2elf scripts/test_fold.sh -o fold.elf >/dev/null 2>&1
	CAPTURE=$(./fold.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a
	
bcdef
ghij
ab cd
 ef g
h ij 
kl
the q
uick 
brown
 fox 
jumps
 over
 the 
lazy 
dog
日本
語日
本
äääää
ää
longw
ordwi
thout
space
s her
e
a	
bcdefghij
ab cd ef 
gh ij kl
the quick 
brown fox 
jumps 
over the 
lazy dog
日本語日本
äääääää
longwordwi
thoutspace
s here
a	bc
defg
hij
ab c
d ef
 gh 
ij k
l
the 
quic
k br
own 
fox 
jump
s ov
er t
he l
azy 
dog
日
本
語
日
本
ää
ää
ää
ä
long
word
with
outs
pace
s he
re
a	
bcdefg
hij
ab cd 
ef gh 
ij kl
the 
quick 
brown 
fox 
jumps 
over 
the 
lazy 
dog
日本
語日
本
äää
äää
ä
longwo
rdwith
outspa
ces 
here
a	
bcdefghi
j
ab cd ef
 gh ij k
l
the quic
k brown 
fox jump
s over t
he lazy 
dog
日本語日
本
äääääää
longword
withouts
paces he
re
a	
bcdefghij
ab cd ef gh 
ij kl
the quick 
brown fox 
jumps over 
the lazy dog
日本語日本
äääääää
longwordwith
outspaces 
here
no newl
ine at 
end
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Fold Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Fold Cmd" "${R}FAILED${N}";
		return 268435456;
	}
}

fbase64() {
	./sh2elf scripts/test_base64.sh -o base64.elf >/dev/null 2>&1
	CAPTURE=$(./base64.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gMDEyMzQ1Njc4OSAh
QCMkJV4mKigp
VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZy4gMDEyMzQ1Njc4OSAhQCMkJV4mKigp
VGhlIHF1aWNrIGJy
b3duIGZveCBqdW1w
cyBvdmVyIHRoZSBs
YXp5IGRvZy4gMDEy
MzQ1Njc4OSAhQCMk
JV4mKigp
aGVsbG8gd29ybGQ=
YQ==
The quick brown fox jumps over the lazy dog. 0123456789 !@#$%^&*()
a
hel rc=1
hello
hellohi
hello rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Base64 Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Base64 Cmd" "${R}FAILED${N}";
		return 536870912;
	}
}

fprintf_full() {
	./sh2elf scripts/test_printf_full.sh -o printf_full.elf >/dev/null 2>&1
	CAPTURE=$(./printf_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a-b
c-d
   42|42   |00042|ff|FF|10|0xff
3.14 1.234568e+04 0.0001
hw
     right|left      |tru
octABé
tab	here
nl
x
65

stop\c after
     7|ab  |
no args %
[  z]
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Printf Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Printf Full" "${R}FAILED${N}";
		return 1073741824;
	}
}

fxxd() {
	./sh2elf scripts/test_xxd.sh -o xxd.elf >/dev/null 2>&1
	CAPTURE=$(./xxd.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
00000000: 6865 6c6c 6f0a 776f 726c 642c 2074 6869  hello.world, thi
00000010: 7320 6973 2078 7864 2074 6573 7401 ff    s is xxd test..
00000000: 68 65 6c 6c 6f 0a 77 6f  hello.wo
00000008: 72 6c 64 2c 20 74 68 69  rld, thi
00000010: 73 20 69 73 20 78 78 64  s is xxd
00000018: 20 74 65 73 74 01 ff      test..
00000000: 68656C6C 6F0A776F 726C642C 20746869  hello.world, thi
00000010: 73206973 20787864 20746573 7401FF    s is xxd test..
68656c6c6f0a776f726c642c207468697320697320787864207465737401
ff
68656c6c
6f0a776f
726c642c
20746869
73206973
20787864
20746573
7401ff
00000003: 6c6f 0a77 6f72 6c64 2c20                 lo.world, 
0000001b: 7374 01ff                                st..
00000010: 6865 6c6c                                hell
00000000: 6c6c6568 6f770a6f 2c646c72 69687420  hello.world, thi
00000010: 73692073 64787820 73657420   ff0174  s is xxd test..
00000000: 01100001 01100010 01100011 01100100 01100101 01100110  abcdef
00000006: 01100111                                               g
00000000: 01101000 01100101 01101100 01101100  hell
00000004: 01101111 00001010 01110111 01101111  o.wo
unsigned char _tmp_sh2elf_xxd_bin[] = {
  0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x0a, 0x77, 0x6f, 0x72, 0x6c, 0x64, 0x2c,
  0x20, 0x74, 0x68, 0x69, 0x73, 0x20, 0x69, 0x73, 0x20, 0x78, 0x78, 0x64,
  0x20, 0x74, 0x65, 0x73, 0x74, 0x01, 0xff
};
unsigned int _tmp_sh2elf_xxd_bin_len = 31;
  0x68, 0x65, 0x6c, 0x6c,
  0x6f, 0x0a, 0x77, 0x6f,
  0x72, 0x6c, 0x64, 0x2c,
  0x20, 0x74, 0x68, 0x69,
  0x73, 0x20, 0x69, 0x73,
  0x20, 0x78, 0x78, 0x64,
  0x20, 0x74, 0x65, 0x73,
  0x74, 0x01, 0xff
00000000: 6865 6c6c  hell
00000004: 6f0a 776f  o.wo
00000008: 72         r
00000000: 68656c6c6f0a776f726c642c20746869  hello.world, thi
00000010: 7320697320787864207465737401ff    s is xxd test..
68656c6c6f0a776f726c642c207468697320697320787864207465737401
ff
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Xxd Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Xxd Cmd" "${R}FAILED${N}";
		return 2097152;
	}
}

fcmp() {
	./sh2elf scripts/test_cmp.sh -o cmp.elf >/dev/null 2>&1
	CAPTURE=$(./cmp.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a b differ: byte 8, line 2
rc=1
a b differ: byte 8, line 2 is 157 o 117 O
cmp: EOF on ‘a’ after byte 12
 8 157 117
10 154 114
rc=1
cmp: EOF on ‘a’ after byte 12
 8 157 o    117 O
10 154 l    114 L
cmp: EOF on ‘c’ after byte 6, line 1
cmp: EOF on ‘e’ which is empty
rc=1
rc=0
rc=0
a b differ: byte 2, line 1
a b differ: byte 1, line 1
a b differ: byte 7, line 2 is 157 o 117 O
- b differ: byte 8, line 2
cmp: missing: No such file or directory
rc=2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cmp Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cmp Cmd" "${R}FAILED${N}";
		return 4194304;
	}
}

fcksum() {
	./sh2elf scripts/test_cksum.sh -o cksum.elf >/dev/null 2>&1
	CAPTURE=$(./cksum.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
2382472371 44 /tmp/sh2elf_cksum.txt
2382472371 44
4294967295 0
1838399800 44 /tmp/sh2elf_cksum.txt
4067 1 /tmp/sh2elf_cksum.txt
25281     1 /tmp/sh2elf_cksum.txt
25281     1
304 1
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cksum Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cksum Cmd" "${R}FAILED${N}";
		return 8388608;
	}
}

fseq() {
	./sh2elf scripts/test_seq.sh -o seq.elf >/dev/null 2>&1
	CAPTURE=$(./seq.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
1
2
3
4
5
3
4
5
6
7
1
4
7
10
10
7
4
1
-3
-2
-1
00
01
02
03
08
09
10
1,2,3,4,5
1, 4, 7, 10
098-099-100-101
1.0
1.5
2.0
2.5
3.0
001
002
003
9223372036854775806
9223372036854775807
18446744073709551614
18446744073709551615
2052179976 588895
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Seq Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Seq Cmd" "${R}FAILED${N}";
		return 0;
	}
}

fyes() {
	./sh2elf scripts/test_yes.sh -o yes.elf >/dev/null 2>&1
	CAPTURE=$(./yes.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
y
y
y
hello world
hello world
2619398717 100000
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Yes Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Yes Cmd" "${R}FAILED${N}";
		return 33554432;
	}
}

ffactor() {
	./sh2elf scripts/test_factor.sh -o factor.elf >/dev/null 2>&1
	CAPTURE=$(./factor.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
1:
0:
2: 2
12: 2 2 3
97: 97
360: 2 2 2 3 3 5
1000000007: 1000000007
18446744073709551615: 3 5 17 257 641 65537 6700417
18446744073709551557: 18446744073709551557
4611686014132420609: 2147483647 2147483647
600851475143: 71 839 1471 6857
1234567890123456789: 3 3 101 3541 3607 3803 27961
1024: 2^10
360: 2^3 3^2 5
18446744073709551615: 3 5 17 257 641 65537 6700417
10: 2 5
21: 3 7
2221863771 921
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Factor Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Factor Cmd" "${R}FAILED${N}";
		return 67108864;
	}
}

fhostname() {
	./sh2elf scripts/test_hostname.sh -o hostname.elf >/dev/null 2>&1
	CAPTURE=$(./hostname.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
hostname-ok
short-ok
long-opt-ok
set-rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Hostname Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Hostname Cmd" "${R}FAILED${N}";
		return 134217728;
	}
}

fnproc() {
	./sh2elf scripts/test_nproc.sh -o nproc.elf >/dev/null 2>&1
	CAPTURE=$(./nproc.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
nproc-ok
all-ok
1
1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Nproc Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Nproc Cmd" "${R}FAILED${N}";
		return 268435456;
	}
}

fprintenv() {
	./sh2elf scripts/test_printenv.sh -o printenv.elf >/dev/null 2>&1
	CAPTURE=$(./printenv.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
home-ok
null-ok
missing-rc=1
1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Printenv Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Printenv Cmd" "${R}FAILED${N}";
		return 536870912;
	}
}

freadlink() {
	./sh2elf scripts/test_readlink.sh -o readlink.elf >/dev/null 2>&1
	CAPTURE=$(./readlink.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
f
l1
plain-rc=1
/tmp/sh2elf_rl/f
/tmp/sh2elf_rl/f
e-rc=1
/tmp/sh2elf_rl/nowhere
/tmp/sh2elf_rl/f
/tmp/sh2elf_rl/nothere
/tmp/sh2elf_rl/a/b/c
/tmp/x/z
f|
readlink: f: Invalid argument
0000000   f  \0
0000002
f-rc=1
/usr
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Readlink Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Readlink Cmd" "${R}FAILED${N}";
		return 1073741824;
	}
}

fln() {
	./sh2elf scripts/test_ln.sh -o ln.elf >/dev/null 2>&1
	CAPTURE=$(./ln.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
f
ln: failed to create symbolic link 'l1': File exists
exists-rc=1
forced
2
'h2' => 'f'
'd/f' -> 'f'
f
ln: failed to access 'nosuch': No such file or directory
missing-rc=1
ln: failed to create symbolic link 'd': File exists
f
h1
l1
'e/h2' -> 'h2'
h2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Ln Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Ln Cmd" "${R}FAILED${N}";
		return 1;
	}
}

ftruncate() {
	./sh2elf scripts/test_truncate.sh -o truncate.elf >/dev/null 2>&1
	CAPTURE=$(./truncate.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
100
150
120
50
70
64
80
1024
2000
1048576
nocreate-rc=0
t1
4
1048577
948578
truncate: cannot open 'nodir/x' for writing: No such file or directory
truncate: Invalid number: ‘1.5K’
invalid-rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Truncate Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Truncate Cmd" "${R}FAILED${N}";
		return 2;
	}
}

fhead_full() {
	./sh2elf scripts/test_head_full.sh -o head_full.elf >/dev/null 2>&1
	CAPTURE=$(./head_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
1
2
3
4
5
6
7
8
9
10
==> h1 <==
1
2
3

==> h2 <==
a
b
ca
b
c
1
2
3
a
b
c
1
a
b
c
==> h1 <==
1

==> h2 <==
a
a
b
c
a
b
c
head: cannot open nosuch for reading: No such file or directory
==> h1 <==
1
missing-rc=1
==> dir <==
head: error reading dir: Is a directory

==> h2 <==
a
b
cdir-rc=1
==> standard input <==
1

==> h2 <==
a

1458715628 51
1
2
3
1
2
1
2
2941577287 588888
1226921129 50000
==> h1 <==
1
2
3
4
5
6
7
8
9
10
head: cannot open -n for reading: No such file or directory
head: cannot open 2 for reading: No such file or directory
perm-rc=1
head: invalid option -- 'q'
usage: head [-c number|-n number] [file...]
rc=1
head: invalid option -- 'v'
usage: head [-c number|-n number] [file...]
rc=1
head: invalid option -- 'z'
usage: head [-c number|-n number] [file...]
rc=1
head: invalid option -- '3'
usage: head [-c number|-n number] [file...]
rc=1
head: invalid option -- '-'
usage: head [-c number|-n number] [file...]
rc=1
head: invalid option -- '-'
usage: head [-c number|-n number] [file...]
rc=1
head: option requires an argument -- 'n'
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines: -3
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines: +2
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines: 1k
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines: abc
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines: 
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines:  2
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of lines: 0x10
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of bytes: -3
usage: head [-c number|-n number] [file...]
rc=1
head: invalid number of bytes: 1k
usage: head [-c number|-n number] [file...]
rc=1
head: cannot combine -c and -n
usage: head [-c number|-n number] [file...]
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Head Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Head Full" "${R}FAILED${N}";
		return 4;
	}
}

fbig_input() {
	./sh2elf scripts/test_big_input.sh -o big_input.elf >/dev/null 2>&1
	CAPTURE=$(./big_input.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
1066600491 87888897 /tmp/sh2elf_big.txt
2886012536 87888897
798806947 87888897
4082364691 87888897
3142121490 175888899
185442658 98788898
3390455255 87888870
roundtrip-ok
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Big Input" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Big Input" "${R}FAILED${N}";
		return 8;
	}
}

ftail_full() {
	./sh2elf scripts/test_tail_full.sh -o tail_full.elf >/dev/null 2>&1
	CAPTURE=$(./tail_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
18
19
20
9
20
18
19
20
0
18
19
20
18
19
20
c
tail: cannot open nosuch for reading: No such file or directory
rc=1
29
30
29
30
1458715628 51
1
2
9
20
tail: error reading dd: Is a directory
rc=1
11
12
13
14
15
16
17
18
19
20
2243145586 588893
100000
3823891876 100
99990
99991
99992
99993
99994
99995
99996
99997
99998
99999
100000
99998
99999
100000
100000
99998
99999
100000
106882155 300001
b
c
19
20
c
b
a
20
19
18
100000
99999
2175776548 588895
3
2
1
a
b
c
tail: extra operand h2
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- 'q'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- 'v'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- 'z'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- 'F'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- '3'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- '-'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid option -- '-'
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: cannot combine -c and -n
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: cannot combine -r and -c
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: cannot combine -r and -f
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid number of lines: +2
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid number of lines: 1k
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid number of lines: abc
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid number of lines: 
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
tail: invalid number of lines: x+2
usage: tail [-f] [-c number|-n number] [file]
       tail -r [-n number] [file]
rc=1
17
18
19
20
b
c
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Tail Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tail Full" "${R}FAILED${N}";
		return 16;
	}
}

ftail_follow() {
	./sh2elf scripts/test_tail_follow.sh -o tail_follow.elf >/dev/null 2>&1
	CAPTURE=$(./tail_follow.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
two
three
four
follow-done rc=143
bb
x
p
q
piped
pipe-follow rc=0
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Tail Follow" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tail Follow" "${R}FAILED${N}";
		return 32;
	}
}

fwc_full() {
	./sh2elf scripts/test_wc_full.sh -o wc_full.elf >/dev/null 2>&1
	CAPTURE=$(./wc_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
20 20 51 h1
20 20 51 h1
1 3 5 h2
21 23 56 total
20 h1
3 h2
51 h1
5 h2
56 total
17 u
2 4 17 u
20 20 51
20 20 51
20
0 0 0 e
wc: nosuch: No such file or directory
20 20 51 h1
20 20 51 total
missing-rc=1
20 20 51 h1
20 51 h1
100000 100000 588895 big
20 20 51 h1
100020 100020 588946 total
0 0 0 dd
wc: dd: Is a directory
dir-rc=1
20 20
20 -
20 -
1 h2
21 total
3
1 4
2 4
2
0 2 3
2 4 17 u
20 20 51 h1
1 3 5 h2
0 0 0 e
23 27 73 total
1 3 5 h2
200000 200000 1288895
51851 51851 300000
wc: invalid option -- 'L'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: invalid option -- 'x'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: invalid option -- '-'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: invalid option -- '-'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: invalid option -- '-'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: invalid option -- '-'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: invalid option -- '-'
usage: wc [-c|-m] [-lw] [file...]
rc=1
wc: cannot combine -c and -m
usage: wc [-c|-m] [-lw] [file...]
rc=1
20 h1
3 h2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Wc Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Wc Full" "${R}FAILED${N}";
		return 64;
	}
}

fcut_posix() {
	./sh2elf scripts/test_cut_posix.sh -o cut_posix.elf >/dev/null 2>&1
	CAPTURE=$(./cut_posix.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
hél
日本語
abc
é
本
b
llo wörld
語テキスト
c
héo
日本キ
ab
hlo wörld
日テキスト
a
hl
日語
ac
h

ab
é
日
bc
llo wörld
本語テキスト

hél
日
abc
é
日
c
b
a§c
b§c
c
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cut POSIX Chars" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cut POSIX Chars" "${R}FAILED${N}";
		return 128;
	}
}

fcut_full() {
	./sh2elf scripts/test_cut_full.sh -o cut_full.elf >/dev/null 2>&1
	CAPTURE=$(./cut_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
b
2
nodelim
x
a:c
1:3
nodelim
:
b:c:d
2:3
nodelim
x:
a:b
1:2
nodelim
:x
b
2
x
a:c:d
1:3
nodelim
:
:b:
:2:
ode
x:
ab
12
nd
::
a:b
1:2
nod
:x:
a:b:c:d
1:2:3
nodelim
:x:
b
a:c:d
1:3
nodelim
:
c:d
3
lim

a:
1:
no
:x
ab:c:d
12:3
ndelim
::
rc=0
cut: fields are numbered from 1
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: the delimiter must be a single character
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: invalid decreasing range
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: only one list may be specified
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
0000000   b  \0   c  \n
0000004
b
rc=0
a:b:c:d
1:2:3
nodelim
:x:
a:b
1:2
:x
a:b
1:2
nodelim
:x
cut: -s: No such file or directory
rc=1
abdeg
abcd
adefgh
a c
ac
abcdf:gh:ij
abcdef:gh
cut: byte/character offset 99999999999999999999 is too large
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
def:gh:ij
cut: field number 99999999999999999999 is too large
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: only one list may be specified
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
0000000   a  \t   b  \n
0000004
b

z
x:z
cut: an input delimiter may be specified only when operating on fields
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: suppressing non-delimited lines makes sense
	only when operating on fields
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: fields are numbered from 1
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: invalid byte/character position x
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: invalid field value x
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: invalid range with no endpoint: -
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
cut: nosuch: No such file or directory
a
1
nodelim

missing-rc=1
cut: invalid option -- 'z'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: invalid option -- '-'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: invalid option -- '-'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: invalid option -- '-'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: invalid option -- '-'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: invalid option -- 'Z'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: you must specify a list of bytes, characters, or fields
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: option requires an argument -- 'f'
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
cut: only one list may be specified
usage: cut -b list [-n] [file...]
       cut -c list [file...]
       cut -f list [-d delim] [-s] [file...]
rc=1
a:
1:
no
:x
a
1
n
:
b
2
nodelim
x
a:c
1:3
:
3440651911 488895
174177100 1233345
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Cut Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cut Full" "${R}FAILED${N}";
		return 256;
	}
}

ftr_full() {
	./sh2elf scripts/test_tr_full.sh -o tr_full.elf >/dev/null 2>&1
	CAPTURE=$(./tr_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
HELLO WORLD 123
heo
abcdd
hexy wyrxd
abcXXXX
123
a
b
c
xxx
xyyyyy
ABC
ab
xxx
xxyz
tab_x
Zbc
x=b
helo
abc
abc
xyb
aQb
yyy
hello
world
foo
xcc
bcc
ab

x__y
132
xbc
x_z
tr: invalid option -- 't'
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
rc=1
tr: invalid option -- '-'
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
rc=1
tr: the [c*] repeat construct may not appear in string1
rc=1
tr: read error: Is a directory
rc=1
HELLO WORLD
abc
xyzdef
axb
axb
axb
xxx
AbC
tr: missing operand
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
tr: missing operand after a
Two strings must be given when translating.
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
tr: missing operand
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
tr: extra operand b
Only one string may be given when deleting without squeezing repeats.
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
tr: extra operand c
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
tr: range-endpoints of c-a are in reverse collating sequence order
tr: when translating, the only character classes that may appear in
string2 are upper and lower
tr: the [c*] repeat construct may not appear in string1
tr: invalid character class foo
tr: when not truncating set1, string2 must be non-empty
tr: when translating with string1 longer than string2,
the latter string must not end with a character class
tr: missing operand after a
Two strings must be given when both deleting and squeezing repeats.
usage: tr [-c|-C] [-s] string1 string2
       tr -s [-c|-C] string1
       tr -d [-c|-C] string1
       tr -ds [-c|-C] string1 string2
tr: misaligned [:upper:] and/or [:lower:] construct
tr: [=c=] expressions may not appear in string2 when translating
abcabc123
xyyABC123
abyyyyyyyy
hello
world
mIXED case 99
x y
a b c


abc
3308782509 1288895
1259080354 1200001
316906447 1270895
741568335 1288895
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Tr Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tr Full" "${R}FAILED${N}";
		return 512;
	}
}

ftr_posix() {
	./sh2elf scripts/test_tr_posix.sh -o tr_posix.elf >/dev/null 2>&1
	CAPTURE=$(./tr_posix.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
hello wörld
hllo wrld
HÉLLO WÖRLD
HÉLLO WÖRLD ÀÉ
héllo àé
h_llo_w_rld
hllowrld
héllo wörld
é aaa
αβγ
abc
 123
hllo
axbyc
omega
x-y
héło
GRÜßE
αβγ*δ
hllo wrld
GRÜßE
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Tr POSIX Chars" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tr POSIX Chars" "${R}FAILED${N}";
		return 1024;
	}
}

funiq_full() {
	./sh2elf scripts/test_uniq_full.sh -o uniq_full.elf >/dev/null 2>&1
	CAPTURE=$(./uniq_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a
b
c
d
a
2 a
1 b
3 c
1 d
1 a
a
c
b
d
a
x 1 a
y 2 a
z 2 b
xa
zb
a
b
c
d
a
a
uniq: cannot combine -c and -d
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: cannot combine -c and -u
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: invalid option -- 'D'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: nosuch: No such file or directory
rc=1
uniq: extra operand c
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
1 100000
x a
x	a
y a
0000000 377   a  \n
0000003
uniq: x: invalid number of characters to skip
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
uniq: -1: invalid number of fields to skip
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
a  b
abc
1 x y
1 a
2 
1 b
uniq: invalid option -- 'i'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: invalid option -- 'z'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: invalid option -- 'w'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: invalid option -- '-'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: invalid option -- '-'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
uniq: invalid option -- '2'
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
2 aa
a b
a c
a
b
c
d
a
uniq: nosuch: No such file or directory
rc=1
ls: out2: No such file or directory
2 a
1 b
3 c
1 d
1 a
2 x 1
uniq: 1k: invalid number of characters to skip
usage: uniq [-c|-d|-u] [-f fields] [-s char] [input_file [output_file]]
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Uniq Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Uniq Full" "${R}FAILED${N}";
		return 2048;
	}
}

fsort_full() {
	./sh2elf scripts/test_sort_full.sh -o sort_full.elf >/dev/null 2>&1
	CAPTURE=$(./sort_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
0:a
0 :a
10
10:30
1:05
-3
9
apple
Apple
b a
banana
cherry
eclair
  zed
  zed
eclair
cherry
banana
b a
Apple
apple
9
-3
1:05
10:30
10
0 :a
0:a
0:a
0 :a
10
10:30
1:05
-3
9
apple
Apple
b a
banana
cherry
eclair
  zed
0:a
0 :a
10
10:30
1:05
-3
9
apple
Apple
b a
banana
cherry
eclair
  zed
-3
0:a
0 :a
apple
Apple
b a
banana
cherry
eclair
  zed
1:05
9
10
10:30
0:a
0 :a
10
10:30
1:05
-3
9
apple
Apple
b a
banana
cherry
eclair
  zed
0 :a
0:a
10
10:30
1:05
-3
9
apple
Apple
b a
banana
cherry
eclair
  zed
w:1:d
y:1:a
z:2:c
x:3:b
y:1:a
z:2:c
x:3:b
10 dec w
1 jan y
2 feb a
2 FEB z
3 Mar x
a
a
b
b
c
c
d
a
b
c
d
d
c
c
b
b
a
a
sort: cannot read: -r: No such file or directory
rc=2
rc=0
sort: f:2: disorder: Apple
rc=1
rc=1
0:a
0 :a
10
10:30
1:05
-3
9
apple
Apple
b a
banana
cherry
eclair
  zed
0000000   a  \0   c  \n   x  \0   a  \n   x  \0   b  \n
0000014
a
b
sort: field number is zero: invalid field specification 0
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: stray character in field spec: invalid field specification 1x
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
sort: character offset is zero: invalid field specification 1.0
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
sort: multi-character tab ab
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
sort: incompatible tabs
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
sort: extra operand s2 not allowed with -c
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
sort: cannot read: nosuch: No such file or directory
rc=2
sort: invalid option -- 'g'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 'h'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 'M'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 'V'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 'R'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 's'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 'z'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- 'S'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- '-'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: invalid option -- '-'
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
sort: cannot read: +1: No such file or directory
rc=2
sort: options -dn are incompatible
usage: sort [-m] [-o output] [-bdfinru] [-t char] [-k keydef]... [file...]
       sort [-c|-C] [-bdfinru] [-t char] [-k keydef] [file]
rc=2
10 dec w
2 feb a
2 FEB z
1 jan y
3 Mar x
rc=0
  zed
-3
0 :a
0:a
10
10:30
1:05
9
Apple
apple
b a
banana
cherry
eclair
  zed
-3
0 :a
0:a
10
10:30
1:05
9
Apple
apple
b a
banana
cherry
eclair
w:1:d
y:1:a
z:2:c
x:3:b
10 dec w
3 Mar x
2 feb a
2 FEB z
1 jan y
sort: f:2: disorder: Apple
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Sort Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sort Full" "${R}FAILED${N}";
		return 4096;
	}
}

fsort_posix() {
	./sh2elf scripts/test_sort_posix.sh -o sort_posix.elf >/dev/null 2>&1
	CAPTURE=$(./sort_posix.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a-b
b
é
É
Éa
éb
ßx
zeta
Ω
Ωa
a-b
b
é
É
Éa
éb
ßx
zeta
Ω
Ωa
a-b
b
é
Éa
éb
ßx
zeta
Ω
Ωa
a-b
b
é
É
Éa
éb
ßx
zeta
Ω
Ωa
y→1→a
x→2→b
z→3→c
z→3→c
x→2→b
y→1→a
aéb 2
méa 3
zΩa 1
zΩa 1
méa 3
aéb 2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Sort POSIX" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sort POSIX" "${R}FAILED${N}";
		return 8192;
	}
}

fgrep_full() {
	./sh2elf scripts/test_grep_full.sh -o grep_full.elf >/dev/null 2>&1
	CAPTURE=$(./grep_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a fox
error
the quick brown fox
fox and dog
a:1:the quick brown fox
a:7:fox and dog
b:2:two fox
a:5
b:2
ERROR: disk

ERROR: disk
error: net
the lazy dog
fox and dog
jumps over
ow
ox
ov
og
or
ox
og
0:the quick brown fox
68:fox and dog
a:1:0:the quick brown fox
a:3:31:the lazy dog
the quick brown fox
fox and dog
two fox
a
b
b
the quick brown fox
the quick brown fox
jumps over
jumps over
the lazy dog
3-the lazy dog
4:ERROR: disk
5-error: net
the lazy dog
ERROR: disk
error: net

fox and dog
the quick brown fox
XX
fox and dog
the quick brown fox
fox and dog
the quick brown fox
error: net
fox and dog
error: net
the quick brown fox
error: net
fox and dog
a: 1:	the quick brown fox
a: 7:	fox and dog
b: 2:	two fox
0000000   a  \0   b  \0
0000004
[32m[K1[m[K[36m[K:[m[Kthe quick brown [01;31m[Kfox[m[K
[32m[K7[m[K[36m[K:[m[K[01;31m[Kfox[m[K and dog
in:the quick brown fox
in:fox and dog
rc=0
rc=1
a:the quick brown fox
a:fox and dog
rc=2
rc=2
rc=0
2
0000000   a  \0   b  \n   a   b  \n
0000007
0000000   x  \0   x  \0
0000004
0:o
6:o
9:o
2
rc=2
rc=2
rc=2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Grep Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep Full" "${R}FAILED${N}";
		return 16384;
	}
}

fgrep_regex() {
	./sh2elf scripts/test_grep_regex.sh -o grep_regex.elf >/dev/null 2>&1
	CAPTURE=$(./grep_regex.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
abc
aXc
abc
ab
abab
foo_bar baz
aaaa
aaaa
ab
abab
abab
aaaa
aXc
ÉCOLE
k K
12:30
aXc
foo_bar baz
12:30
ÉCOLE
k K
foo_bar baz
hello world
foo_bar baz
foo_bar baz
 world
 baz
 café
 
 ß
abc
aXc
ab
abab
aaaa
abc
aXc
hello world
foo_bar baz
ÉCOLE
é café
é
café
hello world
é café
ÉCOLE
12
abc
aXc
abc
rc=2
rc=2
rc=2
rc=2
rc=2
rc=2
aaaa
ab
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Grep Regex" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep Regex" "${R}FAILED${N}";
		return 32768;
	}
}

fgrep_rec() {
	./sh2elf scripts/test_grep_rec.sh -o grep_rec.elf >/dev/null 2>&1
	CAPTURE=$(./grep_rec.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
./a.txt:hello
./d1/b.c:hello x
./d1/d2/c.txt:nohello
a.txt:hello
d1/b.c:hello x
d1/d2/c.txt:nohello
d1/b.c:1
d1/d2/c.txt:1
./d1/b.c:hello x
a.txt:hello
d1/d2/c.txt:nohello
a.txt:hello
d1/b.c:hello x
hello x
nohello
./a.txt
./d1/b.c
./d1/d2/c.txt
rc=2
a.txt:hello
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Grep Recursive" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Grep Recursive" "${R}FAILED${N}";
		return 65536;
	}
}

fls_full() {
	./sh2elf scripts/test_ls_full.sh -o ls_full.elf >/dev/null 2>&1
	CAPTURE=$(./ls_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
lnk
run.sh
x~
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
lnk
run.sh
x~

.
..
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
.hidden
lnk
run.sh
x~
.y~
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
.hidden
lnk
run.sh
x~
.y~
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
lnk
run.sh
x~
apple	    dir2	 file-1.2.9
banana	    eggs.TXT	 lnk
cherry.txt  emptyd	 run.sh
dangling    fig10	 x~
date.c	    fig9
dir1	    file-1.2.10
apple	    banana    cherry.txt
dangling    date.c    dir1
dir2	    eggs.TXT  emptyd
fig10	    fig9      file-1.2.10
file-1.2.9  lnk       run.sh
x~
apple, banana, cherry.txt, dangling,
date.c, dir1, dir2, eggs.TXT, emptyd,
fig10, fig9, file-1.2.10, file-1.2.9,
lnk, run.sh, x~
apple, banana, cherry.txt, dangling, date.c, dir1, dir2, eggs.TXT, emptyd,
fig10, fig9, file-1.2.10, file-1.2.9, lnk, run.sh, x~
apple
banana
cherry.txt
dangling@
date.c
dir1/
dir2/
eggs.TXT
emptyd/
fig10
fig9
file-1.2.10
file-1.2.9
lnk@
run.sh*
x~
apple
banana
cherry.txt
dangling
date.c
dir1/
dir2/
eggs.TXT
emptyd/
fig10
fig9
file-1.2.10
file-1.2.9
lnk
run.sh
x~
x~
run.sh
lnk
file-1.2.9
file-1.2.10
fig9
fig10
emptyd
eggs.TXT
dir2
dir1
date.c
dangling
cherry.txt
banana
apple
dir1
dir2
emptyd
banana
run.sh
dangling
apple
lnk
cherry.txt
date.c
eggs.TXT
fig10
fig9
file-1.2.10
file-1.2.9
x~
cherry.txt
banana
apple
date.c
date.c
apple
banana
cherry.txt
apple
banana
cherry.txt
date.c
cherry.txt
banana
apple
date.c
date.c
cherry.txt
banana
apple
dir1
dir2
run.sh*

dir1:

dir2:
dangling@
lnk@
run.sh*
apple
banana
cherry.txt
dangling
date.c
dir1/
dir2/
eggs.TXT
emptyd/
fig10
fig9
file-1.2.10
file-1.2.9
.hidden
lnk
run.sh
x~
.y~
apple
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
.hidden
lnk
run.sh
x~
.y~
apple
banana
cherry.txt
dangling
date.c
dir1
dir2
eggs.TXT
emptyd
fig10
fig9
file-1.2.10
file-1.2.9
lnk
run.sh
x~
apple  banana  cherry.txt   dangling	date.c	dir1	dir2  eggs.TXT	emptyd
fig10  fig9    file-1.2.10  file-1.2.9	lnk	run.sh	x~
ls: nofile: No such file or directory
rc=2
ls: nofile: No such file or directory
apple
banana
rc=2
ls: -a: No such file or directory
apple
rc=2
ls: invalid option -- 'y'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'X'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'v'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'U'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'B'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'h'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'Q'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'b'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'N'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'G'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'Z'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'D'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'I'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'w'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'T'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "ls full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "ls full" "${R}FAILED${N}";
		return 131072;
	}
}

fls_quote() {
	./sh2elf scripts/test_ls_quote.sh -o ls_quote.elf >/dev/null 2>&1
	CAPTURE=$(./ls_quote.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a:b
back\sl
dq"x
éte
#h
it's
nl
x
plain
q?m
sp ace
st*r
tab	x
x=y
a:b
back\sl
dq"x
éte
#h
it's
nl?x
plain
q?m
sp ace
st*r
tab?x
x=y
a:b
back\sl
dq"x
éte
#h
it's
nl?x
plain
q?m
sp ace
st*r
tab?x
x=y
a:b
back\sl
dq"x
éte
#h
it's
nl?x
plain
q?m
sp ace
st*r
tab?x
x=y
a:b, back\sl, dq"x, éte, #h, it's, nl?x, plain, q?m, sp ace, st*r, tab?x, x=y
a:b	 dq"x  #h    nl?x   q?m     st*r   x=y
back\sl  éte   it's  plain  sp ace  tab?x
a:b  back\sl  dq"x  éte    #h	it's  nl?x  plain
q?m  sp ace   st*r  tab?x  x=y
a:b, back\sl, dq"x, éte, #h, it's, nl?x,
plain, q?m, sp ace, st*r, tab?x, x=y
a:b
back\sl
dq"x
éte
#h
it's
nl?x
plain
q?m
sp ace
st*r
tab?x
x=y
ls: invalid option -- 'Q'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'b'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'N'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "ls quoting" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "ls quoting" "${R}FAILED${N}";
		return 262144;
	}
}

fls_long() {
	./sh2elf scripts/test_ls_long.sh -o ls_long.elf >/dev/null 2>&1
	CAPTURE=$(./ls_long.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
-rw-r----- 2       6 Feb 13  2009 a
-rw-r--r-- 1    5000 Feb 13  2009 big
lrwxrwxrwx 1       7 Feb 13  2009 dangling -> nowhere
-rwxr-xr-x 1      10 Feb 13  2009 exe
-rw-r----- 2       6 Feb 13  2009 hard
-rw-r--r-- 1 3000000 Feb 13  2009 huge
lrwxrwxrwx 1       1 Feb 13  2009 lnk -> a
-rwxr-sr-x 1       0 Feb 13  2009 sgid
-rw-r--r-T 1       0 Feb 13  2009 sticky
-rwsr-xr-x 1       0 Feb 13  2009 suid
-rw-r----- 2  6 Feb 13  2009 a
lrwxrwxrwx 1  7 Feb 13  2009 dangling -> nowhere
-rwxr-xr-x 1 10 Feb 13  2009 exe*
lrwxrwxrwx 1  1 Feb 13  2009 lnk -> a
-rw-r----- 2 6 Feb 13  2009 a
lrwxrwxrwx 1 1 Feb 13  2009 lnk -> a
-rw-r----- 2 6 Feb 13  2009 lnk
ls: dangling: No such file or directory
-rw-r----- 2 6 Feb 13  2009 lnk
rc=2
-rw-r----- 2 6 Feb 13  2009 a
-rw-r----- 2 6 Feb 13  2009 hard
-rw-r----- 2 6 Feb 13  2009 a
-rw-r--r-- 1 3000000 Feb 13  2009 huge
-rw-r--r-- 1    5000 Feb 13  2009 big
-rwxr-xr-x 1      10 Feb 13  2009 exe
-rw-r----- 2       6 Feb 13  2009 a
-rw-r----- 2       6 Feb 13  2009 a
-rwxr-xr-x 1      10 Feb 13  2009 exe
-rw-r--r-- 1    5000 Feb 13  2009 big
-rw-r--r-- 1 3000000 Feb 13  2009 huge
-rw-r----- 2       6 Feb 13  2009 a
-rw-r--r-- 1    5000 Feb 13  2009 big
-rwxr-xr-x 1      10 Feb 13  2009 exe
-rw-r--r-- 1 3000000 Feb 13  2009 huge
-rw-r----- 2       6 Feb 13  2009 a
-rw-r--r-- 1    5000 Feb  3  2001 big
-rw-r--r-- 1 3000000 Dec 31  1969 huge
-rw-r----- 2       6 Feb 13  2009 a
-rw-r--r-- 1    5000 Feb  3  2001 big
-rw-r--r-- 1 3000000 Dec 31  1969 huge
-rw-r--r-- 1 3000000 Dec 31  1969 huge
-rw-r--r-- 1    5000 Feb  3  2001 big
-rw-r----- 2       6 Feb 13  2009 a
-rw-r----- 2       6 Feb 14  2009 a
-rw-r--r-- 1    5000 Feb  3  2001 big
-rw-r--r-- 1 3000000 Jan  1  1970 huge
-rw-r----- 2 6 Feb 13  2009 a
rc=0
ls: invalid option -- 'h'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'Z'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'D'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- '-'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
ls: invalid option -- 'G'
usage: ls [-ikqrs] [-glno] [-A|-a] [-C|-m|-x|-1] [-F|-p] [-H|-L] [-R|-d] [-S|-f|-t] [-c|-u] [file...]
rc=2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "ls long format" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "ls long format" "${R}FAILED${N}";
		return 524288;
	}
}

fls_rec() {
	./sh2elf scripts/test_ls_rec.sh -o ls_rec.elf >/dev/null 2>&1
	CAPTURE=$(./ls_rec.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
top:
f1
sub1
sub2

top/sub1:
deep
f2

top/sub1/deep:
f3

top/sub2:
up
top/sub2:
.
..
.h
up
other:
o1

top:
f1
sub1
sub2

top/sub1:
deep
f2

top/sub1/deep:
f3

top/sub2:
up
top/sub1:
deep
f2

top/sub1/deep:
f3
top/f1

other:
o1

top:
f1
sub1
sub2
other
top
top/sub2:
up

top/sub2/up:
f1
sub1
sub2

top/sub2/up/sub1:
deep
f2

top/sub2/up/sub1/deep:
f3
rc=2
top/sub1/deep:
f3
rc=2
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "ls recursive" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "ls recursive" "${R}FAILED${N}";
		return 1048576;
	}
}

ffind_full() {
	./sh2elf scripts/test_find_full.sh -o find_full.elf >/dev/null 2>&1
	CAPTURE=$(./find_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
.
./alpha
./a.txt
./big.bin
./d1
./d1/mid.dat
./d1/s1
./d1/s1/deep
./d1/s1/deep/f2
./d1/s1/f1
./d2
./d2/.hid
./d2/vis
./dang
./dl
./empty
./it's
./lnk
./sp ace
./x~
./Zeta
./a.txt
./Zeta
./alpha
.
./d1
./d1/s1
./d1/s1/deep
./d2
./empty
./dang
./dl
./lnk
./dang
dang
dl
dl/s1
dl/s1/deep
./big.bin
./alpha
./a.txt
./d1/s1/deep/f2
./d1/s1/f1
./d2/.hid
./d2/vis
./it's
./sp ace
./x~
./Zeta
./d1/mid.dat
./big.bin
./alpha
./Zeta
./alpha
./a.txt
./big.bin
./d1/mid.dat
./d1/s1/deep/f2
./d1/s1/f1
./d2/.hid
./d2/vis
./it's
./sp ace
./x~
.
./d1
./d1/s1
./alpha
./a.txt
./big.bin
./d2/.hid
./d2/vis
./it's
./sp ace
./x~
./Zeta
d1/mid.dat
d1/s1/f1
d1/s1/deep/f2
d1/s1/deep
d1/s1
d1
d1/mid.dat
d1/s1/f1
d1/s1/deep/f2
d1/s1/deep
d1
d1/./mid.dat
d1/./s1
.
./alpha
./a.txt
./big.bin
./d1/mid.dat
./d1/s1/deep/f2
./d1/s1/f1
./d2/.hid
./d2/vis
./it's
./sp ace
./x~
./Zeta
./alpha
./a.txt
./big.bin
./d1/mid.dat
./d1/s1/deep/f2
./d1/s1/f1
./d2/vis
./dang
./dl
./it's
./lnk
./sp ace
./x~
./alpha
./a.txt
./big.bin
./alpha
./a.txt
./big.bin
./big.bin
./d1/mid.dat
./d2/.hid
./d2/vis
./it's
0000000   d   1   /   s   1   /   f   1  \0
0000011
a.txt
find: nonexist: No such file or directory
rc=1
find: -name: missing argument
usage: find [-H|-L] path... [operand_expression...]
rc=1
find: -badpred: unknown primary or operator
usage: find [-H|-L] path... [operand_expression...]
rc=1
find: -type: invalid argument: q
usage: find [-H|-L] path... [operand_expression...]
find: syntax error: missing )
usage: find [-H|-L] path... [operand_expression...]
find: syntax error: expected an expression after -o
usage: find [-H|-L] path... [operand_expression...]
find: -size: invalid argument: 1k
usage: find [-H|-L] path... [operand_expression...]
find: -mtime: invalid argument: 1.5
usage: find [-H|-L] path... [operand_expression...]
find: -perm: invalid mode: /4000
usage: find [-H|-L] path... [operand_expression...]
find: -user: unknown user: no_such_user_x
rc=1
find: nonexist: No such file or directory
rc=1
dl
dl/s1
dl/s1/deep
find: -maxdepth: unknown primary or operator
find: -mindepth: unknown primary or operator
find: -xtype: unknown primary or operator
find: -empty: unknown primary or operator
find: -printf: unknown primary or operator
find: -quit: unknown primary or operator
find: -delete: unknown primary or operator
find: -regex: unknown primary or operator
find: -ls: unknown primary or operator
find: -fprint: unknown primary or operator
find: -samefile: unknown primary or operator
find: -inum: unknown primary or operator
find: -newermt: unknown primary or operator
find: -mmin: unknown primary or operator
find: -true: unknown primary or operator
find: -false: unknown primary or operator
find: -not: unknown primary or operator
find: -and: unknown primary or operator
find: -or: unknown primary or operator
find: -execdir: unknown primary or operator
find: -okdir: unknown primary or operator
find: -files0-from: unknown primary or operator
find: -readable: unknown primary or operator
find: -lname: unknown primary or operator
find: -wholename: unknown primary or operator
find: -ipath: unknown primary or operator
find: -fstype: unknown primary or operator
find: -D: unknown primary or operator
find: -O3: unknown primary or operator
find: -P: unknown primary or operator
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Find Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find Full" "${R}FAILED${N}";
		return 2097152;
	}
}

ffind_exec() {
	./sh2elf scripts/test_find_exec.sh -o find_exec.elf >/dev/null 2>&1
	CAPTURE=$(./find_exec.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
X ./a.txt
X ./b.txt
X ./d1/c.txt
X ./d1/s1/d.txt
X ./d2/e.txt
./a.txt
./b.txt
./d1/c.txt
./d1/s1/d.txt
./d2/e.txt
xa.txty a.txta.txt
SCRIPT a.txt
NOSHEBANG a.txt
find: nosuchcmd: No such file or directory
a.txt
rc=1
rc=0
+
a.txt d2 d2/e.txt
E a.txt d2 d2/e.txt
D d1
D d1/s1
F d1/c.txt
F d1/s1/d.txt
find: -exec: only one {} is allowed with +
usage: find [-H|-L] path... [operand_expression...]
find: -exec: missing argument
usage: find [-H|-L] path... [operand_expression...]
find: -exec: missing argument
usage: find [-H|-L] path... [operand_expression...]
find: -exec: missing argument
usage: find [-H|-L] path... [operand_expression...]
< echo ... a.txt > ? OK a.txt
< echo ... b.txt > ? < echo ... a.txt > ? a.txt
find: -ok: missing argument
usage: find [-H|-L] path... [operand_expression...]
find: -execdir: unknown primary or operator
usage: find [-H|-L] path... [operand_expression...]
find: -files0-from: unknown primary or operator
usage: find [-H|-L] path... [operand_expression...]
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Find Exec" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find Exec" "${R}FAILED${N}";
		return 4194304;
	}
}

ffind_pattern() {
	./sh2elf scripts/test_find_pattern.sh -o find_pattern.elf >/dev/null 2>&1
	CAPTURE=$(./find_pattern.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
./a1
./a22
./aaa
./abab
./abc
./abd
./a1
./abab
./abc
./abd
.
./Abc
./[br]
./éclair
./file.tar.gz
./file.txt
./.hid
./q?m
./README
./*star
./x y
./Abc
./README
./x y
./*star
./q?m
./[br]
.
./file.tar.gz
./file.txt
./.hid
.
./.hid
.
./Abc
./[br]
./file.txt
./.hid
./q?m
./README
./x y
./abc
./Abc
./éclair
./abc
./Abc
./a1
./a22
./aaa
./abab
./abc
./abd
./file.tar.gz
.
./abab
find: -regex: unknown primary or operator
find: -iregex: unknown primary or operator
find: -regextype: unknown primary or operator
find: -wholename: unknown primary or operator
find: -iwholename: unknown primary or operator
find: -ipath: unknown primary or operator
find: -lname: unknown primary or operator
find: -ilname: unknown primary or operator
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Find Patterns" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find Patterns" "${R}FAILED${N}";
		return 8388608;
	}
}

ffind_time() {
	./sh2elf scripts/test_find_time.sh -o find_time.elf >/dev/null 2>&1
	CAPTURE=$(./find_time.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
./future
./mid
./midns
./old2
./future
./mid
./midns
./future
./midns
./mid
./moon
./old
./old2
./mid
./midns
./moon
./old
./old2
.
./fresh
./future
./fresh
./fresh
./future
./old
.
./fresh
./future
./mid
./midns
./moon
./old
./old2
find: -mtime: invalid argument: x
usage: find [-H|-L] path... [operand_expression...]
find: -newermt: unknown primary or operator
usage: find [-H|-L] path... [operand_expression...]
find: -anewer: unknown primary or operator
usage: find [-H|-L] path... [operand_expression...]
find: -daystart: unknown primary or operator
usage: find [-H|-L] path... [operand_expression...]
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Find Time" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find Time" "${R}FAILED${N}";
		return 16777216;
	}
}

fxargs_full() {
	./sh2elf scripts/test_xargs_full.sh -o xargs_full.elf >/dev/null 2>&1
	CAPTURE=$(./xargs_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a b c
X a b c
N a b
N c d
N e
L l1 a
L l2 b
L l3 c
L l1 a l2 b
L l3 c
L l1 l2
L l3
a b
c d
e f
ab cd
e
a
b c
d
X a
X 
X b
a b
a b
a _ b
a
a b
empty
blank
aaaa bbbb
cccc
echo a b c
a b c
echo a b c d
a b c d
echo x y a
x y a
xargs: argument line too long
aaaa
bbbb
cccc
a b
a
b
{} a
{} b
a b
xargs: unmatched double quote
xargs: unmatched single quote
x
a b
xargs: nosuchcmd: No such file or directory
rc=127
rc=123
xargs: sh: exited with status 255; aborting
rc=124
xargs: sh: terminated by signal 15
rc=125
xargs: ./: Permission denied
rc=126
xargs: -s: invalid argument: 0
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: -n: invalid argument: 0
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: -L: invalid argument: 0
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: -n: invalid argument: x
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: -s: invalid argument: abc
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'q'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'i'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'l'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'd'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'a'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'P'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'o'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- 'e'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- '-'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- '-'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- '-'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- '-'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: invalid option -- '-'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
xargs: option requires an argument -- 'n'
usage: xargs [-prtx] [-E eofstr|-0] [-I replstr|-L number|-n number] [-s size] [utility [argument...]]
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Xargs Full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Xargs Full" "${R}FAILED${N}";
		return 33554432;
	}
}

fxargs_exec() {
	./sh2elf scripts/test_xargs_exec.sh -o xargs_exec.elf >/dev/null 2>&1
	CAPTURE=$(./xargs_exec.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
[x y] and x y
[z] and z
x yx y-x y
zz-z
[a  b]
[c]
2: one two
a
c
rc=123
a
b
c
d
done
echo F 1
F 1
echo F 2
F 2
echo F 3
F 3
echo [a b]
[a b]
echo [c]
[c]
5
923a707a733f6c84562b529886c97406  -
e4748ed75e6bcb477c62fbd7f23bdafa  -
e4389a7129bb0d8f7434bbf6dc7c373e  -
ebd1c732d13ccf2f495f7f05cd593067  -
1 2 3 4 5 6 7
8 9 10
1 2 3 4 5 6 7
8 9 10
a
xargs: sh: exited with status 255; aborting
rc=124
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Xargs Exec" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Xargs Exec" "${R}FAILED${N}";
		return 67108864;
	}
}

fcp_full() {
	./sh2elf scripts/test_cp_full.sh -o cp_full.elf >/dev/null 2>&1
	CAPTURE=$(./cp_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
hello
hello
hello
hello
hello
cp: cannot stat nonexist: No such file or directory
rc=1
cp: -R not specified; omitting directory d
rc=1
cp: a and a are the same file
rc=1
cp: missing file operand
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: missing destination file operand after a
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: target c: No such file or directory
rc=1
cp: cannot create regular file nodir/: Not a directory
rc=1
cp: target nodir: No such file or directory
rc=1
in d
sub
cp: overwrite n? 
hello
cp: overwrite n? 
rc=0
hello
hello
cp: cannot create regular file ro: Permission denied
rc=1
hello
rc=0
hello
hello
cp: invalid option -- 'a'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'r'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'b'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'd'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'l'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'n'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 's'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'T'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'u'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'v'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'x'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'Z'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'k'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- '-'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 't'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
cp: invalid option -- 'S'
usage: cp [-Pfip] source_file target_file
       cp [-Pfip] source_file... target
       cp -R [-H|-L|-P] [-fip] source_file... target
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "cp full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "cp full" "${R}FAILED${N}";
		return 134217728;
	}
}

fcp_tree() {
	./sh2elf scripts/test_cp_tree.sh -o cp_tree.elf >/dev/null 2>&1
	CAPTURE=$(./cp_tree.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
z2/f1 664 981173106
z2/sub 750 981173106
z2/hard 664 981173106
z2/sub/f2 664 981173106
z2/lnk symbolic link
z2/fifo fifo
z1:
f1
fifo
hard
lnk
sub

z1/sub:
deep
f2

z1/sub/deep:
f3
e:
d

e/d:
f1
fifo
hard
lnk
sub

e/d/sub:
deep
f2

e/d/sub/deep:
f3
cp: cannot copy a directory, d, into itself, d/sub/d
rc=1
z3/lnk regular file
z3h/lnk symbolic link
z7 directory
z7/lnk symbolic link
z8 symbolic link
z9 symbolic link
664 981173106
f1
fifo
hard
lnk
sub
cp: cannot overwrite non-directory e/d/f1 with directory d
rc=1
cp: target z6: No such file or directory
rc=1
cp: cannot overwrite non-directory a with directory d
rc=1
cp: -R not specified; omitting directory dl
rc=1
z11 symbolic link
z12 regular file
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "cp tree" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "cp tree" "${R}FAILED${N}";
		return 268435456;
	}
}

fmv_full() {
	./sh2elf scripts/test_mv_full.sh -o mv_full.elf >/dev/null 2>&1
	CAPTURE=$(./mv_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
hello
hello
a
f1
sub
a
hello
mv: cannot stat nonexist: No such file or directory
rc=1
mv: missing file operand
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: missing destination file operand after b
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: b and b are the same file
rc=1
mv: cannot move d to a subdirectory of itself, d/sub/d
rc=1
mv: cannot overwrite non-directory d/f1 with directory e
rc=1
f1
mv: cannot move a2 to nodir/: Not a directory
rc=1
rc=0
f1
sub
mv: overwrite m? 
rc=0
y
mv: overwrite m? 
x
mv: overwrite m? 
x
x
w
rc=0
e
m
ro
y
mv: invalid option -- 'b'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'n'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'u'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'v'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'T'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'Z'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'x'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 'k'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- '-'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
mv: invalid option -- 't'
usage: mv [-if] source_file target_file
       mv [-if] source_file... target_dir
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "mv full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "mv full" "${R}FAILED${N}";
		return 536870912;
	}
}

fmv_xdev() {
	./sh2elf scripts/test_mv_xdev.sh -o mv_xdev.elf >/dev/null 2>&1
	CAPTURE=$(./mv_xdev.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
/var/tmp/sh2elf_mv_xb/a 664 981173106
/var/tmp/sh2elf_mv_xb/d 775 981173106 3
/var/tmp/sh2elf_mv_xb/d/sub 750 981173106 2
/var/tmp/sh2elf_mv_xb/d/f1 664 981173106 2
/var/tmp/sh2elf_mv_xb/d/hard 664 981173106 2
/var/tmp/sh2elf_mv_xb/d/sub/f2 664 981173106 1
/var/tmp/sh2elf_mv_xb/d/lnk symbolic link
/tmp/sh2elf_mv_xa/d2:
f1
hard
lnk
sub

/tmp/sh2elf_mv_xa/d2/sub:
f2
a
b
x
mv: cannot overwrite directory /var/tmp/sh2elf_mv_xb/c with non-directory c
rc=1
mv: cannot remove ro/s/f: Permission denied
rc=1
ro/s:
f

/var/tmp/sh2elf_mv_xb/ro/s:
f
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "mv xdev" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "mv xdev" "${R}FAILED${N}";
		return 1073741824;
	}
}

frm_full() {
	./sh2elf scripts/test_rm_full.sh -o rm_full.elf >/dev/null 2>&1
	CAPTURE=$(./rm_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
b
c
d
e
ed
rm: cannot remove nonexist: No such file or directory
rc=1
rc=0
rm: missing operand
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rc=0
rm: invalid option -- 'k'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- 'I'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- 'x'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: invalid option -- '-'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: missing operand
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
rm: cannot remove d: Is a directory
rc=1
rm: cannot remove d: Directory not empty
rc=1
removed directory ed
rm: refusing to remove . or .. directory: skipping .
rc=1
rm: refusing to remove . or .. directory: skipping d/..
rc=1
removed directory d/sub
removed directory d/sub/deep
removed d/sub/deep/f3
removed d/sub/f2
rm: remove regular file b? 
b
c
d
e
rm: remove regular file b? removed b

c
d
e
rm: remove regular file p? rm: remove regular file q? 
c
d
e
p
q
r
s
rm: remove regular file p? rm: remove regular file q? removed p
removed q

c
d
e
rc=0
c
d
e
removed ro
rm: cannot remove w/x/k: Permission denied
rc=1
removed w/x/k
removed directory w/x
removed directory w
rm: descend into directory e? 
g
rm: invalid option -- 'o'
usage: rm [-diRrv] file...
       rm -f [-diRrv] [file...]
rc=1
removed -foo
removed d/lnk
removed d/f1
removed directory d
removed e/g
removed directory e
c
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "rm full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "rm full" "${R}FAILED${N}";
		return 1;
	}
}

fmkdir_full() {
	./sh2elf scripts/test_mkdir_full.sh -o mkdir_full.elf >/dev/null 2>&1
	CAPTURE=$(./mkdir_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a
file
mkdir: cannot create directory a: File exists
rc=1
a
b
c
file
mkdir: cannot create directory x/y: No such file or directory
rc=1
mkdir: missing operand
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- 'k'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: -m: invalid mode: bad
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: -m: invalid mode: 8
usage: mkdir [-p] [-m mode] dir...
rc=1
rc=0
p/q/r
p/q/s
u
mkdir: cannot create directory file: Not a directory
rc=1
mkdir: cannot create directory file: File exists
rc=1
v1
v2
mkdir: invalid option -- 'v'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- 'Z'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- 'x'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- '-'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- '-'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- '-'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- '-'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- '-'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: invalid option -- '-'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: option requires an argument -- 'm'
usage: mkdir [-p] [-m mode] dir...
rc=1
mkdir: missing operand
usage: mkdir [-p] [-m mode] dir...
rc=1
m1 700
m2 1777
m3 750
m4 555
m5 2777
m6 772
n1/n2 700
n3/n4 4757
n5/n6 0
q'uote
sp ace
mkdir: cannot create directory sp ace: File exists
rc=1
-dash
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "mkdir full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "mkdir full" "${R}FAILED${N}";
		return 2;
	}
}

frmdir_full() {
	./sh2elf scripts/test_rmdir_full.sh -o rmdir_full.elf >/dev/null 2>&1
	CAPTURE=$(./rmdir_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a
e
file
y
rmdir: missing operand
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- 'k'
usage: rmdir [-p] dir...
rc=1
rmdir: failed to remove nonexist: No such file or directory
rc=1
rmdir: failed to remove file: Not a directory
rc=1
rmdir: failed to remove e: Directory not empty
rc=1
rmdir: invalid option -- 'v'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- 'k'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- 'x'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- '-'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- '-'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- '-'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- '-'
usage: rmdir [-p] dir...
rc=1
rmdir: invalid option -- '-'
usage: rmdir [-p] dir...
rc=1
rmdir: missing operand
usage: rmdir [-p] dir...
rc=1
e
file
e
file
rmdir: failed to remove directory e: Directory not empty
rc=1
f
g
rmdir: failed to remove se/: Symbolic link not followed
rc=1
rmdir: failed to remove se: Not a directory
rc=1
rmdir: failed to remove file/: Not a directory
rc=1
rmdir: failed to remove .: Invalid argument
rc=1
e
file
se
rmdir: failed to remove sp ace: No such file or directory
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "rmdir full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "rmdir full" "${R}FAILED${N}";
		return 4;
	}
}

ftouch_full() {
	./sh2elf scripts/test_touch_full.sh -o touch_full.elf >/dev/null 2>&1
	CAPTURE=$(./touch_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
a 1000000000 1000000000
a 1000000000 981173106
2001-02-03 04:05:06
a 981173106
b 1000000000.5 1000000000.5
b2 1000000000.25 1000000000.25
201006011200.00
201006011200.00
201006011200.00
196901011200.00
i 1483228800
c 1000000000 1000000000
c 1000000000 981173106
rc=0
a
b
b2
c
d
f
g
h
h2
i
a 981173106
b 981173106
-x
-
touch: missing file operand
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: option requires an argument -- 'd'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- 'h'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- 'f'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- 'k'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- '-'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- '-'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- '-'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- '-'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- '-'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: invalid option -- '-'
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: -d: invalid date_time: bogus
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: -d: invalid date_time: @1000000000
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: -d: invalid date_time: 2001-01-01
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: -d: invalid date_time: 2001-02-30T00:00:00
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: -t: invalid time: 2005
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: -t: invalid time: 200502290000
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: failed to get attributes of nonexist: No such file or directory
rc=1
touch: cannot specify times from more than one source
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: cannot specify times from more than one source
usage: touch [-acm] [-r ref_file|-t time|-d date_time] file...
rc=1
touch: cannot touch nodir/x: No such file or directory
rc=1
touch: setting times of a/: Not a directory
rc=1
d 9
sp ace 9
q'uote 9
-
a
b
b2
c
d
f
g
h
h2
i
q'uote
sp ace
-x
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "touch full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "touch full" "${R}FAILED${N}";
		return 8;
	}
}

fchmod_full() {
	./sh2elf scripts/test_chmod_full.sh -o chmod_full.elf >/dev/null 2>&1
	CAPTURE=$(./chmod_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
rc=0
d 755
d/e 755
d/f 644
d/e/g 644
d/f 6644
rc=0
d/f 444
chmod: cannot operate on dangling symlink d/dg
rc=1
d/f 0
d/f 644
d/f 644
d/e 755
d/e/g 644
d/e/g 660
d/e 755
d/e/g 7777
d/e 755
d/e/g 1777
d/f 444
d/f 444
d/f 0
d/f 0
d/f 620
rc=0
d 755
d/e 755
d/f 755
d/e/g 755
chmod: missing operand
usage: chmod [-R] mode file...
rc=1
chmod: missing operand
usage: chmod [-R] mode file...
rc=1
chmod: missing operand after 755
usage: chmod [-R] mode file...
rc=1
chmod: missing operand after 755
usage: chmod [-R] mode file...
rc=1
chmod: invalid mode: xyz
usage: chmod [-R] mode file...
rc=1
chmod: invalid mode: u+q
usage: chmod [-R] mode file...
rc=1
chmod: invalid mode: ,u+x
usage: chmod [-R] mode file...
rc=1
chmod: invalid mode: +755
usage: chmod [-R] mode file...
rc=1
chmod: invalid mode: u=7
usage: chmod [-R] mode file...
rc=1
chmod: invalid mode: 017777
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'k'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'w'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'x'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'v'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'c'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'f'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'h'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'H'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'L'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'P'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- 'v'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- '-'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- '-'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- '-'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- '-'
usage: chmod [-R] mode file...
rc=1
chmod: invalid option -- '-'
usage: chmod [-R] mode file...
rc=1
chmod: cannot access nonexist: No such file or directory
rc=1
chmod: cannot access nonexist: No such file or directory
rc=1
chmod: cannot access -R: No such file or directory
rc=1
chmod: invalid option -- 'v'
usage: chmod [-R] mode file...
rc=1
d 755
rc=0
d 700
d/e 700
d/f 700
d/e/g 700
chmod: cannot access q'uote: No such file or directory
rc=1
d 700
d/e 700
d/f 700
d/e/g 700
sp ace 700
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "chmod full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "chmod full" "${R}FAILED${N}";
		return 16;
	}
}

fchown_full() {
	./sh2elf scripts/test_chown_full.sh -o chown_full.elf >/dev/null 2>&1
	CAPTURE=$(./chown_full.elf 2>/dev/null)
	EXPECTED=$(cat <<'EOF'
rc=0
rc=0
rc=0
rc=0
rc=0
rc=0
rc=0
chown: cannot dereference dg: No such file or directory
rc=1
chgrp: cannot dereference dg: No such file or directory
rc=1
rc=0
rc=0
rc=0
rc=0
rc=0
rc=0
rc=0
chown: cannot access --: No such file or directory
rc=1
chown: cannot access nonexist: No such file or directory
rc=1
chown: cannot access nonexist: No such file or directory
chown: cannot access nonexist2: No such file or directory
rc=1
chgrp: cannot access nonexist: No such file or directory
rc=1
chown: cannot access q'uote: No such file or directory
rc=1
chown: missing operand
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: missing operand
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: missing operand after root
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chgrp: missing operand
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chgrp: missing operand after root
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chown: invalid option -- 'k'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- 'v'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- 'c'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- 'f'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- 'v'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chown: invalid option -- '-'
usage: chown [-h] owner[:group] file...
       chown -R [-H|-L|-P] owner[:group] file...
rc=1
chgrp: invalid option -- 'v'
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chgrp: invalid option -- 'c'
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chgrp: invalid option -- 'f'
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chgrp: invalid option -- '-'
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chgrp: invalid option -- '-'
usage: chgrp [-h] group file...
       chgrp -R [-H|-L|-P] group file...
rc=1
chown: invalid user: 
rc=1
chown: invalid user: :
rc=1
chown: invalid user: :root
rc=1
chown: invalid group: root:
rc=1
chown: invalid user: root.root
rc=1
chown: invalid group: root:root:x
rc=1
chown: invalid user: +0
rc=1
chown: invalid user:  0
rc=1
chown: invalid user: 0x
rc=1
chown: invalid user: nosuchuser_x
rc=1
chown: invalid user: nosuchuser_x:
rc=1
chown: invalid group: root:nosuchgroup_x
rc=1
chown: invalid user: 4294967295
rc=1
chown: invalid group: 0:4294967295
rc=1
chown: invalid user: sp ace
rc=1
chgrp: invalid group: 
rc=1
chgrp: invalid group: :root
rc=1
chgrp: invalid group: root:
rc=1
chgrp: invalid group: +0
rc=1
chgrp: invalid group: 4294967296
rc=1
chgrp: invalid group: nosuchgroup_x
rc=1
chgrp: invalid group: sp ace
rc=1
EOF
)
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "chown full" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "chown full" "${R}FAILED${N}";
		return 32;
	}
}

{ fhello && fpipe && flogic && ftruefalse && fpwd && fstderr && fmkdir && frmdir && funlink && fsleep && ftestcmd && fexport && fcat && fhead && fwc && fkill && ftouch && fchmod && fbasename && fvars && fdirname && fprintf && fsubshell && fgroup && fif && fwhile && ffor && funtil && fread && funset && fcp && fmv && frm && ftee && fexpr && fparamexp && fcase && fheredoc && fcmdsub && farith && fglob && ffunc && funame && fwhoami && fid && fenv && flscmd && fgrep && ftr && fcut && fsort && funiq && ffind && fxargs && fsed && fawk && ftail && fchown && fchgrp && fgrepi && fgrepv && fgrepn && fgrepc && fheadn && ftailn && fcutdf && fsortr && fsortu && funiqc && funiqd && fwcl && fwcw && ffindname && fps && fkillall && fpgrep && fpkill && fnice && ftime && ftar && fgzip && fgunzip && fexprops && fpatternexp && fgetopts && feval && fshift && fpathexec && fhuge && fcompound_operands && floop_control && ftrap_signals && ffunc_return && fset_flags && fparam_assign_alt && ffd_redirs && fselect_loop && fproc_sub && fifs_splitting && farith_full && farith_cmd && fwhile_loop && fbrace_exp && fparam_ext && fansi_quote && fherestring && fnegation && fbackground && fruntime_params && ffunc_args && fcase_alt && ftest_ext && fecho_opts && fdquote_exp && frev && fnl && ftac && ffold && fbase64 && fprintf_full && fxxd && fcmp && fcksum && fseq && fyes && ffactor && fhostname && fnproc && fprintenv && freadlink && fln && ftruncate && fhead_full && fbig_input && ftail_full && ftail_follow && fwc_full && fcut_posix && fcut_full && ftr_full && ftr_posix && funiq_full && fsort_full && fsort_posix && fgrep_full && fgrep_regex && fgrep_rec && fls_full && fls_quote && fls_long && fls_rec && ffind_full && ffind_exec && ffind_pattern && ffind_time && fxargs_full && fxargs_exec && fcp_full && fcp_tree && fmv_full && fmv_xdev && frm_full && fmkdir_full && frmdir_full && ftouch_full && fchmod_full && fchown_full; RETURN="${?}"; } || exit 1

[ "${RETURN}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RETURN}"
