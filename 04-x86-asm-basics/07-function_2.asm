section .text
global _start


_start: 
    mov rdi, 3 ; a
    mov rsi, 9 ; b
    mov rdx, 5 ; c
    call max3


    mov rdi, rax
    mov rax, 60
    syscall

max3: 
    push rbp
    mov rbp, rsp

    push rbx 
    mov rbx, rdx ; rbx = 5

    call max 

     ; Konvention rdi 1 argument/ rsi 2 argument
    mov rdi, rax
    mov rsi, rbx

    call max

    pop rbx
    pop rbp
    ret


max:
    push rbp
    mov rbp, rsp 

    cmp rdi, rsi
    jg setmax

    mov rax, rsi 
    jmp ende

setmax:
    mov rax, rdi
    

ende:
    pop rbp
    ret
 
   