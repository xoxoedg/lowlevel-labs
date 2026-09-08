section .data
msg db "Hello, World!", 10    ; 10 = Zeilenumbruch (Newline), wie \n
msg_len equ $ - msg              ; berechnet automatisch die Länge des Strings

section .text
global _start

_start:
    mov rax, 1          ; syscall: write
    mov rdi, 1           ; file descriptor: stdout
    mov rsi, msg          ; Adresse des Strings
    mov rdx, msg_len        ; Länge des Strings
    syscall

    mov rax, 60           ; syscall: exit
    mov rdi, 0
    syscall