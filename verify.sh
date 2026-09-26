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

ftruefalse() {
	./sh2elf scripts/test_truefalse.sh -o tf.elf >/dev/null
	CAPTURE=$(./tf.elf)
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
	./sh2elf scripts/test_pwd.sh -o pwd.elf >/dev/null
	CAPTURE=$(./pwd.elf)
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
	./sh2elf scripts/test_stderr.sh -o err.elf >/dev/null
	CAPTURE=$(./err.elf)
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
	./sh2elf scripts/test_mkdir.sh -o mkdir.elf >/dev/null
	CAPTURE=$(./mkdir.elf)
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
	./sh2elf scripts/test_rmdir.sh -o rmdir.elf >/dev/null
	CAPTURE=$(./rmdir.elf)
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
	./sh2elf scripts/test_unlink.sh -o unlink.elf >/dev/null
	CAPTURE=$(./unlink.elf)
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
	./sh2elf scripts/test_sleep.sh -o sleep.elf >/dev/null
	CAPTURE=$(./sleep.elf)
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
	./sh2elf scripts/test_testcmd.sh -o testcmd.elf >/dev/null
	CAPTURE=$(./testcmd.elf)
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
	./sh2elf scripts/test_export.sh -o export.elf >/dev/null
	CAPTURE=$(./export.elf)
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
	./sh2elf scripts/test_cat.sh -o cat.elf >/dev/null
	CAPTURE=$(./cat.elf)
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
	./sh2elf scripts/test_head.sh -o head.elf >/dev/null
	CAPTURE=$(./head.elf)
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
	./sh2elf scripts/test_wc.sh -o wc.elf >/dev/null
	CAPTURE=$(./wc.elf)
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
	./sh2elf scripts/test_kill.sh -o kill.elf >/dev/null
	CAPTURE=$(./kill.elf)
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
	./sh2elf scripts/test_touch.sh -o touch.elf >/dev/null
	CAPTURE=$(./touch.elf)
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
	./sh2elf scripts/test_chmod.sh -o chmod.elf >/dev/null
	CAPTURE=$(./chmod.elf)
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
	./sh2elf scripts/test_basename.sh -o base.elf >/dev/null
	CAPTURE=$(./base.elf)
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
	./sh2elf scripts/test_vars.sh -o vars.elf >/dev/null
	CAPTURE=$(./vars.elf)
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
	./sh2elf scripts/test_dirname.sh -o dirname.elf >/dev/null
	CAPTURE=$(./dirname.elf)
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
	./sh2elf scripts/test_printf.sh -o printf.elf >/dev/null
	CAPTURE=$(./printf.elf)
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
	./sh2elf scripts/test_subshell.sh -o subshell.elf >/dev/null
	CAPTURE=$(./subshell.elf)
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
	./sh2elf scripts/test_group.sh -o group.elf >/dev/null
	CAPTURE=$(./group.elf)
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
	./sh2elf scripts/test_if.sh -o if.elf >/dev/null
	CAPTURE=$(./if.elf)
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
	./sh2elf scripts/test_while.sh -o while.elf >/dev/null
	CAPTURE=$(./while.elf)
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
	./sh2elf scripts/test_for.sh -o for.elf >/dev/null
	CAPTURE=$(./for.elf)
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
	./sh2elf scripts/test_until.sh -o until.elf >/dev/null
	CAPTURE=$(./until.elf)
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
	./sh2elf scripts/test_read.sh -o read.elf >/dev/null
	echo "testinput" | ./read.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Read Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Read Cmd" "${R}FAILED${N}";
		return 1;
	}
}

funset() {
	./sh2elf scripts/test_unset.sh -o unset.elf >/dev/null
	CAPTURE=$(./unset.elf)
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
	./sh2elf scripts/test_cp.sh -o cp.elf >/dev/null
	./cp.elf
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
	./sh2elf scripts/test_mv.sh -o mv.elf >/dev/null
	./mv.elf
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
	./sh2elf scripts/test_rm.sh -o rm.elf >/dev/null
	./rm.elf
	[ ! -f /tmp/sh2elf_rm_file.txt ] && {
		fprint "Rm Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Rm Cmd" "${R}FAILED${N}";
		return 16;
	}
}

ftee() {
	./sh2elf scripts/test_tee.sh -o tee.elf >/dev/null
	CAPTURE=$(echo "teedata" | ./tee.elf)
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
	./sh2elf scripts/test_expr.sh -o expr.elf >/dev/null
	CAPTURE=$(./expr.elf)
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
	./sh2elf scripts/test_param_exp.sh -o paramexp.elf >/dev/null
	CAPTURE=$(./paramexp.elf)
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
	./sh2elf scripts/test_case.sh -o case.elf >/dev/null
	CAPTURE=$(./case.elf)
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
	./sh2elf scripts/test_heredoc.sh -o heredoc.elf >/dev/null
	CAPTURE=$(./heredoc.elf)
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
	./sh2elf scripts/test_cmdsub.sh -o cmdsub.elf >/dev/null
	CAPTURE=$(./cmdsub.elf)
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
	./sh2elf scripts/test_arith.sh -o arith.elf >/dev/null
	CAPTURE=$(./arith.elf)
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
	./sh2elf scripts/test_glob.sh -o glob.elf >/dev/null
	CAPTURE=$(./glob.elf)
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
	./sh2elf scripts/test_func.sh -o func.elf >/dev/null
	CAPTURE=$(./func.elf)
	EXPECTED="in_func"
	[ "${CAPTURE}" = "${EXPECTED}" ] && {
		fprint "Shell Func" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Shell Func" "${R}FAILED${N}";
		return 8192;
	}
}

funame() {
	./sh2elf scripts/test_uname.sh -o uname.elf >/dev/null
	CAPTURE=$(./uname.elf)
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
	./sh2elf scripts/test_whoami.sh -o whoami.elf >/dev/null
	./whoami.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Whoami Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Whoami Cmd" "${R}FAILED${N}";
		return 32768;
	}
}

fid() {
	./sh2elf scripts/test_id.sh -o id.elf >/dev/null
	./id.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Id Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Id Cmd" "${R}FAILED${N}";
		return 65536;
	}
}

fenv() {
	./sh2elf scripts/test_env.sh -o env.elf >/dev/null
	./env.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Env Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Env Cmd" "${R}FAILED${N}";
		return 131072;
	}
}

flscmd() {
	./sh2elf scripts/test_ls.sh -o ls.elf >/dev/null
	./ls.elf >/dev/null
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
	./sh2elf scripts/test_grep.sh -o grep.elf >/dev/null
	CAPTURE=$(./grep.elf)
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
	./sh2elf scripts/test_tr.sh -o tr.elf >/dev/null
	CAPTURE=$(echo "abc" | ./tr.elf)
	[ "${CAPTURE}" = "zbc" ] && {
		fprint "Tr Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tr Cmd" "${R}FAILED${N}";
		return 1048576;
	}
}

fcut() {
	./sh2elf scripts/test_cut.sh -o cut.elf >/dev/null
	CAPTURE=$(echo "col1 col2" | ./cut.elf)
	[ "${CAPTURE}" = "col1 col2" ] && {
		fprint "Cut Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Cut Cmd" "${R}FAILED${N}";
		return 2097152;
	}
}

fsort() {
	./sh2elf scripts/test_sort.sh -o sort.elf >/dev/null
	CAPTURE=$(echo "sorted" | ./sort.elf)
	[ "${CAPTURE}" = "sorted" ] && {
		fprint "Sort Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sort Cmd" "${R}FAILED${N}";
		return 4194304;
	}
}

funiq() {
	./sh2elf scripts/test_uniq.sh -o uniq.elf >/dev/null
	CAPTURE=$(echo "unique" | ./uniq.elf)
	[ "${CAPTURE}" = "unique" ] && {
		fprint "Uniq Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Uniq Cmd" "${R}FAILED${N}";
		return 8388608;
	}
}

ffind() {
	./sh2elf scripts/test_find.sh -o find.elf >/dev/null
	./find.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Find Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find Cmd" "${R}FAILED${N}";
		return 16777216;
	}
}

fxargs() {
	./sh2elf scripts/test_xargs.sh -o xargs.elf >/dev/null
	CAPTURE=$(echo "xargs_test" | ./xargs.elf)
	[ "${CAPTURE}" = "xargs_test" ] && {
		fprint "Xargs Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Xargs Cmd" "${R}FAILED${N}";
		return 33554432;
	}
}

fsed() {
	./sh2elf scripts/test_sed.sh -o sed.elf >/dev/null
	CAPTURE=$(echo "sed_test" | ./sed.elf)
	[ "${CAPTURE}" = "sed_test" ] && {
		fprint "Sed Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Sed Cmd" "${R}FAILED${N}";
		return 67108864;
	}
}

fawk() {
	./sh2elf scripts/test_awk.sh -o awk.elf >/dev/null
	CAPTURE=$(echo "awk_test" | ./awk.elf)
	[ "${CAPTURE}" = "awk_test" ] && {
		fprint "Awk Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Awk Cmd" "${R}FAILED${N}";
		return 134217728;
	}
}

ftail() {
	./sh2elf scripts/test_tail.sh -o tail.elf >/dev/null
	CAPTURE=$(echo "tail_test" | ./tail.elf)
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
	./sh2elf scripts/test_chown.sh -o chown.elf >/dev/null
	./chown.elf >/dev/null
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
	./sh2elf scripts/test_chgrp.sh -o chgrp.elf >/dev/null
	./chgrp.elf >/dev/null
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
	./sh2elf scripts/test_grep_i.sh -o grepi.elf >/dev/null
	CAPTURE=$(./grepi.elf)
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
	./sh2elf scripts/test_grep_v.sh -o grepv.elf >/dev/null
	CAPTURE=$(./grepv.elf)
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
	./sh2elf scripts/test_grep_n.sh -o grepn.elf >/dev/null
	CAPTURE=$(./grepn.elf)
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
	./sh2elf scripts/test_grep_c.sh -o grepc.elf >/dev/null
	CAPTURE=$(./grepc.elf)
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
	./sh2elf scripts/test_head_n.sh -o headn.elf >/dev/null
	CAPTURE=$(./headn.elf)
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
	./sh2elf scripts/test_tail_n.sh -o tailn.elf >/dev/null
	CAPTURE=$(./tailn.elf)
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
	./sh2elf scripts/test_cut_df.sh -o cutdf.elf >/dev/null
	./cutdf.elf >/dev/null
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
	./sh2elf scripts/test_sort_r.sh -o sortr.elf >/dev/null
	./sortr.elf >/dev/null
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
	./sh2elf scripts/test_sort_u.sh -o sortu.elf >/dev/null
	./sortu.elf >/dev/null
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
	./sh2elf scripts/test_uniq_c.sh -o uniqc.elf >/dev/null
	./uniqc.elf >/dev/null
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
	./sh2elf scripts/test_uniq_d.sh -o uniqd.elf >/dev/null
	./uniqd.elf >/dev/null
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
	./sh2elf scripts/test_wc_l.sh -o wcl.elf >/dev/null
	./wcl.elf >/dev/null
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
	./sh2elf scripts/test_wc_w.sh -o wcw.elf >/dev/null
	./wcw.elf >/dev/null
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
	./sh2elf scripts/test_find_name.sh -o findname.elf >/dev/null
	./findname.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Find -name Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Find -name Cmd" "${R}FAILED${N}";
		return 8192;
	}
}

fps() {
	./sh2elf scripts/test_ps.sh -o ps.elf >/dev/null
	./ps.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Ps Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Ps Cmd" "${R}FAILED${N}";
		return 16384;
	}
}

fkillall() {
	./sh2elf scripts/test_killall.sh -o killall.elf >/dev/null
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
	./sh2elf scripts/test_pgrep.sh -o pgrep.elf >/dev/null
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
	./sh2elf scripts/test_pkill.sh -o pkill.elf >/dev/null
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
	./sh2elf scripts/test_nice.sh -o nice.elf >/dev/null
	./nice.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Nice Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Nice Cmd" "${R}FAILED${N}";
		return 262144;
	}
}

ftime() {
	./sh2elf scripts/test_time.sh -o time.elf >/dev/null
	./time.elf >/dev/null
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
	./sh2elf scripts/test_tar.sh -o tar.elf >/dev/null
	./tar.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Tar Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Tar Cmd" "${R}FAILED${N}";
		return 1048576;
	}
}

fgzip() {
	echo "gzip content" > /tmp/sh2elf_gzip.txt
	./sh2elf scripts/test_gzip.sh -o gzip.elf >/dev/null
	./gzip.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Gzip Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Gzip Cmd" "${R}FAILED${N}";
		return 2097152;
	}
}

fgunzip() {
	echo "gunzip content" > /tmp/sh2elf_gunzip.txt
	./sh2elf scripts/test_gunzip.sh -o gunzip.elf >/dev/null
	./gunzip.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Gunzip Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Gunzip Cmd" "${R}FAILED${N}";
		return 4194304;
	}
}

fexprops() {
	./sh2elf scripts/test_expr_ops.sh -o exprops.elf >/dev/null
	CAPTURE=$(./exprops.elf)
	[ "${CAPTURE}" = "1" ] && {
		fprint "Expr Ops Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Expr Ops Cmd" "${R}FAILED${N}";
		return 8388608;
	}
}

fpatternexp() {
	./sh2elf scripts/test_pattern_exp.sh -o patternexp.elf >/dev/null
	./patternexp.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Pattern Exp Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Pattern Exp Cmd" "${R}FAILED${N}";
		return 16777216;
	}
}

fgetopts() {
	./sh2elf scripts/test_getopts.sh -o getopts.elf >/dev/null
	./getopts.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Getopts Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Getopts Cmd" "${R}FAILED${N}";
		return 33554432;
	}
}

feval() {
	./sh2elf scripts/test_eval.sh -o eval.elf >/dev/null
	CAPTURE=$(./eval.elf)
	[ "${CAPTURE}" = "EVAL_SUCCESS" ] && {
		fprint "Eval Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Eval Cmd" "${R}FAILED${N}";
		return 67108864;
	}
}

fshift() {
	./sh2elf scripts/test_shift.sh -o shift.elf >/dev/null
	CAPTURE=$(./shift.elf)
	[ "${CAPTURE}" = "SHIFT_OK" ] && {
		fprint "Shift Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Shift Cmd" "${R}FAILED${N}";
		return 134217728;
	}
}

fpathexec() {
	./sh2elf scripts/test_pathexec.sh -o pathexec.elf >/dev/null
	CAPTURE=$(./pathexec.elf)
	[ "${CAPTURE}" = "PATH_EXEC_OK" ] && {
		fprint "Path Exec Cmd" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Path Exec Cmd" "${R}FAILED${N}";
		return 268435456;
	}
}

fhuge() {
	./sh2elf scripts/test_huge_comprehensive.sh -o huge.elf >/dev/null
	./huge.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Huge Test Script" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Huge Test Script" "${R}FAILED${N}";
		return 536870912;
	}
}

fcompound_operands() {
	./sh2elf scripts/test_compound_operands.sh -o compound_operands.elf >/dev/null
	./compound_operands.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Compound Operands" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Compound Operands" "${R}FAILED${N}";
		return 1;
	}
}

floop_control() {
	./sh2elf scripts/test_loop_control.sh -o loop_control.elf >/dev/null
	./loop_control.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Loop Control" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Loop Control" "${R}FAILED${N}";
		return 2;
	}
}

ftrap_signals() {
	./sh2elf scripts/test_trap_signals.sh -o trap_signals.elf >/dev/null
	./trap_signals.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Trap Signals" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Trap Signals" "${R}FAILED${N}";
		return 4;
	}
}

ffunc_return() {
	./sh2elf scripts/test_func_return.sh -o func_return.elf >/dev/null
	./func_return.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Func Return" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Func Return" "${R}FAILED${N}";
		return 8;
	}
}

fset_flags() {
	./sh2elf scripts/test_set_flags.sh -o set_flags.elf >/dev/null
	./set_flags.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Set Flags" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Set Flags" "${R}FAILED${N}";
		return 16;
	}
}

fparam_assign_alt() {
	./sh2elf scripts/test_param_assign_alt.sh -o param_assign_alt.elf >/dev/null
	./param_assign_alt.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Param Assign Alt" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Param Assign Alt" "${R}FAILED${N}";
		return 32;
	}
}

ffd_redirs() {
	./sh2elf scripts/test_fd_redirs.sh -o fd_redirs.elf >/dev/null
	./fd_redirs.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "FD Redirections" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "FD Redirections" "${R}FAILED${N}";
		return 64;
	}
}

fselect_loop() {
	./sh2elf scripts/test_select_loop.sh -o select_loop.elf >/dev/null
	./select_loop.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Select Loop" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Select Loop" "${R}FAILED${N}";
		return 128;
	}
}

fproc_sub() {
	./sh2elf scripts/test_proc_sub.sh -o proc_sub.elf >/dev/null
	./proc_sub.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "Process Substitution" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "Process Substitution" "${R}FAILED${N}";
		return 256;
	}
}

fifs_splitting() {
	./sh2elf scripts/test_ifs_splitting.sh -o ifs_splitting.elf >/dev/null
	./ifs_splitting.elf >/dev/null
	[ $? -eq 0 ] && {
		fprint "IFS Splitting" "${G}PASSED${N}";
		return 0;
	} || {
		fprint "IFS Splitting" "${R}FAILED${N}";
		return 512;
	}
}

farith_full() {
	./sh2elf scripts/test_arith_full.sh -o arith_full.elf >/dev/null
	CAPTURE=$(./arith_full.elf)
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
	./sh2elf scripts/test_arith_cmd.sh -o arith_cmd.elf >/dev/null
	CAPTURE=$(./arith_cmd.elf)
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
	./sh2elf scripts/test_while_loop.sh -o while_loop.elf >/dev/null
	CAPTURE=$(./while_loop.elf)
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
	./sh2elf scripts/test_brace_exp.sh -o brace_exp.elf >/dev/null
	CAPTURE=$(./brace_exp.elf)
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
	./sh2elf scripts/test_param_ext.sh -o param_ext.elf >/dev/null
	CAPTURE=$(./param_ext.elf)
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
	./sh2elf scripts/test_ansi_quote.sh -o ansi_quote.elf >/dev/null
	CAPTURE=$(./ansi_quote.elf)
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
	./sh2elf scripts/test_herestring.sh -o herestring.elf >/dev/null
	CAPTURE=$(./herestring.elf)
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
	./sh2elf scripts/test_negation.sh -o negation.elf >/dev/null
	CAPTURE=$(./negation.elf)
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
	./sh2elf scripts/test_background.sh -o background.elf >/dev/null
	CAPTURE=$(./background.elf)
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
	./sh2elf scripts/test_runtime_params.sh -o runtime_params.elf >/dev/null
	CAPTURE=$(./runtime_params.elf one two "three four")
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
	./sh2elf scripts/test_func_args.sh -o func_args.elf >/dev/null
	CAPTURE=$(./func_args.elf)
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
	./sh2elf scripts/test_case_alt.sh -o case_alt.elf >/dev/null
	CAPTURE=$(./case_alt.elf)
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
	./sh2elf scripts/test_test_ext.sh -o test_ext.elf >/dev/null
	CAPTURE=$(./test_ext.elf)
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
	./sh2elf scripts/test_echo_opts.sh -o echo_opts.elf >/dev/null
	CAPTURE=$(./echo_opts.elf)
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
	./sh2elf scripts/test_dquote_exp.sh -o dquote_exp.elf >/dev/null
	CAPTURE=$(./dquote_exp.elf)
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
	./sh2elf scripts/test_rev.sh -o rev.elf >/dev/null
	CAPTURE=$(./rev.elf)
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
	./sh2elf scripts/test_nl.sh -o nl.elf >/dev/null
	CAPTURE=$(./nl.elf)
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
	./sh2elf scripts/test_tac.sh -o tac.elf >/dev/null
	CAPTURE=$(./tac.elf)
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
	./sh2elf scripts/test_fold.sh -o fold.elf >/dev/null
	CAPTURE=$(./fold.elf)
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
	./sh2elf scripts/test_base64.sh -o base64.elf >/dev/null
	CAPTURE=$(./base64.elf)
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
	./sh2elf scripts/test_printf_full.sh -o printf_full.elf >/dev/null
	CAPTURE=$(./printf_full.elf)
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
	./sh2elf scripts/test_xxd.sh -o xxd.elf >/dev/null
	CAPTURE=$(./xxd.elf)
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
	./sh2elf scripts/test_cmp.sh -o cmp.elf >/dev/null
	CAPTURE=$(./cmp.elf)
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
	./sh2elf scripts/test_cksum.sh -o cksum.elf >/dev/null
	CAPTURE=$(./cksum.elf)
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
	./sh2elf scripts/test_seq.sh -o seq.elf >/dev/null
	CAPTURE=$(./seq.elf)
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
	./sh2elf scripts/test_yes.sh -o yes.elf >/dev/null
	CAPTURE=$(./yes.elf)
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
	./sh2elf scripts/test_factor.sh -o factor.elf >/dev/null
	CAPTURE=$(./factor.elf)
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
	./sh2elf scripts/test_hostname.sh -o hostname.elf >/dev/null
	CAPTURE=$(./hostname.elf)
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
	./sh2elf scripts/test_nproc.sh -o nproc.elf >/dev/null
	CAPTURE=$(./nproc.elf)
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
	./sh2elf scripts/test_printenv.sh -o printenv.elf >/dev/null
	CAPTURE=$(./printenv.elf)
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
	./sh2elf scripts/test_readlink.sh -o readlink.elf >/dev/null
	CAPTURE=$(./readlink.elf)
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
	./sh2elf scripts/test_ln.sh -o ln.elf >/dev/null
	CAPTURE=$(./ln.elf)
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
	./sh2elf scripts/test_truncate.sh -o truncate.elf >/dev/null
	CAPTURE=$(./truncate.elf)
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
	./sh2elf scripts/test_head_full.sh -o head_full.elf >/dev/null
	CAPTURE=$(./head_full.elf)
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

1
2
3
1
a
==> h1 <==
1
head: cannot open 'nosuch' for reading: No such file or directory
==> h1 <==
1
missing-rc=1
head: invalid number of lines: ‘abc’
invalid-rc=1
==> standard input <==
1

==> h2 <==
a
1458715628 51
1
2
1
2
a
b
0000000   x  \0   y  \0
0000004
2941577287 588888
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
1226921129 50000
1
2
3
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
	./sh2elf scripts/test_big_input.sh -o big_input.elf >/dev/null
	CAPTURE=$(./big_input.elf)
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
	./sh2elf scripts/test_tail_full.sh -o tail_full.elf >/dev/null
	CAPTURE=$(./tail_full.elf)
	EXPECTED=$(cat <<'EOF'
==> h1 <==
18
19
20

==> h2 <==
a
b
c--
9
20
18
19
20
0
18
19
20
19
20
c
20
c
==> h1 <==
20
tail: cannot open 'nosuch' for reading: No such file or directory
==> h1 <==
20
rc=1
tail: invalid number of lines: ‘abc’
rc=1
==> standard input <==
29
30

==> h2 <==
b
c
1458715628 51
1
2
9
20
tail: error reading 'dd': Is a directory
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
19
20
b
c
b
c
19
20
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
	./sh2elf scripts/test_tail_follow.sh -o tail_follow.elf >/dev/null
	CAPTURE=$(./tail_follow.elf)
	EXPECTED=$(cat <<'EOF'
two
three
four
follow-done rc=0
aaaa
bbbb
tail: /tmp/sh2elf_tf.txt: file truncated
x
old
tail: '/tmp/sh2elf_tf.txt' has been replaced;  following new file
new1
new2
==> /tmp/sh2elf_tf.txt <==
new2

==> /tmp/sh2elf_tf.txt.b <==
p
q

==> /tmp/sh2elf_tf.txt <==
r
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
	./sh2elf scripts/test_wc_full.sh -o wc_full.elf >/dev/null
	CAPTURE=$(./wc_full.elf)
	EXPECTED=$(cat <<'EOF'
20 20 51 h1
20 20 51 h1
 1  3  5 h2
21 23 56 total
20 h1
3 h2
51 h1
 5 h2
56 total
17 u
11 u
 2 h1
11 total
20 20 51
     20      20      51
20
0 0 0 e
wc: nosuch: No such file or directory
20 20 51 h1
20 20 51 total
missing-rc=1
20 20 51 h1
20 51 h1
20 20 51 h1
 1  3  5 h2
21 23 56
20 20 51 h1
20 20 51 total
100000 100000 588895 big
    20     20     51 h1
100020 100020 588946 total
      0       0       0 dd
wc: dd: Is a directory
dir-rc=1
     20      20
20 -
     20 -
      1 h2
     21 total
5
      1       4
11
5
      2       4       1
2
      0       2       3
 2  4 17 23 11 u
20 20 51 51  2 h1
 1  3  5  5  3 h2
 0  0  0  0  0 e
23 27 73 79 11 total
 2  4 17 23 11 u
 200000  200000 1288895 1288895       6
  51851   51851  300000
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
	./sh2elf scripts/test_cut_posix.sh -o cut_posix.elf >/dev/null
	CAPTURE=$(./cut_posix.elf)
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
h:l
日:語
a:c
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
b+c
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
	./sh2elf scripts/test_cut_full.sh -o cut_full.elf >/dev/null
	CAPTURE=$(./cut_full.elf)
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
a--c
1--3
nodelim
--
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
Try 'cut --help' for more information.
cut: the delimiter must be a single character
Try 'cut --help' for more information.
cut: invalid decreasing range
Try 'cut --help' for more information.
cut: only one list may be specified
Try 'cut --help' for more information.
0000000   b  \0   d  \0
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
ab:de:g
ab:cd
a:defgh
a c
ac
ab+cd+f:gh:ij
abcdef:gh
cut: byte/character offset ‘99999999999999999999’ is too large
Try 'cut --help' for more information.
def:gh:ij
cut: field number ‘99999999999999999999’ is too large
Try 'cut --help' for more information.
cut: only one list may be specified
Try 'cut --help' for more information.
0000000   a  \0   b  \n
0000004
0000000   a  \n  \0
0000003
b

z
x:z
cut: an input delimiter may be specified only when operating on fields
Try 'cut --help' for more information.
cut: suppressing non-delimited lines makes sense
	only when operating on fields
Try 'cut --help' for more information.
cut: fields are numbered from 1
Try 'cut --help' for more information.
cut: invalid byte/character position ‘x’
Try 'cut --help' for more information.
cut: invalid field value ‘x’
Try 'cut --help' for more information.
cut: invalid range with no endpoint: -
Try 'cut --help' for more information.
cut: nosuch: No such file or directory
a
1
nodelim

missing-rc=1
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
	./sh2elf scripts/test_tr_full.sh -o tr_full.elf >/dev/null
	CAPTURE=$(./tr_full.elf)
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
xycd
axb
axb
axb
xxx
AbC
tr: missing operand
Try 'tr --help' for more information.
tr: missing operand after ‘a’
Two strings must be given when translating.
Try 'tr --help' for more information.
tr: missing operand
Try 'tr --help' for more information.
tr: extra operand ‘b’
Only one string may be given when deleting without squeezing repeats.
Try 'tr --help' for more information.
tr: extra operand ‘c’
Try 'tr --help' for more information.
tr: range-endpoints of 'c-a' are in reverse collating sequence order
tr: when translating, the only character classes that may appear in
string2 are 'upper' and 'lower'
tr: the [c*] repeat construct may not appear in string1
tr: invalid character class ‘foo’
tr: when not truncating set1, string2 must be non-empty
tr: when translating with string1 longer than string2,
the latter string must not end with a character class
tr: missing operand after ‘a’
Two strings must be given when both deleting and squeezing repeats.
Try 'tr --help' for more information.
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
	./sh2elf scripts/test_tr_posix.sh -o tr_posix.elf >/dev/null
	CAPTURE=$(./tr_posix.elf)
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
	./sh2elf scripts/test_uniq_full.sh -o uniq_full.elf >/dev/null
	CAPTURE=$(./uniq_full.elf)
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
a
a
c
c
c
a
a

c
c
c

a
a

c
c
c
a
a

b

c
c
c

d

a

a
a

b

c
c
c

d

a


a
a

b

c
c
c

d

a
a
a

b

c
c
c

d

a

x 1 a
y 2 a
z 2 b
xa
zb
A
B
abc1
abd
0000000   a  \0   b  \0
0000004
a
b
c
d
a
a
      2 a
      3 c
      1 b
      1 d
      1 a
      2 a
      3 c
a
a
c
c
c
uniq: printing all duplicated lines and repeat counts is meaningless
Try 'uniq --help' for more information.
rc=1
uniq: nosuch: No such file or directory
rc=1
uniq: extra operand ‘c’
Try 'uniq --help' for more information.
rc=1
      1 100000
x a
x	a
y a
0000000 377   a  \n
0000003
aé
aÉ
uniq: --group is mutually exclusive with -c/-d/-D/-u
Try 'uniq --help' for more information.
uniq: invalid argument ‘foo’ for ‘--all-repeated’
Valid arguments are:
  - ‘none’
  - ‘prepend’
  - ‘separate’
Try 'uniq --help' for more information.
uniq: invalid argument ‘foo’ for ‘--group’
Valid arguments are:
  - ‘prepend’
  - ‘append’
  - ‘separate’
  - ‘both’
Try 'uniq --help' for more information.
uniq: x: invalid number of bytes to skip
uniq: -1: invalid number of fields to skip
a  b
abc
      1 x y
      1 a
      2 
      1 b
a
a x
c y
aa
a
      1 b
      1 d
      1 a
      3 Ab
      1 Ac
a
a

b
b
b
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
	./sh2elf scripts/test_sort_full.sh -o sort_full.elf >/dev/null
	CAPTURE=$(./sort_full.elf)
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
1 jan y
2 feb a
2 FEB z
3 Mar x
10 dec w
1 jan y
2 feb a
2 FEB z
3 Mar x
10 dec w
-1K
0
300
1.5K
2M
1G
1G
2M
1.5K
300
0
-1K
-5K
-,5M
0M
2
5,M
,5M
5,,5M
3K
.5M
0001M
0,5M
1,5.5M
1,0001M
3K
5k
1M
1e3
2E1
.a
file-1.2.tar.gz
file-1.10.tar.gz
v1.9
v1.9a
v1.10
foo
-nan
nan
-inf
2.5
0x10
1e3
inf
w:1:d
y:1:a
z:2:c
x:3:b
y:1:a
w:1:d
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
10 dec w
2 feb a
2 FEB z
1 jan y
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
rc=0
sort: f:2: disorder: Apple
rc=1
rc=1
rc=0
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
0000000   a  \0   b  \0   c  \0
0000006
0000000   a  \0   c  \n   x  \0   a  \n   x  \0   b  \n
0000014
a
b
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
z:2:c
y:1:a
x:3:b
w:1:d
sort: field number is zero: invalid field specification ‘0’
rc=2
sort: stray character in field spec: invalid field specification ‘1x’
sort: character offset is zero: invalid field specification ‘1.0’
sort: options '-gn' are incompatible
sort: multi-character tab ‘ab’
sort: incompatible tabs
sort: extra operand 's2' not allowed with -c
sort: cannot read: nosuch: No such file or directory
rc=2
sort: invalid argument ‘foo’ for ‘--sort’
Valid arguments are:
  - ‘general-numeric’
  - ‘human-numeric’
  - ‘month’
  - ‘numeric’
  - ‘random’
  - ‘version’
Try 'sort --help' for more information.
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
	./sh2elf scripts/test_sort_posix.sh -o sort_posix.elf >/dev/null
	CAPTURE=$(./sort_posix.elf)
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
	./sh2elf scripts/test_grep_full.sh -o grep_full.elf >/dev/null
	CAPTURE=$(./grep_full.elf)
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
	./sh2elf scripts/test_grep_regex.sh -o grep_regex.elf >/dev/null
	CAPTURE=$(./grep_regex.elf)
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
	./sh2elf scripts/test_grep_rec.sh -o grep_rec.elf >/dev/null
	CAPTURE=$(./grep_rec.elf)
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

{ fhello && fpipe && flogic && ftruefalse && fpwd && fstderr && fmkdir && frmdir && funlink && fsleep && ftestcmd && fexport && fcat && fhead && fwc && fkill && ftouch && fchmod && fbasename && fvars && fdirname && fprintf && fsubshell && fgroup && fif && fwhile && ffor && funtil && fread && funset && fcp && fmv && frm && ftee && fexpr && fparamexp && fcase && fheredoc && fcmdsub && farith && fglob && ffunc && funame && fwhoami && fid && fenv && flscmd && fgrep && ftr && fcut && fsort && funiq && ffind && fxargs && fsed && fawk && ftail && fchown && fchgrp && fgrepi && fgrepv && fgrepn && fgrepc && fheadn && ftailn && fcutdf && fsortr && fsortu && funiqc && funiqd && fwcl && fwcw && ffindname && fps && fkillall && fpgrep && fpkill && fnice && ftime && ftar && fgzip && fgunzip && fexprops && fpatternexp && fgetopts && feval && fshift && fpathexec && fhuge && fcompound_operands && floop_control && ftrap_signals && ffunc_return && fset_flags && fparam_assign_alt && ffd_redirs && fselect_loop && fproc_sub && fifs_splitting && farith_full && farith_cmd && fwhile_loop && fbrace_exp && fparam_ext && fansi_quote && fherestring && fnegation && fbackground && fruntime_params && ffunc_args && fcase_alt && ftest_ext && fecho_opts && fdquote_exp && frev && fnl && ftac && ffold && fbase64 && fprintf_full && fxxd && fcmp && fcksum && fseq && fyes && ffactor && fhostname && fnproc && fprintenv && freadlink && fln && ftruncate && fhead_full && fbig_input && ftail_full && ftail_follow && fwc_full && fcut_posix && fcut_full && ftr_full && ftr_posix && funiq_full && fsort_full && fsort_posix && fgrep_full && fgrep_regex && fgrep_rec; RETURN="${?}"; } || exit 1

[ "${RETURN}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RETURN}"
