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

- **Control flow & compound commands**:
  - `if ...; then ...; else ...; fi` conditional execution.
  - `while ...; do ...; done` loop execution.
  - `for VAR in ...; do ...; done` iterative loop execution.
  - `until ...; do ...; done` loop until condition succeeds.
  - `case ... in pattern) ... ;; esac` pattern-matching branch statements via `fnmatch`.
  - Shell functions `func() { ... }` defined and inlined at call sites.
  - Subshells `(...)` and command grouping `{ ... }`.

- **Expansions & Substitutions**:
  - Parameter expansion (`$VAR`, `${VAR}`, `${#VAR}` string length, `${VAR:-default}` fallback, `${VAR:=default}` assignment, `${VAR:+alt}` alternative).
  - Special variables (`$?` exit status, `$$` process ID).
  - Command substitution (`$(cmd)` and `` `cmd` ``).
  - Inline arithmetic expansion (`$(( A + B ))`).
  - Pathname globbing (`*.c`, `?`, `[...]`) via POSIX `glob()`.

- **Built-ins**:
  - `echo` prints its arguments separated by single spaces and appends a newline.
  - `cd` changes to the provided directory (`cd DIR`). Missing arguments are ignored.
  - `pwd` prints the current working directory via `sys_getcwd`.
  - `true` exits with status 0.
  - `false` exits with status 1.
  - `mkdir` creates a directory (`mkdir DIR`) via `sys_mkdir`.
  - `rmdir` removes an empty directory (`rmdir DIR`) via `sys_rmdir`.
  - `unlink` deletes a file (`unlink FILE`) via `sys_unlink`.
  - `sleep` pauses execution for N seconds (`sleep N`) via `sys_nanosleep`.
  - `test` / `[` evaluates file checks (`-e`, `-f`, `-d`) via `sys_newfstatat` or string equality (`=`, `!=`).
  - `export` sets environment variables (`export VAR=VAL`).
  - `cat` streams file or stdin contents via `sys_read` and `sys_write`.
  - `head` outputs the initial portion of files (`head -n N FILE`).
  - `wc` counts lines or bytes (`wc -l FILE`, `wc -c FILE`).
  - `kill` sends signals (`kill -SIG PID`) via `sys_kill`.
  - `touch` creates or updates files (`touch FILE`) via `sys_openat`.
  - `chmod` modifies file permissions (`chmod MODE FILE`) via `sys_chmod`.
  - `basename` extracts the trailing component of a path (`basename PATH [SUFFIX]`).
  - `dirname` extracts the directory component of a path (`dirname PATH`).
  - `printf` formats and prints text (`printf FMT ARGS`).
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
  - `grep` searches pattern in files or stdin via streaming syscalls (supports `-i`, `-v`, `-n`, `-c`).
  - `tr` translates characters from stdin to stdout via streaming syscalls.
  - `cut` extracts sections from stdin to stdout via streaming syscalls (supports `-d`, `-f`).
  - `sort` sorts lines of text from stdin to stdout via streaming syscalls (supports `-r`, `-u`, `-n`).
  - `uniq` reports or omits repeated lines from stdin to stdout via streaming syscalls (supports `-c`, `-d`, `-u`).
  - `find` searches directory hierarchies natively via `sys_getdents64` (supports `-name`).
  - `xargs` processes command arguments from stdin streams.
  - `sed` performs stream editing on text streams.
  - `awk` performs pattern scanning and processing on text streams.
  - `head` outputs initial portions of input streams (supports `-n`, `-c`).
  - `tail` outputs trailing portions of input streams (supports `-n`, `-c`).
  - `wc` counts lines/words/bytes natively (supports `-l`, `-w`, `-c`).
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
  - `exit` terminates the program with status 0.

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
1. `verify.sh`: 89 / 89 integration tests pass (100%).
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
