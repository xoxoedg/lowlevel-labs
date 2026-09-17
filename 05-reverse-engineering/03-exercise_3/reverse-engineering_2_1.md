# Reverse Engineering 2.1

## Ziel

Vor allem ging es in dieser Übung darum, sich mit den unterschiedlichen Rechten
(Permissions) der einzelnen Sections vertraut zu machen. Jede Section landet beim
Linken in einem eigenen LOAD-Segment mit eigenen Flags (r--, r-x, rw-), und die MMU
setzt beim Laden der Binary für jede Page genau diese Rechte durch.

### Was ist ein Segmentation Fault

Ein Segmentation Fault (SIGSEGV) ist ein Signal, das der Kernel an einen Prozess
schickt, wenn dieser auf eine Speicheradresse zugreift, auf die er nicht zugreifen
darf. Bei jedem Speicherzugriff prüft die MMU anhand der Page-Tabelle, ob die
Adresse gemappt ist und ob die Zugriffsart (read/write/execute) erlaubt ist. Passt
das nicht zusammen, löst die Hardware einen Fault aus, der Kernel erkennt, dass der
Zugriff illegal war, und schickt dem Prozess SIGSEGV. Ohne eigenen Signal-Handler
wird der Prozess dadurch sofort beendet.

Im Wesentlichen gibt es zwei Fälle, die dazu führen:

1. Nicht gemappte Adressen: Die Adresse liegt in keinem der dem Prozess
   zugewiesenen Speicherbereiche, zum Beispiel bei einem wilden Pointer oder einem
   Nullpointer-Zugriff.
2. Fehlende Rechte: Die Adresse ist zwar gemappt, aber der Zugriff verletzt die für
   diese Page gesetzten Rechte, etwa ein Schreibzugriff auf eine read-only Page.

In `hello.s` trifft Fall zwei zu. `mov byte [msg], 'X'` schreibt in `.rodata`, die
laut Programm-Header nur mit `r--` gemappt ist, deswegen crasht das Programm dort.
`.data` dagegen ist mit `rw-` gemappt, ein Schreibzugriff auf `str` wäre also
problemlos möglich gewesen.

## Quellcode

`hello.s`:

```asm
global _start

; exec sagt, dass die section automatisch executabke permission bekommt
section .mycodesection exec

_addone:
    ret

_start:
    call _addone
    
    mov rax, 1      ; write(
    mov rdi, 1      ;   STDOUT,FILENO,
    mov rsi, msg    ;   "hello, world\n”
    mov rdx, msglen ;   sizeof("hello, world\n")
    syscall         ; );


    ; try ti write to rodata (read only) section
    mov byte [msg], 'X' 
    mov rax, 60     ; exit(
    mov rdi, 0      ;   EXIT_SUCESS
    syscall         ; );

section .data 
    str: db "d"


section .rodata
    msg: db "hello, world", 10
    msglen: equ $ - msg
```

## objdump Output

```bash
$ objdump -x -M intel hello
```

```
hello:     Dateiformat elf64-x86-64
hello
Architektur: i386:x86-64, Flags 0x00000112:
EXEC_P, HAS_SYMS, D_PAGED
Startadresse 0x0000000000401001

Programm-Header:
    LOAD off    0x0000000000000000 vaddr 0x0000000000400000 paddr 0x0000000000400000 align 2**12
         filesz 0x0000000000000120 memsz 0x0000000000000120 flags r--
    LOAD off    0x0000000000001000 vaddr 0x0000000000401000 paddr 0x0000000000401000 align 2**12
         filesz 0x0000000000000035 memsz 0x0000000000000035 flags r-x
    LOAD off    0x0000000000002000 vaddr 0x0000000000402000 paddr 0x0000000000402000 align 2**12
         filesz 0x000000000000000d memsz 0x000000000000000d flags r--
    LOAD off    0x0000000000002010 vaddr 0x0000000000403010 paddr 0x0000000000403010 align 2**12
         filesz 0x0000000000000001 memsz 0x0000000000000001 flags rw-

Sektionen:
Idx Name          Size      VMA               LMA               File off  Algn
  0 .mycodesection 00000035  0000000000401000  0000000000401000  00001000  2**0
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  1 .rodata       0000000d  0000000000402000  0000000000402000  00002000  2**2
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  2 .data         00000001  0000000000403010  0000000000403010  00002010  2**2
                  CONTENTS, ALLOC, LOAD, DATA
SYMBOL TABLE:
0000000000000000 l    df *ABS*    0000000000000000 hello.s
0000000000401000 l       .mycodesection    0000000000000000 _addone
0000000000403010 l       .data    0000000000000000 str
0000000000402000 l       .rodata    0000000000000000 msg
000000000000000d l       *ABS*    0000000000000000 msglen
0000000000401001 g       .mycodesection    0000000000000000 _start
0000000000403011 g       .data    0000000000000000 __bss_start
0000000000403011 g       .data    0000000000000000 _edata
0000000000403018 g       .data    0000000000000000 _end
```

## Beobachtungen

Es gibt vier separate LOAD-Segmente, eines pro Permission-Kombination: der
ELF-Header (`r--`), `.mycodesection` (`r-x`), `.rodata` (`r--`) und `.data`
(`rw-`). Der Linker fasst Sections mit gleichen Flags zwar zusammen, legt aber für
jede unterschiedliche Rechtekombination ein eigenes Segment an, damit die
Page-Permissions beim Laden sauber getrennt gesetzt werden können.

`.mycodesection` ist `r-x` (READONLY, CODE), also ausführbar dank `exec`-Attribut
in der `section`-Direktive, aber nicht beschreibbar. `.rodata` ist `r--`
(READONLY, DATA), und genau hier scheitert `mov byte [msg], 'X'`, weil die Page
keine Schreibrechte hat. `.data` ist `rw-`, ein Schreibzugriff auf `str` wäre hier
also erlaubt gewesen und hätte keinen Segfault ausgelöst.
