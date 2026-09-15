section .text
global _start



_start:
    mov rdi, 2
    mov rsi, 3
    mov rdx, 4
    
    call make_and_sum

    mov rdi, rax
    mov rax, 60

    syscall

make_and_sum:
    push rbp
    mov rbp, rsp

    sub rsp, 32
    
    call square
    mov [rbp-8], rax 

    mov rdi, rsi
    call square
    mov [rbp-16], rax

    mov rdi, rdx
    call square
    mov [rbp-24], rax
    
    ;Lade startadresse in rdi
    lea rdi, [rbp-24]
    mov rsi, 3 ; 3 Werte zum summieren (count)
    call array_sum

    
    mov rsp, rbp
    pop rbp
    ret
    

array_sum:
    push rbp
    mov rbp, rsp

    mov rax, 0 ; summe
    mov rcx, 0 ; index i

loop_start:
    cmp rcx, rsi
    jge quit
    
    add rax, [rdi + rcx*8]
    inc rcx 
    jmp loop

loop_end:
    pop rbp
    ret

square:
    push rbp
    mov rbp, rsp
    mov rax, rdi
    imul rax, rax
    pop rbp
    ret
