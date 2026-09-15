section .text
global _start

_start:
    mov rdi, 2 
    mov rsi, 3
    mov rdx, 4
    mov r12, 0

    call sum_of_square

    mov rdi, rax
    mov rax, 60

    syscall

sum_of_square:
    push rbp
    mov rbp, rsp
    push r12
    call square

    add r12, rax

    mov rdi, rsi
    call square
      
    add r12, rax

    mov rdi, rdx
    call square 

    add r12, rax

    mov rax, r12

    pop r12
    pop rbp
    ret



square:  
    push rbp
    mov rbp, rsp

    mov rax, rdi
    imul rax, rax 

    pop rbp
    ret
    
