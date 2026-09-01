CC = gcc
CFLAGS = -fno-stack-protector -z execstack -no-pie -g
TARGET = vuln
SRC = vuln.c

.PHONY: all clean disasm run

all: $(TARGET)

$(TARGET): $(SRC)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRC)

disasm: $(TARGET)
	objdump -d $(TARGET) | grep -A 10 "<secret>:"

run: $(TARGET)
	./$(TARGET) $(ARGS)

clean:
	rm -f $(TARGET)