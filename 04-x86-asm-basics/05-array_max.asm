section .data
numbers: dq 3, 17, 8, 42, 15

section .text
global _start

_start:
    mov rbx, numbers ; Array Start 
    mov rcx, 0 ; Index
    mov rax, [rbx] ; Max value
    inc rcx

loop_start:
    cmp rcx, 5
    jge loop_end

    ; Index 1 of array
    mov rdx, [rbx + rcx*8]
    cmp rdx, rax
    jge update_max
    jmp skip_update

skip_update:
    inc rcx
    jmp loop_start

update_max: 
    mov rax, rdx
    inc rcx
    jmp loop_start

loop_end:
    mov rdi, rax
    mov rax, 60
    syscall