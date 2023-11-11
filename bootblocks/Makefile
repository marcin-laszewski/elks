ifndef V
	V = @
endif

INFO = @echo

# for CONFIG_ROMCODE
include $(TOPDIR)/.config

PREFIX = ia16-elf-

CC = $(PREFIX)gcc
# See boot_minix.c on -fno-top-level-reorder.
CROSS_CFLAGS = \
 -mregparmcall \
 -fno-toplevel-reorder \
 -fno-inline \
 -mcmodel=tiny \
 -mno-segment-relocation-stuff \
 -ffreestanding \
 -mtune=i8086 \

INCLUDES = \
 -I$(TOPDIR)/include \
 -I$(TOPDIR)/elks/include \

CFLAGS = -Wall -Wno-strict-aliasing -Os $(CROSS_CFLAGS) $(INCLUDES)

AS = $(PREFIX)as
# We do some assembly-time divisions in boot_sect_fat.h, so ask GNU as not to treat `/' as a comment character.
ASFLAGS = --divide

LD = $(PREFIX)ld
LDFLAGS = -T $(TOPDIR)/elks/elks-raw.ld

.PHONY: all

TARGETS = mbr.bin

ifneq ($(CONFIG_ROMCODE), y)
TARGETS += minix.bin probe.bin fat.bin
endif

all: $(TARGETS)

minix.bin: boot_sect.o boot_minix.o
	$(INFO) 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -M -o $(basename $@).tmp $^ > $(basename $@).map
	$(V)dd if=$(basename $@).tmp ibs=1k conv=sync of=$@
	$(V)$(RM) $(basename $@).tmp

probe.bin: boot_sect.o boot_probe.o
	$(INFO) 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -M -o $@ $^ > $(basename $@).map

boot_sect.o: boot_sect.S $(TOPDIR)/include/autoconf.h
	$(INFO) 'CC	$@'
	$(V)$(CC) $(INCLUDES) -E -o $(basename $@).asm $<
	$(V)$(CC) $(INCLUDES) -E -UBOOT_FAT -o $(basename $@).asm $<
	$(V)$(AS) $(ASFLAGS) -o $@ $(basename $@).asm
	$(V)$(RM) $(basename $@).asm

boot_probe.o: boot_probe.S $(TOPDIR)/include/autoconf.h
	$(INFO) 'CC	$@'
	$(V)$(CC) $(INCLUDES) -E -o $(basename $@).asm $<
	$(V)$(AS) $(ASFLAGS) -o $@ $(basename $@).asm
	$(V)$(RM) $(basename $@).asm

boot_minix.o: boot_minix.c $(TOPDIR)/include/autoconf.h
	$(INFO) 'CC	$@'
	$(V)$(CC) $(CFLAGS) -c -o $@ $<

fat.bin: boot_sect_fat.o $(TOPDIR)/include/autoconf.h
	$(LD) $(LDFLAGS) -M -o $@ $< > $(basename $@).map

mbr_autogen.c: mbr.bin
	$(INFO) 'GEN	$@'
	$(V)xxd -i $< > $@

mbr.bin: mbr.S
	$(INFO) 'LD	$@'
	$(V)$(CC) $(INCLUDES) -E -o $(basename $@).asm $<
	$(V)$(AS) $(ASFLAGS) -o $(basename $@).o $(basename $@).asm
	$(V)$(LD) $(LDFLAGS) -M -o $@ $(basename $@).o > $(basename $@).map
	$(V)$(RM) $(basename $@).asm

boot_sect_fat.o: boot_sect.S boot_sect_fat.h $(TOPDIR)/include/autoconf.h
	$(INFO) 'CC	$@'
	$(V)$(CC) $(INCLUDES) -E -DBOOT_FAT -o $(basename $@).asm $<
	$(V)$(AS) $(ASFLAGS) -o $@ $(basename $@).asm
	$(V)$(RM) $(basename $@).asm

clean:
	$(INFO) 'CLEAN'
	$(V)$(RM) *.o *.bin *.map mbr_autogen.c
