section .text
global _start 
; calling convention:
; First six arguments are passed in RDI, RSI, RDX, RCX, R8, R9, rest on stack right to left
; Return value in RAX
; Caller-saved: RAX, R10, R11, RDI, RSI, RDX, RCX, R8, R9
; Callee-saved: RBX, RBP, R12, R13, R14, R15

_start:
    mov rdi, 7 ; arg1
    mov rsi, 12 ; arg2
    ; rsp = rsp - 8, [rsp] = ra
    call max

    mov rdi, rax
    mov rax, 60
    syscall


max:    
    ; Prolog rsp = rsp - 8 - 8 = rsp => rsp-16
    push rbp
    mov rbp, rsp

    cmp rdi, rsi
    jg setmax
    mov rax, rsi
    jmp ende

setmax:
    mov rax, rdi

ende:
    ; Epilog
    ; rsp = rsp - 16 + 8 => rsp = -8 
    pop rbp
    ; rsp = rsp - 8 -> rsp = rsp
    ret 
