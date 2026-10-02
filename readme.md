# sh2elf

A compiler that turns shell scripts into standalone statically linked `ELF64` executables for `Linux` on the `x86_64` architecture. It translates shell command lines, functions, arithmetic, pipelines and control flow straight into native machine code and raw kernel system calls, embeds them in an `ELF` binary, and handles process control without relying on an external shell or interpreter.

## How it works

The POSIX shell is not a fast language. Every invocation parses text, forks subprocesses to evaluate command substitutions, and interprets variable expansions at runtime. sh2elf compiles a shell script once and produces a native ELF64 binary that the Linux kernel can execute directly. All control flow becomes native branches. All I/O goes through inline system call sequences. Variable state lives in a BSS hashtable. Pipelines are implemented with `fork`, `pipe`, and `dup2` at the call site, emitted as machine code. The result runs 11.28x faster than bash on a comprehensive benchmark exercising the full supported language, carries no shared library dependencies, and communicates with the kernel exclusively through raw Linux system calls.

## Quick Start

### Build sh2elf

```sh
make
```

This builds all core compiler utilities:
* `sh2elf`: Compiler backend, disassembler, IR printer, and object generator.
* `sh2elf-lsp`: Standalone Language Server Protocol daemon for IDEs.
* `test_diff`: Differential test harness comparing sh2elf output against bash.
* `fuzz_sh`: Grammar-based shell script fuzzer.

### Compile a Shell Script

```sh
./sh2elf script.sh -o out.elf
./out.elf
```

## Compiler Modes

### 1. Standalone Binary Output
Compile a shell script into a standalone ELF executable:
```sh
./sh2elf script.sh -o out.elf
```

### 2. Disassembler and Listing Mode (`--list`)
View the source shell lines matched directly with generated x86_64 assembly opcodes:
```sh
./sh2elf --list script.sh
```

### 3. Intermediate Representation Dump (`--dump-ir`)
Inspect the three-address IR instructions produced by the parser:
```sh
./sh2elf --dump-ir script.sh
```

### 4. Static Relocatable Object Output (`--emit-obj`)
Emit an ELF relocatable `.o` object file to link directly into C applications:
```sh
./sh2elf --emit-obj script.sh -o script.o
gcc main.c script.o -o binary
```

## Supported shell subset

Anything outside the rules below is rejected with a parse error or left uninterpreted.

- **Command layout**: commands are separated by newlines or `;`. Blank lines are ignored. Trailing `|` entries are rejected.

- **Comments**: unquoted `#` begins a comment that extends to the end of the current line (after any inline whitespace). Inside single or double quotes `#` is treated literally.

- **Pipelines**: the `|` operator connects stdout of the left stage to stdin of the right one. Arbitrary length pipelines are supported, mixing built-ins and external commands.

- **Conditional execution**: `&&` runs the following pipeline only when the previous command succeeds (exit status `0`), while `||` runs the next pipeline only when the previous command fails (non zero status). Conditions short circuit without altering the last exit status.

- **Redirection & Here-Documents**: each stage accepts input (`< file`), output redirection (`> file` overwrite, `>> file` append), stderr redirection (`2> file` overwrite, `2>> file` append), and Here-Documents (`<< EOF`, `<<- EOF`).

- **Here-Strings**: `cmd <<< word` feeds the expanded word plus a newline to stdin through a runtime `sys_pipe`, no temporary file.

- **Pipeline negation & background jobs**: `! pipeline` inverts the exit status at runtime, `pipeline &` forks without waiting and records the pid in `$!`, `wait` reaps every child via `sys_wait4(-1)` and `wait PID` returns that child's status.

- **Control flow & compound commands**:
  - `if ...; then ...; else ...; fi` conditional execution.
  - `while ...; do ...; done` loop execution.
  - `for VAR in ...; do ...; done` iterative loop execution.
  - `until ...; do ...; done` loop until condition succeeds.
  - `case ... in pattern) ... ;; esac` pattern-matching branch statements via `fnmatch`.
  - Shell functions `func() { ... }` defined and inlined at call sites, with call arguments bound to `$1`..`$9`, `$#`, `$@` inside the body.
  - Subshells `(...)` and command grouping `{ ... }`.
  - `while` / `until` loops whose condition is a `test`, `[`, `[[` or `(( ))` expression are unrolled at compile time until the condition flips (limit 100000 iterations).
  - Arithmetic command `(( expr ))` and C-style `for (( init; cond; step )); do ...; done`.
  - `case` patterns with alternation `a|b)` and the optional leading `(pat)` form.

- **Expansions & Substitutions**:
  - Parameter expansion (`$VAR`, `${VAR}`, `${#VAR}` string length, `${VAR:-default}` fallback, `${VAR:=default}` assignment, `${VAR:+alt}` alternative).
  - Special variables (`$?` exit status, `$$` process ID).
  - Command substitution (`$(cmd)` and `` `cmd` ``).
  - Inline arithmetic expansion (`$(( A + B ))`) with full C precedence: `** * / % + - << >> < <= > >= == != & ^ | && || ?: ,`, unary `! ~ - +`, `++`/`--`, assignments `= += -= *= /= %= <<= >>= &= ^= |=`, bare variable names, `0x`, octal and `base#digits` constants.
  - Pathname globbing (`*.c`, `?`, `[...]`) via POSIX `glob()`.
  - Brace expansion (`{a,b,c}`, `pre{1,2}post`, `{1..10..3}`, `{01..03}`, `{a..e}`, nested).
  - Extended parameter expansion: substrings `${V:off}`, `${V:off:len}` (negative offsets and lengths), case modification `${V^}`, `${V^^}`, `${V,}`, `${V,,}`, `${V~~}`, indirection `${!V}`, and `${V:?msg}` / `${V?msg}`.
  - ANSI-C quoting `$'...'` (`\n \t \xHH \NNN \e \cX ...`) and tilde expansion (`~`, `~/path`, `~user`, after `=` and `:` in assignments).
  - Runtime special parameters `$?`, `$$`, `$!`, `$PPID`, `$RANDOM`, `$#`, `$0`..`$9`, `$@`, `$*`, read from the kernel or from the entry stack when the binary runs, and usable inside double quotes, `echo`, `printf`, `test`, `exit` and external command arguments.

- **External commands**: names containing `/` are executed verbatim. Otherwise the compiler checks `/bin/NAME`, `/usr/bin/NAME`, `/usr/local/bin/NAME`, `/sbin/NAME`, and `/usr/sbin/NAME` sequentially. The runtime passes an empty environment (`envp` terminates with NULL).

- **Tokenisation & quoting**:
  - Unquoted tokens are split on spaces, tabs, and carriage returns.
  - Backslash outside quotes escapes the next character (e.g. `echo foo\ bar`).
  - Single quotes (`'literal'`) preserve characters verbatim until the matching `'`.
  - Double quotes recognise `"`, `\`, `\$`, and ``\` `` escapes; all other backslash pairs keep the backslash (e.g. `"Hello\n"` stays `Hello\n`).
  - Newlines inside double quotes can be escaped with `\` + newline (line continuation).

## Built-in tools

Every tool below is compiled natively into the output binary. No external program is spawned.

| Tool | Description |
| :--- | :--- |
| `echo` | POSIX XSI echo: no options (`-n`, `-e`, `--` are printed), escapes `\a \b \c \f \n \r \t \v \\ \0num` always interpreted; use `printf` for portable output without a newline. |
| `cd` | Changes the working directory. |
| `pwd` | Prints the working directory via `sys_getcwd`. |
| `true` / `false` | Exit with status 0 / 1. |
| `:` | Does nothing and succeeds. |
| `test` / `[` | POSIX.1-2024 test: the 0-4 argument algorithm with `!`, unary `-b -c -d -e -f -g -h -L -n -p -r -S -s -t -u -w -x -z`, binary `= != < > -eq -ne -gt -ge -lt -le -nt -ot -ef`; `<` `>` collate in the current locale (byte order for C/POSIX), integers of any size. `-a`, `-o`, parentheses and `==` are not supported (use `&&` / `\|\|` between tests). |
| `[[` | bash-style conditional (not POSIX): `&&`, `\|\|`, `!`, parentheses, glob `==`, regex `=~`. |
| `export` | Sets environment variables. |
| `unset` | Unsets a variable. |
| `read` | Reads input from stdin into a variable. |
| `printf` | POSIX printf: flags `- + space # 0`, width, precision, `*`, numbered arguments `%n$` / `*n$`, conversions `d i o u x X c s b e E f F g G %`, escapes `\\ \a \b \f \n \r \t \v \ddd` (and `\0ddd`, `\c` in `%b`), format reuse; bad numbers are reported and the value read so far is printed. |
| `getopts` | Parses command-line flags and option arguments. |
| `eval` | Evaluates command strings dynamically. |
| `local` | Declares function-scoped variables. |
| `return` | Exits a function with an optional status. |
| `exit` | Terminates the program with the last status or `exit N`. |
| `trap` | Registers signal actions. |
| `wait` | Waits for background jobs (`wait`, `wait PID`). |
| `sleep` | POSIX: `sleep time` with whole seconds only, run in-process (`nanosleep`); a trapped signal runs its trap and ends the sleep with status 128+signal. |
| `time` | Measures execution timing. |
| `nice` | Sets process scheduling priority. |
| `kill` | POSIX (XSI): sends signals (`-s name`, `-name`, `-number`, default TERM; names case-insensitive without `SIG`, plus `0` and `RTMIN+n`/`RTMAX-n`); `-l` lists names or maps a signal number or `$?` value (128+n) to its name; pids, negative process groups after `--`, and job IDs `%n`, `%%`, `%+`, `%-`. |
| `killall` | Signals processes matching target names. |
| `pgrep` | Searches running processes via `/proc`. |
| `pkill` | Signals processes matching a pattern via `/proc`. |
| `ps` | Inspects processes by scanning `/proc` with `sys_getdents64`. |
| `cat` | POSIX: concatenates files or stdin (`-u`; `-` operands); zero-copy `sendfile` with read/write fallback. |
| `tee` | POSIX: copies stdin to stdout and files (`-a -i`; `-` is a file name); unbuffered, per-file write errors. |
| `head` | Outputs the first part of files; POSIX.1-2024 only (`-c number`, `-n number`). |
| `tail` | Outputs the last part of a file; POSIX.1-2024 only (`-f`, `-c number`, `-n number` with `+`/`-` origin, `-r`). |
| `tac` | Prints the lines of each file (or stdin, `-`) in reverse order; no options (toybox set). |
| `rev` | Reverses the characters of each line, UTF-8 aware in a UTF-8 locale; no options (toybox set). |
| `wc` | Counts newlines, words, bytes or characters; POSIX.1-2024 only (`-c`, `-m`, `-l`, `-w`, POSIX output format). |
| `nl` | POSIX (XSI): numbers lines of one file (`-p`, `-b -h -f` with `a t n pBRE`, `-d`, `-i`, `-l`, `-n` with `ln`, `rn` or `rz`, `-s`, `-v`, `-w`); logical page sections. |
| `fold` | POSIX: wraps lines by display columns (`-w width`, `-s`, `-b`); UTF-8 widths in a UTF-8 locale, backspace, tab and carriage return handled. |
| `cut` | POSIX: selects bytes, characters or fields (`-b list [-n]`, `-c list`, `-f list [-d delim] [-s]`); `-c` counts UTF-8 characters. |
| `tr` | POSIX: translates, deletes and squeezes characters (`-c -C -d -s`, ranges, escapes, `[:class:]`, `[=c=]`, `[x*n]`); UTF-8 aware. |
| `sort` | POSIX: sorts, merges and checks lines (`-m -o -b -d -f -i -n -r -u -t -k -c -C`); en_US.UTF-8 collation built in, byte order when LC_ALL/LC_COLLATE/LANG is C, POSIX or C.* (or unset). |
| `uniq` | POSIX: filters adjacent repeated lines (`-c|-d|-u`, `-f fields`, `-s chars`, optional output file); `-s` counts UTF-8 characters. |
| `grep` | POSIX: searches files or stdin (`-E|-F`, `-c|-l|-q`, `-e -f -i -n -s -v -x`); BRE with `\+ \? \|`; UTF-8 classes, ranges and `[=c=]`. |
| `sed` | Stream editing on text. |
| `awk` | Pattern scanning and processing on text. |
| `find` | Searches directory hierarchies; POSIX.1-2024 only (`-H -L`; `! -a -o ( )`; `-name -iname -path -type -size -perm -links -user -group -nouser -nogroup -atime -ctime -mtime -newer -xdev -mount -depth -prune -print -print0 -exec -ok`). |
| `xargs` | Builds and runs command lines from input; POSIX.1-2024 only (`-0 -E -I -L -n -p -r -s -t -x`). |
| `ls` | Lists directory contents; POSIX.1-2024 options only (`-ikqrs -glno -A -a -C -m -x -1 -F -p -H -L -R -d -S -f -t -c -u`). |
| `cp` | Copies files and trees; POSIX.1-2024 only (`-P -f -i -p -R -H -L`). |
| `mv` | Moves and renames files and trees, across file systems too; POSIX.1-2024 only (`-i -f`). |
| `rm` | Removes files and trees; POSIX.1-2024 only (`-d -f -i -R -r -v`). |
| `mkdir` | Creates directories; POSIX.1-2024 only (`-p`, `-m mode`). |
| `rmdir` | Removes empty directories; POSIX.1-2024 only (`-p`). |
| `unlink` | Deletes a file via `sys_unlink`. |
| `ln` | POSIX: creates hard and symbolic links (`-f -s`, `-L|-P`); both synopsis forms decided at run time. |
| `readlink` | POSIX.1-2024: prints the contents of one symbolic link (`-n`); a diagnostic when the file is not a symbolic link. |
| `touch` | Creates files or updates timestamps; POSIX.1-2024 only (`-a -c -m`, `-r ref_file`, `-t time`, `-d date_time`). |
| `truncate` | Shrinks or extends files (toybox set: `-c`, `-s size` with `+ - < > / %` modes and `k m g t p e` suffixes). |
| `chmod` | Changes file modes, octal and symbolic; POSIX.1-2024 only (`-R`). |
| `chown` | Changes file ownership; POSIX.1-2024 only (`-h`, `-R` with `-H -L -P`, `owner[:group]`). |
| `chgrp` | Changes file group ownership; POSIX.1-2024 only (same options as `chown`). |
| `basename` | POSIX: `basename string [suffix]`, run in-process (trailing slashes, `/`, `//`, suffix only when not the whole name). |
| `dirname` | POSIX: `dirname string`, run in-process (`.` without a slash, `/` for root and `//`). |
| `tar` | Archives and extracts streaming data. |
| `gzip` | Compresses streaming input to stdout. |
| `gunzip` | Decompresses streaming input to stdout. |
| `base64` | Encodes and decodes one file or stdin (toybox set: `-d`, `-i`, `-w columns`). |
| `xxd` | Makes hex dumps and reverses them (toybox set: `-c -e -g -i -l -o -p -r -s`). |
| `cmp` | POSIX: compares two files (`-l` or `-s`; `-` is stdin); POSIX output `differ: char N, line N` and `%d %o %o`. |
| `cksum` | POSIX: prints the CRC, size and name of each file (no options). |
| `expr` | POSIX expr, run in-process: `\| & = != < <= > >= + - * / % :` and parentheses, integers of any size, string comparisons by locale collation, `:` with BRE (match length, or `\1` when the pattern has a subexpression); `\|` and `&` skip evaluating the side they do not need. No `length`, `substr`, `index`, `match`, `+ token` or `==`. |
| `seq` | Prints number sequences (toybox set: `-f format`, `-s string`, `-w`); integers of any length, long double steps with GNU-compatible output. |
| `yes` | Repeats a line through a pre-filled 8 KiB write loop; no options. |
| `factor` | Factors 64-bit integers from operands or stdin (`-h` for exponents; trial division, Miller-Rabin, Pollard-Brent). |
| `uname` | POSIX: prints system information (`-a -m -n -r -s -v`; fields always in the order s n r v m, `-a` without GNU extras). |
| `hostname` | Prints or sets the host name (`-s`, `-f`, `-d`; the full name comes from /etc/hosts). |
| `nproc` | Counts usable CPUs (`-a` for all installed CPUs). |
| `whoami` | Prints the current user name via `sys_getuid`. |
| `id` | POSIX: prints user and group IDs and names (`id [user]`, `-G [-n]`, `-g [-nr]`, `-u [-nr]`); names from /etc/passwd and /etc/group, euid/egid shown when they differ. |
| `env` | POSIX: `env [-i] [name=value]... [utility [argument...]]` (`-` acts as `-i`); prints the exported variables in-process, or runs the utility with the modified environment and PATH (126 not executable, 127 not found, 125 env errors). |
| `printenv` | Prints the shell's exported variables (`-0`); status 1 when a name is not set. |

## Architecture and Specs

### 1. Language Completeness
* **Runtime Variable Store**: BSS hashtable with linear probing for dynamic variable get and set operations without syscalls.
* **Full Runtime Word Evaluation**: Scratch-buffer word evaluator for dynamic variable concatenation.
* **Positional Parameters**: Prologue saving argc and argv from the Linux stack into BSS slots for `$1` through `$9`, `$@`, `$*`, `$#`, and `$0`.
* **IFS-aware Word Splitting**: In-place argument splitting on IFS characters to generate argument arrays.
* **Pattern Expansions and Substitutions**: Support for `${VAR#pat}`, `${VAR##pat}`, `${VAR%pat}`, `${VAR%%pat}`, `${VAR/pat/repl}`, and `${VAR//pat/repl}`.
* **Numeric FD Redirections**: Full support for `N>&M`, `N<&M`, and closing `N>&-` via `sys_dup2` and `sys_close`.
* **Tool Runtime**: The built-in tools stream input with 64 KiB `sys_read` chunks into a 1 TiB region reserved at a fixed address by `sys_mmap` with `MAP_NORESERVE | MAP_FIXED_NOREPLACE` (only touched pages cost memory, with a 1 GiB fallback under strict overcommit) and write through a 64 KiB output buffer flushed by an inline `flush` routine; each tool body is hand written x86_64 machine code emitted with `c8`.
* **Execution Flags**: Builtin codegen for `set -e`, `set -u`, and `set -x`.
* **Loop Depth Controls**: Compile-time jump backpatching stack for multi-level `break N` and `continue N`.
* **Select Loops**: Interactive menu generation and stdin evaluation.

### 2. Codegen Quality and Optimizations
* **Peephole Optimizer**: Post-emission pass converting `mov rax, 0` to `xor eax, eax` and trimming redundant jumps.
* **String Pool Deduplication**: O(1) string pool hashing to avoid duplicate strings in `.rodata`.
* **Dead Branch Elimination**: Compile-time constant folding that strips unreachable conditional blocks.
* **SIGPIPE Correctness**: Automatic `sys_rt_sigaction` signal handling setup for pipeline stages.
* **Full Integer Arithmetic**: 64-bit recursive descent integer evaluator for `$(( ))` in pure x86_64 assembly.
* **Inline Function Frames**: Proper positional parameter frame push and pop codegen for scoped function calls.
* **Trap Handlers**: Native `sys_rt_sigaction` handler registration for signal processing.

### 3. Compiler Infrastructure
* **Three-Address IR**: Decoupled IR layer between front-end parsing and x86-64 code generation.
* **Disassembler**: Source-annotated instruction disassembly viewer.
* **Line and Column Error Reporting**: Precise diagnostics with exact token locations.
* **Differential Harness**: `test_diff.c` utility comparing sh2elf binaries against standard bash execution.
* **Grammar Fuzzer**: `fuzz_sh.c` stress-testing parser and codegen stability with randomized inputs.
* **Static Object Output**: Relocatable `.o` generator with full symbol tables.
* **Incremental Builds**: Function source hashing to skip unchanged compilation units.

### 4. Advanced Capabilities
* **Process Substitution**: Support for `<(cmd)` and `>(cmd)` using anonymous pipes and `/dev/fd/N`.
* **Runtime Eval**: On-the-fly compilation of dynamic code strings.
* **Source Merging**: Sourced script inclusion and symbol table merging at link time.
* **LSP Integration**: Standalone language server `sh2elf-lsp` for real-time IDE diagnostics and hover details.
* **Formal Semantics Paper**: Comprehensive formal denotational semantics document in `docs/semantics.md`.

## Testing

Run the full verification suite:

```sh
make test
```

This verifies:
1. `verify.sh`: 167 / 167 integration tests pass (100%).
2. `test_diff`: Differential test harness matches bash output byte-for-byte.
3. `fuzz_sh`: 100 / 100 random fuzzing iterations pass without errors.

## Paper

A formal treatment of the old compiler architecture, memory model, pipeline semantics, and code generation is available in [`docs/sh2elf-paper.pdf`](./docs/sh2elf-paper.pdf). To rebuild the PDF from the LaTeX source, run:

```sh
sh docs/tex2pdf.sh docs/sh2elf-paper.tex
```

Requires `pdflatex` or `xelatex`. The script prompts which one to use, runs two passes for cross references, and copies the result to `~/Downloads`.

## License

Copyright (C) 2025-2026 Ivan Gaydardzhiev.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License. See [COPYING](./COPYING) for complete details.
