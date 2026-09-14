# Reverse Engineering 2

## Exercise 1 — Calling Conventions

Diesmal wechselt **nur `alg`** auf die Microsoft x64 ABI — `my_entry` bleibt bei der
System V AMD64 ABI (Standard unter Linux). Damit das funktioniert, müssen Caller
(`my_entry`, ruft `alg` auf) und Callee (`alg` selbst) sich einig sein, welche Convention
für den Aufruf von `alg` gilt — deshalb wird `alg` sowohl in der Deklaration
(`myprog.c`) als auch in der Definition (`mylib.c`) mit `__attribute__((ms_abi))`
markiert. `my_entry` selbst behält ihre normale (System-V-)Signatur, da sie ja nur von
außen (dem Loader über `-e my_entry`) aufgerufen wird und nicht `alg`-intern ist.

Kompiliert mit:

```bash
$ gcc -o myprog_mscall myprog.c mylib.c -O0 -e my_entry -nostdlib -nostartfiles -lc
```

## Quellcode

`myprog.c`:

```c
//defines _exit
//Microsoft ABI
#include <unistd.h>

int __attribute__((ms_abi)) alg(int n);
int my_var1 = 0xAB;

//System V AMD ABI
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
//Microsoft ABI
int __attribute__((ms_abi)) alg(int n)
{
    if (n <= 1)
        return 1;
    return n * alg(n-1);
}
```

## objdump Output

```bash
$ objdump -d -M intel myprog_mscall
```

```
Disassembly of section .text:

0000000000001030 <my_entry>:
    1030:	f3 0f 1e fa          	endbr64
                                    //Prolog
    1034:	55                   	push   rbp
    1035:	48 89 e5             	mov    rbp,rsp
    1038:	53                   	push   rbx              -> rbx sichern (callee-saved, wie in SysV) -> my_entry selbst ist SysV
    1039:	48 83 ec 18          	sub    rsp,0x18         -> 24 Byte für lokale Variablen, wie gewohnt (kein XMM-Save nötig, my_entry ist SysV)
    103d:	c7 45 ec 03 00 00 00 	mov    DWORD PTR [rbp-0x14],0x3   -> Initialisiere my_var2 = 3
    1044:	c7 45 e8 00 00 00 00 	mov    DWORD PTR [rbp-0x18],0x0   -> Initialisiere i = 0
    104b:	90                   	nop
    104c:	83 7d e8 05          	cmp    DWORD PTR [rbp-0x18],0x5   -> i < 6
    1050:	7f 27                	jg     1079 <my_entry+0x49>
    1052:	8b 15 a8 2f 00 00    	mov    edx,DWORD PTR [rip+0x2fa8]        # 4000 <my_var1>
    1058:	8b 45 ec             	mov    eax,DWORD PTR [rbp-0x14]   -> lade my_var2
    105b:	8d 1c 02             	lea    ebx,[rdx+rax*1]            -> ebx = my_var1 + my_var2
    105e:	8b 45 e8             	mov    eax,DWORD PTR [rbp-0x18]   -> lade i
    1061:	48 83 ec 20          	sub    rsp,0x20                   -> Shadow Space: my_entry ruft alg (ms_abi) auf -> Caller muss 32 Byte reservieren
    1065:	89 c1                	mov    ecx,eax                    -> Argument für alg jetzt in ecx statt edi (ms_abi)
    1067:	e8 14 00 00 00       	call   1080 <alg>
    106c:	48 83 c4 20          	add    rsp,0x20                   -> Shadow Space wieder freigeben
    1070:	01 d8                	add    eax,ebx                    -> eax += ebx (Rückgabewert von alg + my_var1 + my_var2)
    1072:	89 c7                	mov    edi,eax                    -> Argument für _exit weiterhin in edi (_exit ist SysV/libc)
    1074:	e8 a7 ff ff ff       	call   1020 <_exit@plt>
    1079:	90                   	nop
    107a:	48 8b 5d f8          	mov    rbx,QWORD PTR [rbp-0x8]    -> rbx wiederherstellen
                                    //Epilog
    107e:	c9                   	leave
    107f:	c3                   	ret

0000000000001080 <alg>:
    1080:	f3 0f 1e fa          	endbr64
                                    //Prolog
    1084:	55                   	push   rbp
    1085:	48 89 e5             	mov    rbp,rsp
    1088:	48 83 ec 20          	sub    rsp,0x20                     -> Shadow Space (ms_abi reserviert immer 32 Byte für den Caller)
    108c:	89 4d 10             	mov    DWORD PTR [rbp+0x10],ecx     -> ms_abi: 1. Argument kommt in ecx statt edi
    108f:	83 7d 10 01          	cmp    DWORD PTR [rbp+0x10],0x1     -> Vergleiche n mit 1
    1093:	7f 07                	jg     109c <alg+0x1c>
    1095:	b8 01 00 00 00       	mov    eax,0x1                      -> return 1
    109a:	eb 11                	jmp    10ad <alg+0x2d>
    109c:	8b 45 10             	mov    eax,DWORD PTR [rbp+0x10]
    109f:	83 e8 01             	sub    eax,0x1                      -> eax = n - 1
    10a2:	89 c1                	mov    ecx,eax                      -> Argument für rekursiven Aufruf (ms_abi -> ecx)
    10a4:	e8 d7 ff ff ff       	call   1080 <alg>
    10a9:	0f af 45 10          	imul   eax,DWORD PTR [rbp+0x10]     -> eax = alg(n-1) * n
                                    //Epilog
    10ad:	c9                   	leave
    10ae:	c3                   	ret
```

## Beobachtungen

- **`my_entry` selbst sieht fast aus wie die reine SysV-Version** (`push rbx`, `sub rsp,0x18`,
  keine XMM-Saves) — der einzige Unterschied ist der `sub rsp,0x20` / `add rsp,0x20`
  rund um den `call alg`, sowie `mov ecx,eax` statt `mov edi,eax`.
- **Shadow Space wird nur um den `alg`-Aufruf herum reserviert** (`1061`/`106c`), nicht
  für den ganzen Funktionskörper — im Gegensatz zu einer Funktion, die selbst komplett
  in ms_abi kompiliert ist (dort steht `sub rsp` einmalig im Prolog).
- **Kein XMM6-15 Save/Restore in `my_entry`**, weil `my_entry` selbst nicht `ms_abi` ist
  und daher nicht die (viel größeren) callee-saved-Pflichten der Microsoft ABI hat —
  diese gelten nur für `alg`, das aber hier keine XMM-Register benutzt.
- **`alg` selbst** sieht identisch aus wie im Fall, in dem beide Funktionen ms_abi waren:
  Argument in `ecx`, `sub rsp,0x20` als eigener Shadow-Space-Puffer.
- **`_exit`** bleibt unverändert System V (`edi`), da es aus der libc kommt und nicht
  angepasst wurde — im selben Binary sind also drei verschiedene Aufruf-Konventionen
  gleichzeitig aktiv: SysV für `my_entry`/`_exit`, ms_abi für `alg`.

## Data Section

```bash
$ objdump -s -j .data -M intel myprog_mscall
```

```
Inhalt von Abschnitt .data:
 4000 ab000000                             ....
```
