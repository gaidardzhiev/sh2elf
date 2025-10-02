# sh2elf

`sh2elf` is a compiler that translates a restricted subset of `POSIX` shell scripts into statically positioned `ELF` executables for`x86_64` `Linux`. The generated programs rely only on raw system calls and bundle command strings inside the binary.

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
./sh2elf tests/hello.sh -o hello
./hello

./sh2elf tests/pipeline.sh -o pipeline
./pipeline
```

---

## License

This project is provided under the GPL3 License.

---
