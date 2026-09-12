section .text
global _start

_start:
    mov rax, 1
    mov rdx, 1


loop_start:
    mul rdx
    inc rdx

    cmp rdx, 5
    jg loop_end
    jmp loop_start

loop_end:
    mov rdi, rax
    mov rax, 60
    syscall