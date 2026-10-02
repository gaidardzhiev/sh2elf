env > /dev/null && echo "env-rc=0"
env | /usr/bin/grep -c '^PATH='
env -i A=1 B='x y' A=2
env -i
echo "empty-rc=$?"
export SH2ELF_E=1
env | /usr/bin/grep '^SH2ELF_E='
SH2ELF_P=prefix env | /usr/bin/grep '^SH2ELF_P='
env SH2ELF_V=val sh -c 'echo "$SH2ELF_V"'
env -i SH2ELF_Q=q /usr/bin/printenv SH2ELF_Q
env -i PATH=/usr/bin printenv PATH
env -i /usr/bin/env
env - Z=1
env sh -c 'exit 7'
echo "child-rc=$?"
env sh_no_such_cmd_x 2>&1
echo "missing-rc=$?"
env /etc/passwd 2>&1
echo "noexec-rc=$?"
env -u HOME 2>&1
echo "badopt-rc=$?"
