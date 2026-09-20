# sh2elf

This project is a minimalistic compiler written in `C` that compiles shell scripts into standalone `ELF64` executables for `Linux` on the `x86_64` architecture. It translates shell command lines into machine code, embeds them in an `ELF` binary, and handles process control and system calls natively without relying on an external shell or interpreter.

## Building

```sh
make
```

The produced `sh2elf` binary is a normal host executable. No additional runtime libraries are required.

## Usage

```sh
./sh2elf script.sh -o elf.out    # emits `elf.out` (defaults to a.out)
./elf.out                        # runs the translated script
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

## Performance & Benchmarks

The compiled `ELF64` binary runs significantly faster than interpreted shell scripts by executing native x86_64 machine code and streaming kernel syscalls:

```sh
# Comprehensive test script (130+ lines, exercising all language features)
./sh2elf scripts/test_huge_comprehensive.sh -o huge.elf

# 50-iteration execution benchmark comparison:
# Compiled ELF binary:   0.325s total (6.5 ms / run)
# Interpreted bash:      3.668s total (73.3 ms / run)
# Speedup factor:        11.28x FASTER
```

## Examples

Compile and run the included samples:

```sh
cat scripts/hello.sh
./sh2elf scripts/hello.sh -o hello
./hello

./sh2elf scripts/test_huge_comprehensive.sh -o huge.elf
./huge.elf
```

## Parsing, Tokenizing, and Code Generation

The `sh2elf` compiler includes a fully integrated tokenizer and parser to transform raw shell script text into executable machine code:

### Tokenizer

- The tokenizer reads the shell script input character by character and breaks it into meaningful tokens while respecting shell syntax.
- It handles complex quoting rules:
  - Single quotes `'...'` treat everything literally until the closing quote.
  - Double quotes `"..."` allow escapes and preserve spaces within the string.
  - Backslash `\` escapes the next character.
- Token terminators include whitespace, pipeline symbols `|`, command separators `;` or newlines, and redirection symbols `<`, `>`.
- It accumulates characters into tokens until a terminator or quote is detected, enabling commands and arguments to be accurately extracted.

### Parser

- The parser consumes tokens sequentially and organizes them into a hierarchical structure representing the shell script logic:
  - **Stage**: Represents a single command and its arguments, along with input/output redirections.
  - **Pipeline**: A sequence of `Stage`'s connected by pipe `|` operators.
  - **Script**: One or more pipelines separated by command terminators (`;` or newline).
- Redirections are parsed and attached to the relevant `Stage`.
- Error checking is performed to detect syntax errors such as missing command after a pipe or unterminated quotes.
- The output is a tree like structure that fully describes the commands, their arguments, pipes, and redirections.

### Code Generation

- The structured script representation feeds into code emission routines generating native `x86_64` machine code.
- Built-in commands (`echo`, `cd`, `exit`) are implemented inline by emitting syscall instructions directly.
- External commands are executed using `fork()` and `execve()` syscalls; the exec path is resolved if not absolute by checking common bin directories.
- Pipelines are handled by creating pipes and managing file descriptors between forked children.
- Arguments and strings are stored in a dedicated string pool with relocations patched once the ELF layout is finalized.
- The final machine code is wrapped in a minimal ELF64 executable with proper headers and segments, making the binary runnable on Linux without dependencies.

Together, the tokenizer and parser transform text shell scripts into an intermediate representation that clearly separates lexical analysis, syntactic parsing, and code generation.

This low level modular design allows complex shell behavior to be implemented using just system calls, without an external interpreter, while maintaining clarity and correctness in the transformation from source text to executable machine code.

## ELF Generation and Machine Code Emission

### Machine Code Emission on `x86_64`

- The compiler generates raw `x86_64` machine instructions byte by byte into a dynamic buffer.
- Instruction helper functions emit opcodes and immediates manually, for example:
  - `mov_rax_imm32(c, x)` emits bytes for `mov rax, imm32`.
  - `syscall_(c)` emits the `syscall` instruction to invoke Linux kernel syscalls.
  - Conditional jumps (`je_rel32`, `jne_rel32`) emit placeholder offsets to be patched later once the target address is known.
- Registers (like `rax`, `rdi`, `rsi`, `rdx`, `r10`) are loaded with immediate values or addresses for syscall arguments.
- System calls for typical shell operations are implemented:
  - `sys_write` (write to file descriptor),
  - `sys_fork` (create child process),
  - `sys_execve` (execute a binary),
  - `sys_wait4` (wait for child process),
  - `sys_getcwd` (get current working directory),
  - `sys_mkdir` (create directory),
  - `sys_rmdir` (remove directory),
  - `sys_unlink` (remove file),
  - `sys_nanosleep` (pause execution),
  - `sys_newfstatat` (file/directory status check),
  - `sys_read` (read from file descriptor),
  - `sys_kill` (send signal to process),
  - `sys_chmod` (change file permissions),
  - file operations like `sys_openat`, `sys_dup2`, `sys_close` for managing redirections.

### String Pooling and Relocations

- All string literals (command arguments, file names) are stored in a read only string pool buffer.
- When emitting code that loads address of strings, a zero placeholder is emitted.
- These placeholders are registered in a relocation list to be patched later.
- After code emission is complete, the final absolute addresses of strings inside the ELF `.rodata` segment are used to patch the machine code.

### ELF64 Binary Construction

- The executable is built as a minimal `ELF64` file with these components:
  - **ELF header**: identifies `ELF64`, type executable, machine `x86_64`, entry point.
  - **Program headers (segments)**:
    - A loadable text segment containing machine code followed by the `.rodata` string pool.
    - A loadable `bss` segment reserved for uninitialized data used at runtime (e.g., environment pointers, pipe file descriptors, child pids).
- Sections are not included separately; only program segments are generated directly.
- Virtual addresses are chosen as conventional Linux `x86_64` load addresses (e.g., code at 0x400000, `.bss` at 0x600000).
- The binary is written out to the specified output filename, and file permissions are set to executable (0755).

### Integration of Parsing and Code Generation

- The parsed script structure is converted sequentially into machine code.
- For each parsed pipeline and stage:
  - Code for commands, argument setup, syscalls for fork/exec, and pipe/redirection management is emitted.
- Built-in commands bypass creating new processes; their behavior is implemented inline in assembly.
- Pipelines setup multiple pipes and forked children, duplicating file descriptors to implement Unix semantics.
- Error cases and exec failures include emitting code to print an error string then exit with error.

### Summary

This compiler manually assembles every byte of machine code and ELF headers from scratch, without assembler or linker, demonstrating full control over:

- Encoding of instructions and operands.
- Address and offset relocations for strings.
- ELF layout with precise segment and memory mapping.
- Implementation of shell like process and I/O management using Linux syscall ABI.


---

## License

This project is provided under the GPL3 License.

---
