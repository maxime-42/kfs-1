TARGET = myos
ISO = $(TARGET).iso

C_SOURCES = $(wildcard *.c)
ASM_SOURCES = $(wildcard *.s)

C_OBJECTS = $(C_SOURCES:.c=.o)
ASM_OBJECTS = $(ASM_SOURCES:.s=.o)

CFLAGS = -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -ffreestanding -O2 -nostdlib

GRUB_CFG = grub.cfg

$(TARGET).iso: $(TARGET).bin $(GRUB_CFG)
	mkdir -p isodir/boot/grub
	cp $(TARGET).bin isodir/boot/$(TARGET).bin
	cp $(GRUB_CFG) isodir/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) isodir

$(TARGET).bin: boot.o kernel.o
	i686-elf-gcc -T linker.ld -o $@ $(LDFLAGS) $^ -lgcc

boot.o: boot.s
	i686-elf-as $< -o $@

kernel.o: kernel.c
	i686-elf-gcc -c $< -o $@ $(CFLAGS)

run: $(ISO)
	qemu-system-i386 -kernel $(TARGET).bin
	#qemu-system-i386 -cdrom $(ISO)

grub-check:
	grub-file --is-x86-multiboot $(TARGET).bin

clean:
	rm -rf *.o $(TARGET).bin isodir $(ISO)
