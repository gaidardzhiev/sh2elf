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
	EXPECTED="2"
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
	[ "${CAPTURE}" = "abc" ] && {
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
	[ "${CAPTURE}" = "MATCH LINE" ] && {
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
	[ "${CAPTURE}" = "MATCH LINE" ] && {
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

{ fhello && fpipe && flogic && ftruefalse && fpwd && fstderr && fmkdir && frmdir && funlink && fsleep && ftestcmd && fexport && fcat && fhead && fwc && fkill && ftouch && fchmod && fbasename && fvars && fdirname && fprintf && fsubshell && fgroup && fif && fwhile && ffor && funtil && fread && funset && fcp && fmv && frm && ftee && fexpr && fparamexp && fcase && fheredoc && fcmdsub && farith && fglob && ffunc && funame && fwhoami && fid && fenv && flscmd && fgrep && ftr && fcut && fsort && funiq && ffind && fxargs && fsed && fawk && ftail && fchown && fchgrp && fgrepi && fgrepv && fgrepn && fgrepc && fheadn && ftailn && fcutdf && fsortr && fsortu && funiqc && funiqd && fwcl && fwcw && ffindname && fps && fkillall && fpgrep && fpkill && fnice && ftime && ftar && fgzip && fgunzip && fexprops && fpatternexp && fgetopts && feval && fshift && fpathexec && fhuge; RETURN="${?}"; } || exit 1

[ "${RETURN}" -eq 0 ] 2>/dev/null || printf "%s\n" "${RETURN}"





