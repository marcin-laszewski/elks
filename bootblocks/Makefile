# for CONFIG_ROMCODE
include $(TOPDIR)/.config

CC = ia16-elf-gcc
# See boot_minix.c on -fno-top-level-reorder.
CROSS_CFLAGS = -mregparmcall -fno-toplevel-reorder -fno-inline -mcmodel=tiny -mno-segment-relocation-stuff -ffreestanding -mtune=i8086
INCLUDES = -I $(TOPDIR)/include -I $(TOPDIR)/elks/include
CFLAGS = -Wall -Wno-strict-aliasing -Os $(CROSS_CFLAGS) $(INCLUDES)

AS = ia16-elf-as
# We do some assembly-time divisions in boot_sect_fat.h, so ask GNU as not to treat `/' as a comment character.
ASFLAGS = --divide

LD = ia16-elf-ld
LDFLAGS = -T $(TOPDIR)/elks/elks-raw.ld

.PHONY: all

TARGETS = mbr.bin

ifneq ($(CONFIG_ROMCODE), y)
TARGETS += minix.bin probe.bin fat.bin
endif

all: $(TARGETS)

minix.bin: boot_sect.o boot_minix.o
	$(LD) $(LDFLAGS) -M -o $(basename $@).tmp $^ > $(basename $@).map
	dd if=$(basename $@).tmp ibs=1k conv=sync of=$@
	$(RM) $(basename $@).tmp

probe.bin: boot_sect.o boot_probe.o
	$(LD) $(LDFLAGS) -M -o $@ $^ > $(basename $@).map

boot_sect.o: boot_sect.S $(TOPDIR)/include/autoconf.h
	$(CC) $(INCLUDES) -E -o $(basename $@).asm $<
	$(CC) $(INCLUDES) -E -UBOOT_FAT -o $(basename $@).asm $<
	$(AS) $(ASFLAGS) -o $@ $(basename $@).asm
	$(RM) $(basename $@).asm

boot_probe.o: boot_probe.S $(TOPDIR)/include/autoconf.h
	$(CC) $(INCLUDES) -E -o $(basename $@).asm $<
	$(AS) $(ASFLAGS) -o $@ $(basename $@).asm
	$(RM) $(basename $@).asm

boot_minix.o: boot_minix.c $(TOPDIR)/include/autoconf.h

fat.bin: boot_sect_fat.o $(TOPDIR)/include/autoconf.h
	$(LD) $(LDFLAGS) -M -o $@ $< > $(basename $@).map

mbr.bin: mbr.S
	$(CC) $(INCLUDES) -E -o $(basename $@).asm $<
	$(AS) $(ASFLAGS) -o $(basename $@).o $(basename $@).asm
	$(LD) $(LDFLAGS) -M -o $@ $(basename $@).o > $(basename $@).map
	xxd -i $@ > mbr_autogen.c
	$(RM) $(basename $@).asm

boot_sect_fat.o: boot_sect.S boot_sect_fat.h $(TOPDIR)/include/autoconf.h
	$(CC) $(INCLUDES) -E -DBOOT_FAT -o $(basename $@).asm $<
	$(AS) $(ASFLAGS) -o $@ $(basename $@).asm
	$(RM) $(basename $@).asm

clean:
	$(RM) *.o *.bin *.map mbr_autogen.c

# Boot blocks are not part of the target filesystem
# but embedded in the target disk image
# so empty rule for installation

install:
