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
