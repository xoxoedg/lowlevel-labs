# Flaches Makefile fuer NASM x86-64 Labs (reine syscalls, Entry = _start)
#
#   make            -> alle *.asm zu *.elf bauen
#   make hello.elf  -> nur ein Ziel bauen
#   make run-hello  -> hello.elf bauen und ausfuehren
#   make clean      -> *.o und *.elf loeschen

NASM      := nasm
NASMFLAGS := -f elf64 -g -F dwarf
LD        := ld
LDFLAGS   :=

SRCS := $(wildcard *.asm)
OBJS := $(SRCS:.asm=.o)
BINS := $(SRCS:.asm=.elf)

.PHONY: all clean
all: $(BINS)

%.o: %.asm
	$(NASM) $(NASMFLAGS) $< -o $@

%.elf: %.o
	$(LD) $(LDFLAGS) $< -o $@

# make run-hello  ==  bauen + ausfuehren
run-%: %.elf
	./$<

clean:
	$(RM) $(OBJS) $(BINS)

.PRECIOUS: %.o
