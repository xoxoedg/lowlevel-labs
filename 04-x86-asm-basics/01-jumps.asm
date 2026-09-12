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
    mov rax, 6
    mov rbx, 7
    
    ;Multiplies operand with value in rax register
    ; Stores the result in rdx:rax register
    ; rax -> stores the lower 64 bits
    ; rdx -> stores the higher 64 bits
    
    mul rbx
    cmp rax, 40
    ; Springt wenn rax > 40 (jump greater)
    jg groesser

    mov rdi, 0
    jmp ende



groesser:
    ; Setze exit status auf 1
    mov rdi, 1

ende: 
    mov rax, 60
    syscall