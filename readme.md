# sh2elf

This project is a minimalistic shell script compiler written in `C` that compiles shell scripts into `ELF64` executables for `Linux` on `x86_64` architecture. It translates shell command lines into machine code, embeds them in an `ELF` binary, and handles process control and system calls natively without relying on an external shell or interpreter.

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

- **Pipelines**: the `|` operator connects stdout of the left stage to stdin of the right one. Arbitrary length pipelines are supported, mixing built-ins and external commands.

- **Redirection**: each stage accepts a single input (`< file`) and single output redirection (`> file` overwrite, `>> file` append). Redirections must have a word argument and cannot appear without an accompanying command.

- **Built-ins**:
  - `echo` prints its arguments separated by single spaces and appends a newline.
  - `cd` changes to the provided directory (`cd DIR`). Missing arguments are ignored.
  - `exit` terminates the program with status 0.

- **External commands**: names containing `/` are executed verbatim. Otherwise the compiler tries `/bin/NAME` and then `/usr/bin/NAME`. No `PATH` lookup occurs. The runtime passes an empty environment (`envp` terminates with NULL).

- **Tokenisation & quoting**:
  - Unquoted tokens are split on spaces, tabs, and carriage returns.
  - Backslash outside quotes escapes the next character (e.g. `echo foo\ bar`).
  - Single quotes (`'literal'`) preserve characters verbatim until the matching `'`.
  - Double quotes recognise `"`, `\`, `\$`, and ``\` `` escapes; all other backslash pairs keep the backslash (e.g. `"Hello\n"` stays `Hello\n`).
  - Newlines inside double quotes can be escaped with `\` + newline (line continuation).

- **Argument vectors**: argv is constructed exactly as parsed; no globbing, parameter expansion, command substitution, arithmetic expansion, nor brace expansion is implemented.

### Not supported

- Comments (`# ...`), background jobs (`&`), logical operators (`&&`, `||`), subshells, functions, here documents, `set`, variable assignment, or environment inheritance.
- Signals are not trapped; generated programs exit on failed `execve` or unhandled system call errors.

## Examples

Translate and run the included samples:

```sh
./sh2elf scripts/hello.sh -o hello
./hello

./sh2elf scripts/pipeline.sh -o pipeline
./pipeline
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
  - **Pipeline**: A sequence of `Stage`s connected by pipe `|` operators.
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
