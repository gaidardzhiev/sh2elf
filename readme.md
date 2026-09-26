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

The source language is intentionally tiny. Anything outside the rules below is rejected with a parse error or left uninterpreted.

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

- **Built-ins**:
  - `echo` prints its arguments separated by single spaces and appends a newline (supports `-n`, `-e`, `-E`).
  - `cd` changes to the provided directory (`cd DIR`). Missing arguments are ignored.
  - `pwd` prints the current working directory via `sys_getcwd`.
  - `true` exits with status 0.
  - `false` exits with status 1.
  - `mkdir` creates a directory (`mkdir DIR`) via `sys_mkdir`.
  - `rmdir` removes an empty directory (`rmdir DIR`) via `sys_rmdir`.
  - `unlink` deletes a file (`unlink FILE`) via `sys_unlink`.
  - `sleep` pauses execution for N seconds (`sleep N`) via `sys_nanosleep`.
  - `test` / `[` / `[[` evaluate the full expression grammar: file checks (`-e -f -d -s -r -w -x -L -h -p -S -b -c -g -u -k -O -G -t`) via `sys_newfstatat`, `sys_faccessat2` and `sys_ioctl`, file comparisons (`-nt -ot -ef`), strings (`-z -n = == != < >`), integers (`-eq -ne -gt -ge -lt -le`), `!`, `-a`, `-o`, parentheses, and in `[[ ]]` also `&&`, `||`, glob matching with `==` and regex matching with `=~`. Constant expressions are folded at compile time.
  - `export` sets environment variables (`export VAR=VAL`).
  - `cat` streams file or stdin contents via `sys_read` and `sys_write`.
  - `head` outputs the initial portion of files (supports `-n [-]N`, `-c [-]N` with `b kB K MB M GB G ...` suffixes, legacy `-N`, `-q`, `-v`, `-z`, multiple files with headers); positive counts stream 64 KiB chunks scanned with SSE2 `pcmpeqb`/`pmovmskb`/`popcnt` and `lseek` back unread input.
  - `wc` counts lines, words, characters, bytes and the maximum display width (supports `-l -w -m -c -L`, `--total=auto|always|only|never`, `--files0-from`, GNU column widths); 64 KiB streaming with an SSE2 path that counts newlines, characters and word starts from byte masks with `popcnt`, an exact UTF-8 decoder for non-ASCII blocks, `wcwidth` ranges taken from glibc at compile time for `-L`, and `sys_fstat` for `-c` on regular files.
  - `kill` sends signals (`kill -SIG PID`) via `sys_kill`.
  - `touch` creates or updates files (`touch FILE`) via `sys_openat`.
  - `chmod` modifies file permissions (`chmod MODE FILE`) via `sys_chmod`.
  - `basename` extracts the trailing component of a path (`basename PATH [SUFFIX]`).
  - `dirname` extracts the directory component of a path (`dirname PATH`).
  - `printf` formats and prints text (`printf FMT ARGS`) with flags, width, precision, `*`, conversions `d i o u x X c s b e f g E G a %`, all backslash escapes including `\NNN`, `\xHH`, `\uHHHH`, and format reuse while arguments remain.
  - `read` reads input from stdin (`read VAR`).
  - `unset` unsets an environment variable (`unset VAR`).
  - `cp` copies a file (`cp SRC DST`).
  - `mv` moves or renames a file (`mv SRC DST`).
  - `rm` removes a file (`rm FILE`).
  - `tee` duplicates input to stdout and a file (`tee FILE`).
  - `expr` evaluates arithmetic expressions and comparisons (`+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `>`, `<=`, `>=`).
  - `trap` registers signal actions (`trap CMD SIG`).
  - `uname` prints system information via `sys_uname` (syscall 63).
  - `whoami` prints current user name via `sys_getuid` (syscall 102).
  - `id` prints user and group IDs via `sys_getuid`.
  - `env` prints environment variables.
  - `ls` lists directory contents natively via `sys_getdents64` (syscall 217).
  - `grep` searches files, stdin or directory trees (supports `-E`, `-F`, `-G`, `-e`, `-f`, `-i`, `-y`, `-v`, `-w`, `-x`, `-c`, `-l`, `-L`, `-q`, `-s`, `-m`, `-o`, `-b`, `-n`, `-H`, `-h`, `-T`, `-Z`, `-z`, `-a`, `-I`, `-U`, `-A`/`-B`/`-C`/`-NUM`, `--color`, `--label`, `--binary-files`, `-d`, `-D`, `-r`, `-R`, `--include`, `--exclude`, `--exclude-from`, `--exclude-dir`, `--group-separator`, `--line-buffered`, abbreviated long options, all GNU diagnostics); matches GNU grep 3.12 exactly: a port of the glibc regex parser (BRE/ERE, back-references, intervals, classes, `[=a=]` and collation-order ranges from the en_US.UTF-8 tables, `\< \> \b \B \w \s`) compiled into a context-aware character DFA at compile time, GNU's `-w` retry loop, binary-file and encoding-error handling per 96 KiB read; runtime is an SSE2 required-literal search, an SSSE3 `pshufb` skip over bytes that cannot start a match and a byte-indexed DFA, with a backtracker only for back-references. Patterns from `-f FILE` are read at compile time.
  - `tr` translates, deletes and squeezes characters (supports `-c`, `-C`, `-d`, `-s`, `-t`, escapes, `\ooo`, ranges, `[:class:]`, `[=c=]`, `[c*n]`, `[c*]`, case conversion, all GNU diagnostics); byte mode matches GNU with SSE2 range-shift, table and squeeze-run paths, and per POSIX `-C`, multibyte operands and character classes switch to UTF-8 character mode with glibc `isw*`/`tow*` tables built at compile time and an SSE2 path for ASCII blocks.
  - `cut` selects bytes, characters or fields (supports `-b`, `-c`, `-f`, `-d`, `-s`, `-n`, `-z`, `--complement`, `--output-delimiter`, comma or blank separated lists); follows POSIX for `-c` (UTF-8 characters), `-n` (no split characters) and multibyte `-d`, GNU for everything else; streams 64 KiB reads, and single-byte field splitting walks a combined delimiter/newline SSE2 bitmask with `bsf`.
  - `sort` sorts, merges and checks lines (supports `-b`, `-d`, `-f`, `-g`, `-h`, `-i`, `-M`, `-n`, `-R`, `-V`, `-r`, `-k`, `-t`, `-u`, `-s`, `-z`, `-c`, `-C`, `-m`, `-o`, `--sort=`, `--check=`, `--random-source`, `--files0-from`, obsolete `+POS1 -POS2`, all GNU diagnostics); text order is an exact port of glibc `strcoll` for en_US.UTF-8 (weight tables extracted at compile time, contractions excepted), and POSIX is followed for `-k` character offsets, `-d`/`-i`/`-f` on UTF-8 characters and multibyte `-t`; bottom-up merge sort over 32-byte items that cache the first key span and an order-preserving 64-bit key prefix (collation L1, numeric, human, month, general-numeric), so most comparisons are a single integer compare.
  - `uniq` filters adjacent repeated lines (supports `-c`, `-d`, `-u`, `-D`, `--all-repeated=none|prepend|separate`, `--group=separate|prepend|append|both`, `-f`, `-s`, `-w`, `-i`, `-z`, obsolete `-N`/`+N`, input and output file operands); `-s`/`-w` count UTF-8 characters and fields split on Unicode blanks; streaming 64 KiB reads with SSE2 line splitting and 16-byte key comparison.
  - `find` searches directory hierarchies natively via `sys_getdents64` (supports `-name`).
  - `xargs` processes command arguments from stdin streams.
  - `sed` performs stream editing on text streams.
  - `awk` performs pattern scanning and processing on text streams.
  - `tail` outputs the last part of files (supports `-n [+-]N`, `-c [+-]N` with size suffixes, legacy `+N`/`-N[bcl][f]`, `-q`, `-v`, `-z`, headers); regular files are read backwards from the end with `sys_pread64` and an SSE2 `pcmpeqb`/`bsr` scan, then sent with zero-copy `sys_sendfile`. Follow mode `-f`, `-F`, `--follow=name|descriptor`, `--retry`, `-s SEC`, `--pid=PID` polls with `sys_fstat`/`sys_newfstatat`, detects truncation and replaced files, and ends when the watched process exits.
  - `chown` changes file ownership natively via `sys_chown` (syscall 92).
  - `chgrp` changes file group ownership natively via `sys_chown` (syscall 92).
  - `ps` inspects processes natively by scanning `/proc` using `sys_getdents64`.
  - `killall` signals processes matching specified target names via `sys_kill`.
  - `pgrep` searches active processes natively from `/proc`.
  - `pkill` signals matching processes natively from `/proc` via `sys_kill`.
  - `nice` sets process scheduling priority natively.
  - `time` measures execution timing natively.
  - `tar` archives/extracts streaming data natively via streaming syscalls.
  - `gzip` compresses streaming input to stdout natively via streaming syscalls.
  - `gunzip` decompresses streaming input to stdout natively via streaming syscalls.
  - `getopts` parses command-line flags and option arguments.
  - `eval` evaluates command string parameters dynamically.
  - `local` declares function-scoped local variables.
  - `return` exits from a function with an optional return status.
  - `exit` terminates the program with the last status or with `exit N`.
  - `:` does nothing and succeeds.
  - `wait` waits for background jobs (`wait`, `wait PID`).
  - `rev` reverses the characters of every line, UTF-8 aware, per file (supports `-0`).
  - `tac` prints files in reverse record order (supports `-b`, `-s SEP`).
  - `nl` numbers lines (supports `-b -h -f` styles `a t n`, `-n ln|rn|rz`, `-w`, `-s`, `-v`, `-i`, `-l`, `-p`, `-d`, logical page sections).
  - `fold` wraps lines by display columns with UTF-8 and double width characters (supports `-w`, `-s`, `-b`, `-N`).
  - `base64` encodes and decodes (supports `-d`, `-i`, `-w COLS`).
  - `xxd` makes hex dumps (supports `-c -g -u -s -l -o -a -e -b -p -i -r`, including `-r -p`).
  - `cmp` compares files byte by byte (supports `-b`, `-l`, `-s`, `-n`, `-i SKIP1:SKIP2`, skip operands, stdin as `-`).
  - `cksum` prints checksums with the `crc`, `crc32b`, `sysv` and `bsd` algorithms (`-a ALG`).
  - `seq` prints number sequences (supports `-s`, `-w`, `-f`, negative and floating steps).
  - `yes` repeats a line through a pre-filled 8 KiB `sys_write` loop.
  - `factor` factors 64-bit integers with trial division, Miller-Rabin and Pollard rho (supports `-h`, reads stdin without operands).
  - `hostname` prints or sets the host name via `sys_uname` and `sys_sethostname` (supports `-s`, `-d`).
  - `nproc` counts usable CPUs via `sys_sched_getaffinity` (supports `--all`, `--ignore=N`).
  - `printenv` prints environment variables read from the entry stack (supports `-0`).
  - `readlink` prints link targets and canonical paths (supports `-f`, `-e`, `-m`, `-n`, `-z`, `-v`, `-q`).
  - `ln` creates hard and symbolic links via `sys_linkat` and `sys_symlinkat` (supports `-s`, `-f`, `-n`, `-v`, `-T`, `-t DIR`, target directories).
  - `truncate` shrinks or extends files via `sys_ftruncate` (supports `-s` with `+ - < > / %` and `K M G T P E` / `KB` / `KiB` suffixes, `-c`, `-o`, `-r RFILE`).

- **External commands**: names containing `/` are executed verbatim. Otherwise the compiler checks `/bin/NAME`, `/usr/bin/NAME`, `/usr/local/bin/NAME`, `/sbin/NAME`, and `/usr/sbin/NAME` sequentially. The runtime passes an empty environment (`envp` terminates with NULL).

- **Tokenisation & quoting**:
  - Unquoted tokens are split on spaces, tabs, and carriage returns.
  - Backslash outside quotes escapes the next character (e.g. `echo foo\ bar`).
  - Single quotes (`'literal'`) preserve characters verbatim until the matching `'`.
  - Double quotes recognise `"`, `\`, `\$`, and ``\` `` escapes; all other backslash pairs keep the backslash (e.g. `"Hello\n"` stays `Hello\n`).
  - Newlines inside double quotes can be escaped with `\` + newline (line continuation).

## Architecture and Specs

### 1. Language Completeness
* **Runtime Variable Store**: BSS hashtable with linear probing for dynamic variable get and set operations without syscalls.
* **Full Runtime Word Evaluation**: Scratch-buffer word evaluator for dynamic variable concatenation.
* **Positional Parameters**: Prologue saving argc and argv from the Linux stack into BSS slots for `$1` through `$9`, `$@`, `$*`, `$#`, and `$0`.
* **IFS-aware Word Splitting**: In-place argument splitting on IFS characters to generate argument arrays.
* **Pattern Expansions and Substitutions**: Support for `${VAR#pat}`, `${VAR##pat}`, `${VAR%pat}`, `${VAR%%pat}`, `${VAR/pat/repl}`, and `${VAR//pat/repl}`.
* **Numeric FD Redirections**: Full support for `N>&M`, `N<&M`, and closing `N>&-` via `sys_dup2` and `sys_close`.
* **Tool Runtime**: The new tools stream input with 64 KiB `sys_read` chunks into a 1 TiB region reserved at a fixed address by `sys_mmap` with `MAP_NORESERVE | MAP_FIXED_NOREPLACE` (only touched pages cost memory, with a 1 GiB fallback under strict overcommit) and write through a 64 KiB output buffer flushed by an inline `flush` routine; each tool body is hand written x86_64 machine code emitted with `c8`.
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

## Performance Benchmark

Benchmarked on a comprehensive 130+ line script exercising every POSIX language construct:

| Execution Method | Total Time (50 runs) | Average Run Time | Relative Speed |
| :--- | :--- | :--- | :--- |
| **Interpreted Bash** | 3.668 s | 73.3 ms | 1.0x (Baseline) |
| **sh2elf Binary** | **0.325 s** | **6.5 ms** | **11.28x FASTER** |

## Testing

Run the full verification suite:

```sh
make test
```

This verifies:
1. `verify.sh`: 147 / 147 integration tests pass (100%).
2. `test_diff`: Differential test harness matches bash output byte-for-byte.
3. `fuzz_sh`: 100 / 100 random fuzzing iterations pass without errors.

## Paper

A formal treatment of the compiler architecture, memory model, pipeline semantics, and code generation is available in [`docs/sh2elf-paper.pdf`](./docs/sh2elf-paper.pdf). To rebuild the PDF from the LaTeX source, run:

```sh
sh docs/tex2pdf.sh docs/sh2elf-paper.tex
```

Requires `pdflatex` or `xelatex`. The script prompts which one to use, runs two passes for cross references, and copies the result to `~/Downloads`.

## License

Copyright (C) 2025-2026 Ivan Gaydardzhiev.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3 of the License. See [COPYING](./COPYING) for complete details.
