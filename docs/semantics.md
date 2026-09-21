# Formal Semantics of sh2elf

This document specifies the formal denotational and operational semantics of the `sh2elf` compiler language subset, mapping POSIX shell source constructs to emitted `x86_64` machine code sequences and Linux kernel system call semantics.

---

## 1. Syntax Domain

Let $S$ represent a Shell Script, $P$ represent a Pipeline, $C$ represent a Command Stage, and $E$ represent an Expression or Parameter.

$$
\begin{aligned}
S &::= P_1 \mid P_1 \,;\dots;\, P_n \mid P_1 \mathbin{\&\&} P_2 \mid P_1 \mathbin{\vert\vert} P_2 \\
P &::= C_1 \mid C_1 \mathbin{\vert} C_2 \mathbin{\vert} \dots \mathbin{\vert} C_m \\
C &::= \text{Name} \,\, \text{Arg}_1 \dots \text{Arg}_k \, [\text{Redir}] \\
E &::= \$VAR \mid \$\{VAR\} \mid \$\{VAR\text{\#\#}pat\} \mid \$\{VAR\text{\%\%}pat\} \mid \$\{VAR/pat/rep\} \mid \$((A + B))
\end{aligned}
$$

---

## 2. Denotational Semantics

We define the compilation function $\mathcal{C} : \text{Script} \to \text{ELF64}$ mapping shell constructs into a target state tuple $\langle \text{Code}, \text{StrPool}, \text{Relocations}, \text{BSS} \rangle$.

### 2.1 Simple Commands & Syscall Inlining
For a command $C = \langle \text{Name}, a_1, \dots, a_k \rangle$:

$$
\mathcal{C}\llbracket \text{printf } s \rrbracket = \text{mov } rdi, 1 \;\Vert\; \text{mov } rsi, \text{Addr}(s) \;\Vert\; \text{mov } rdx, \text{Len}(s) \;\Vert\; \text{mov } rax, 1 \;\Vert\; \text{syscall}
$$

$$
\mathcal{C}\llbracket \text{pwd} \rrbracket = \text{mov } rdi, \text{BSS}_{\text{pwd}} \;\Vert\; \text{mov } rsi, 65536 \;\Vert\; \text{mov } rax, 79 \;\Vert\; \text{syscall}
$$

$$
\mathcal{C}\llbracket \text{exit } n \rrbracket = \text{mov } rdi, n \;\Vert\; \text{mov } rax, 60 \;\Vert\; \text{syscall}
$$

### 2.2 Pipeline Semantics ($\mathcal{C}\llbracket P_1 \mid P_2 \rrbracket$)
For a two-stage pipeline $C_1 \mid C_2$:
1. $P \leftarrow \text{sys\_pipe}(fd[2])$
2. $pid_1 \leftarrow \text{sys\_fork}()$; if $pid_1 = 0$, $\text{sys\_dup2}(fd[1], 1)$, $\text{sys\_close}(fd[0])$, execute $C_1$.
3. $pid_2 \leftarrow \text{sys\_fork}()$; if $pid_2 = 0$, $\text{sys\_dup2}(fd[0], 0)$, $\text{sys\_close}(fd[1])$, execute $C_2$.
4. Parent closes $fd[0], fd[1]$, executes $\text{sys\_wait4}(pid_1)$, $\text{sys\_wait4}(pid_2)$, and stores status of $pid_2$ into BSS status register ($\text{BSS}_{\text{status}}$).

### 2.3 Short-Circuit Logic ($\mathcal{C}\llbracket P_1 \mathbin{\&\&} P_2 \rrbracket$)
$$
\mathcal{C}\llbracket P_1 \mathbin{\&\&} P_2 \rrbracket = \mathcal{C}\llbracket P_1 \rrbracket \;\Vert\; \text{cmp } [\text{BSS}_{\text{status}}], 0 \;\Vert\; \text{jne } L_{\text{skip}} \;\Vert\; \mathcal{C}\llbracket P_2 \rrbracket \;\Vert\; L_{\text{skip}}:
$$

---

## 3. Parameter Expansion Algorithms

### 3.1 Pattern Stripping (${VAR##pat}$ and ${VAR%%pat}$)
- Prefix stripping ($\# / \#\#$) evaluates $\text{fnmatch}(pat, S[0..k])$ for $k = 1 \dots |S|$. Shortest match ($\#$) stops at min $k$; longest match ($\#\#$) stops at max $k$.
- Suffix stripping ($\% / \%\%$) evaluates $\text{fnmatch}(pat, S[k..|S|])$. Shortest match ($\%$) stops at max $k$; longest match ($\%\%$) stops at min $k$.

### 3.2 Dynamic Substitution (${VAR/pat/rep}$ and ${VAR//pat/rep}$)
- Scans input buffer $S$. First match of $pat$ via substring or glob is replaced with $rep$. Global replacement ($\slash\slash$) continues scanning after replacement offset until end of buffer.

---

## 4. Execution Memory Model

- **Text Segment (`.text`)**: Executable segment (Read + Execute, VADDR `0x400000 + headers`). Emitted machine code instructions.
- **Read-Only Data (`.rodata`)**: Deduplicated string pool storage.
- **BSS Segment (`.bss`)**: Zero-initialized memory (Read + Write, VADDR `0x600000`).
  - `BSS + 0`: Exit status register (8 bytes).
  - `BSS + 8`: POSIX positional parameters stack frame pointers (`$0..$9`, `$#`, `$@`).
  - `BSS + 256`: Dynamic variable hashtable / key-value store.
  - `BSS + 4352`: Streaming I/O buffer ($64\,\text{KB}$).
