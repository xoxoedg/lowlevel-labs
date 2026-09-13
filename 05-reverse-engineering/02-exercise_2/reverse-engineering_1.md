# Reverse Engineering 1

Disassemble der Binary mit:

```
objdump -d -M intel bin/myprog0
```

## Quellcode

`myprog.c`:

```c
//defines _exit
#include <unistd.h>

int alg(int n);
int my_var1 = 0xAB;


int my_entry(void)
{
    int my_var2 = 3;
    for (int i = 0; i < 6; ++i)
    {
        _exit(my_var1 + my_var2 + alg(i));
    }
	
}
```

`mylib.c`:

```c
int alg(int n)
{
    if (n <= 1)
        return 1;
    return n * alg(n-1);
}
```

## objdump Output

BYTE = 1 Byte (8 Bit)
WORD = 2 Bytes (16 Bit)
DWORD = Double WORD = 4 Bytes (32 Bit)
QWORD = Quad WORD = 8 Bytes (64 Bit)

```
Disassembly of section .text:

0000000000001030 <my_entry>:
    1030:       f3 0f 1e fa             endbr64
                                    //Prolog
    1034:       55                      push   rbp
    1035:       48 89 e5                mov    rbp,rsp 
    1038:       53                      push   rbx   -> Save rbx (callee saved)  rsp - 8
    1039:       48 83 ec 18             sub    rsp,0x18  -> Platziere 24 Bytes auf dem Stack rsp - 32 dann insgesamt
    103d:       c7 45 ec 03 00 00 00    mov    DWORD PTR [rbp-0x14],0x3 -> Initialisiere: my_var2 (schreibe Zahl 3 an Arbeisspeicher Position rbp-0x14) 
    1044:       c7 45 e8 00 00 00 00    mov    DWORD PTR [rbp-0x18],0x0 -> Initialisiere: loop variable i=0 an Ram Position rbp-0x18
    104b:       90                      nop                             -> No Operation
    104c:       83 7d e8 05             cmp    DWORD PTR [rbp-0x18],0x5 -> i < 6
    1050:       7f 1f                   jg     1071 <my_entry+0x41>     -> Springt hierhin 1072
    1052:       8b 15 a8 2f 00 00       mov    edx,DWORD PTR [rip+0x2fa8]        # 4000 <my_var1>
    1058:       8b 45 ec                mov    eax,DWORD PTR [rbp-0x14] -> Lade my_var2 in eax
    105b:       8d 1c 02                lea    ebx,[rdx+rax*1]          -> ebx=my_var1 + my_var2 
    105e:       8b 45 e8                mov    eax,DWORD PTR [rbp-0x18]
    1061:       89 c7                   mov    edi,eax
    1063:       e8 10 00 00 00          call   1078 <alg>
    1068:       01 d8                   add    eax,ebx
    106a:       89 c7                   mov    edi,eax
    106c:       e8 af ff ff ff          call   1020 <_exit@plt>
    1071:       90                      nop
    1072:       48 8b 5d f8             mov    rbx,QWORD PTR [rbp-0x8]
    1076:       c9                      leave
    1077:       c3                      ret

0000000000001078 <alg>:
    1078:       f3 0f 1e fa             endbr64
    107c:       55                      push   rbp
    107d:       48 89 e5                mov    rbp,rsp
    1080:       48 83 ec 10             sub    rsp,0x10
    1084:       89 7d fc                mov    DWORD PTR [rbp-0x4],edi
    1087:       83 7d fc 01             cmp    DWORD PTR [rbp-0x4],0x1
    108b:       7f 07                   jg     1094 <alg+0x1c>
    108d:       b8 01 00 00 00          mov    eax,0x1
    1092:       eb 11                   jmp    10a5 <alg+0x2d>
    1094:       8b 45 fc                mov    eax,DWORD PTR [rbp-0x4]
    1097:       83 e8 01                sub    eax,0x1
    109a:       89 c7                   mov    edi,eax
    109c:       e8 d7 ff ff ff          call   1078 <alg>
    10a1:       0f af 45 fc             imul   eax,DWORD PTR [rbp-0x4]
    10a5:       c9                      leave
    10a6:       c3                      ret
```

## Data Section

```
objdump -s -j .data -M intel bin/myprog0
```

```
bin/myprog0:     Dateiformat elf64-x86-64

Inhalt von Abschnitt .data:
 4000 ab000000                             ....
```
