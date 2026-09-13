section .data
; db = define byte -> 't', 'e', 's', 't', '.' .... 
    filename db "test.txt", 0

; 256 Bytes Buffer reservieren (unintialisiert-> deswegen .bss)
section .bss
    buffer resb 256

section .text
global _start

; ================================
; Linux x86-64 Syscall Konvention
; ================================
; rax = Syscall-Nummer (rein) / Rückgabewert (raus)
; Argumente: rdi, rsi, rdx, r10, r8, r9

; Syscall  | Nr | rdi          | rsi              | rdx
; ---------|----|--------------|------------------|--------
; read     | 0  | fd           | buffer-Adresse   | Anzahl Bytes
; write    | 1  | fd           | buffer-Adresse   | Anzahl Bytes
; open     | 2  | Pfad-Adresse | flags            | mode
; close    | 3  | fd           | -                | -
; exit     | 60 | exit code    | -                | -

; open flags (fcntl.h):
; O_RDONLY = 0
; O_WRONLY = 1
; O_RDWR   = 2
; O_CREAT  = 0x40 (= 64, oktal 0100)

; Rückgabewerte in rax:
; open  -> neuer File-Descriptor (negativ = Fehler)
; read  -> Anzahl gelesener Bytes (0 = EOF, negativ = Fehler)
; write -> Anzahl geschriebener Bytes

_start:
    ; Open
    mov rax, 2 ; syscall open()
    mov rdi, filename ; Adresse in rdi ablegen
    mov rsi, 0  ; mit mode O_RDONLY öffnen
    mov rdx, 0 
    
    ; Legt fd in rax ab
    syscall

    mov rbx, rax ; fd nun in rbx

    ; Read 
    mov rax, 0
    mov rdi, rbx
    mov rsi, buffer
    mov rdx, 256

    syscall 

    mov r12, rax ; Save number of bytes read

    ; Write     
    mov rax, 1
    mov rdi , 1 ; 1=stdout 0=stdin 2=stderr
    mov rsi, buffer
    mov rdx, r12

    syscall

    ; Close fd 
    mov rdi, rbx
    mov rax, 3

    syscall

    ; exit 
    mov rdi, rsi
    mov rax, 60
    syscall


    