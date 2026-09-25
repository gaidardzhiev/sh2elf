#!/bin/sh
trap 'echo trap_sigint_fired' SIGINT
trap 'echo trap_sigusr1_fired' SIGUSR1
trap 'echo trap_num2_fired' 2
echo "trap_configured"
trap - SIGINT
trap - 2
echo "trap_reset"
