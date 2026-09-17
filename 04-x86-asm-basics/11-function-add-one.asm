section .text
global _start

_start:

    push msglen
    push msg
    call _addone
    
    mov rax,1  ; 1 = write syscall
    mov rdi,1  ; fd hier stdout = 1
    mov rsi, msg ; adresse des buffers
    mov rdx, msglen ; n bytees

    syscall

    mov rax, 60
    mov rdi, 0

    syscall
;[rbp + 0]   = alter rbp
;[rbp + 8]   = Return-Adresse (RA)
;[rbp + 16]  = msg
;[rbp + 24]  = msglen


_addone:
    push rbp
    mov rbp, rsp

    mov rcx, 0 ; counter
    mov r9, [rbp+16]  ; mgs
    mov r10, [rbp+24] ; msglen

    jmp _loop


_loop:
    
    cmp rcx, r10
    jge .done
    add byte [r9+rcx], 1

    inc rcx
    jmp _loop

    
.done:
    pop rbp 
    ret

section .data
    msg: db "hello, world", 10
    msglen: equ $ - msg
