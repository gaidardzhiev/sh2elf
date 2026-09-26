#!/bin/sh
printf 'h\303\251llo w\303\266rld
\346\227\245\346\234\254\350\252\236\343\203\206\343\202\255\343\202\271\343\203\210
abc
' > /tmp/sh2elf_cutu
cut -c1-3 /tmp/sh2elf_cutu
cut -c2 /tmp/sh2elf_cutu
cut -c3- /tmp/sh2elf_cutu
cut -c-2,5 /tmp/sh2elf_cutu
cut -c2-3 --complement /tmp/sh2elf_cutu
cut -c1,3 --output-delimiter=: /tmp/sh2elf_cutu
cut -b1-2 -n /tmp/sh2elf_cutu
cut -b2-3 -n /tmp/sh2elf_cutu
cut -b4- -n /tmp/sh2elf_cutu
cut -b-4 -n /tmp/sh2elf_cutu
cut -b3 -n /tmp/sh2elf_cutu
printf 'a§b§c\n' | cut -d§ -f2
printf 'a§b§c\nnone\n' | cut -d§ -f1,3 -s
printf 'a§b§c\n' | cut -d§ -f2- --output-delimiter=+
rm -f /tmp/sh2elf_cutu
