section .text
global _start
; ===== General Purpose Registers (x86-64) =====
; rax  -> Accumulator, commonly used for return values / arithmetic results
; rbx   -> Base, callee-saved (must be restored by function if used)
; rcx    -> Counter, often used for loop counters, 4th function argument
; rdx     -> Data, 3rd function argument, holds upper bits in mul/div
; rsi      -> Source Index, 2nd function argument, source address in string ops
; rdi       -> Destination Index, 1st function argument, destination address in string ops
; rsp        -> Stack Pointer, points to current top of stack
; rbp         -> Base Pointer, fixed reference point for current stack frame
; r8            -> 5th function argument
; r9             -> 6th function argument
; r10              -> caller-saved, otherwise freely usable
; r11               -> caller-saved, otherwise freely usable
; r12-r15            -> callee-saved, freely usable (must be restored if used)

_start:
    mov rax, 0 ; Summe
    mov rcx, 1 ; Zähler

loop_start:
    add rax, rcx
    inc rcx 

    cmp rcx, 5
    jg loop_end

    jmp loop_start


loop_end:
    ; Result as exit code
    mov rdi, rax
    mov rax, 60
    syscall
