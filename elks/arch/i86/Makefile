#
#
#########################################################################
# Relative path to base directory.

BASEDIR 	= ../..

#########################################################################
# Define the variables required by the standard rules - see the standard
# rules file (below) for details of these variables.

USEBCC  	= Y

CLEANDEP	= 

CLEANME 	= $(BASEDIR)/include/arch/asm-offsets.h

DEPEND  	= 

DISTFILES	= defconfig

NOINDENT	= 

#########################################################################
# Include standard commands.

include $(BASEDIR)/Makefile-rules

#########################################################################
# ROM specific options.

ifeq ($(CONFIG_ROMCODE), y)

# Make sure that the a.out header & data segment values are prefixed with `0x'
ROMPOSTLINKFLAGS = --aout-seg 0x$(CONFIG_ROM_KERNEL_CODE:0x%=%) \
		   --data-seg 0x$(CONFIG_ROM_KERNEL_DATA:0x%=%)

endif

#########################################################################
# Objects to be compiled.

AARCHIVES = kernel/akernel.a lib/lib86.a mm/mm.a

ARCHIVES := \
 $(addprefix $(BASEDIR)/,$(ARCHIVES)) \
 kernel/akernel.a \
 lib/lib86.a \
 mm/mm.a \

ADRIVERS = drivers/char/chr_drv.a drivers/block/blk_drv.a drivers/net/net_drv.a

DRIVERS := $(DRIVERS) \
 drivers/char/chr_drv.a \
 drivers/block/blk_drv.a \
 drivers/net/net_drv.a

XINCLUDE = $(BASEDIR)/include/arch/asm-offsets.h

#########################################################################
# Path to GCC's compiler support routines (libgcc.a).

# Ask GCC for the correct path to the library given our compiler options

LIBGCC = "`$(CC) $(CFLAGS) -print-libgcc-file-name`"

#########################################################################
# Things to make.

boot/bootsect:   boot/bootsect.o

boot/setup:   boot/setup.o

boot/bootsect boot/setup: LDFLAGS += -M -T $(TOPDIR)/elks/elks-tiny.ld
boot/bootsect boot/setup: POSTLINK_OPS += --tiny

boot/netbootsect: LDFLAGS += -M $(ARCH_LD) -s

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $< > $(basename $@).map
	$(V)$(POSTLINK) $(POSTLINK_OPS) $@

boot/netbootsect.o:	boot/netbootsect.s

.PHONY: toolkit
toolkit:
	@echo 'MAKE	$@'
	$(V)${MAKE} -C tools all

$(BASEDIR)/include/arch/asm-offsets.h: asm-offsets.s asm-offsets.awk
	@echo 'CREAT-H	$@	$<'
	$(V)awk -f asm-offsets.awk $< > $@

asm-offsets.s: kernel/asm-offsets.c
	@echo 'CC-AS	$@	$<'
	$(V)$(CC) $(CFLAGS) -S -o asm-offsets.s $<

#########################################################################
# Image selection.

# Begin PC image build

boot/system boot/system.sym &: boot/system.elf
	@echo 'ELKS	$@'
	$(V)cp $< $@
	$(V)$(POSTLINK) --symfile $(basename $@).sym $@

boot/system.map: boot/system.elf
	@echo 'MAP-ELF	$@'
	$(V)$(NM) $< | sed -e '/&/d; /!/d' | sort > $@

boot/system.elf boot/system-full.map &: $(XINCLUDE) $(AARCHIVES) $(ADRIVERS) boot/crt0.o
	@echo 'LD-MAP	$@'
	$(V)$(LD) -o $@ $(CPU_LD) -M $(ARCH_LD) -T $(TOPDIR)/elks/elks-small.ld \
		boot/crt0.o $(BASEDIR)/init/main.o \
		'-(' $(ARCHIVES) $(DRIVERS) '-)' $(LIBGCC) \
	> $(basename $@)-full.map

.PHONY: Image

ifneq ($(CONFIG_ROMCODE), y)

Image:	boot/Image

boot/Image: toolkit boot/bootsect boot/setup boot/system
	@echo 'IMAGE	$@'
	$(V)tools/build $(filter-out toolkit,$^) > $@

.PHONY: nbImage
nbImage: boot/nbImage

boot/nbImage: boot/netbootsect boot/Image
	@echo 'IMAGE	$@'
	$(V)tools/mknbi-elks $^ $@

else

ifeq ($(CONFIG_ROM_BOOTABLE_BY_RESET), y)
    RVECT = -r $(CONFIG_ROM_RESET_ADDRESS)   
endif

Image:	boot/Image

boot/Image:	toolkit boot/setup boot/system
	@echo 'IMAGE	$@'
	$(V)tools/mkbootloader $(RVECT) -c $(CONFIG_ROM_SETUP_CODE) $(CONFIG_ROM_CHECKSUM_SIZE) $@ $(CONFIG_ROM_BASE) -a boot/setup $(CONFIG_ROM_SETUP_CODE) -s boot/system $(CONFIG_ROM_KERNEL_CODE) $(CONFIG_ROM_BIOS_MODULE) $(CONFIG_ROM_BIOS_MODULE_ADDR)
	$(V)$(CONFIG_ROM_SIMULATOR_PROGRAM)

# End PC image build

endif

#########################################################################
# Other commands.

.PHONY: boot-fd0
boot-fd0: boot/Image
	@echo 'IMAGE	$@'
	$(V)dd if=$< of=/dev/$(subst boot-,,$@) bs=8192

.PHONY: disk
disk:	boot-fd0

.PHONY: setup
setup:	toolkit boot/setup  
	@echo 'IMAGE	$@'
	$(V)tools/mkbootloader $(RVECT) -c $(CONFIG_ROM_SETUP_CODE) $(ROM_MAX_SETUP_SIZE) Image $(CONFIG_ROM_BASE) -a boot/setup $(CONFIG_ROM_SETUP_CODE) -s boot/system $(CONFIG_ROM_KERNEL_CODE) $(CONFIG_ROM_BIOS_MODULE) $(CONFIG_ROM_BIOS_MODULE_ADDR)
	$(V)$(CONFIG_ROM_SIMULATOR_PROGRAM)

#########################################################################
# library rules

# Build archives and add them to the list of things to link into kernel image

KLIBS = \
 kernel/akernel.a \
 lib/lib86.a mm/mm.a \
 drivers/char/chr_drv.a \
 drivers/block/blk_drv.a \
 drivers/net/net_drv.a \

.PHONY: $(KLIBS)
$(KLIBS):
	@echo 'MAKE	$@'
	$(V)$(MAKE) -C $(dir $@) $(notdir $@)

#########################################################################
# commands.

.PHONY: distdir
distdir:
	mkdir -p $(DISTDIR)/arch/i86
	cd $(DISTDIR)/arch/i86 && mkdir -p boot drivers kernel lib mm tools
	cd $(DISTDIR)/arch/i86/drivers && mkdir -p block char
	cp -pf defconfig Makefile $(DISTDIR)/arch/i86
	cp -pf boot/*.S boot/*.c $(DISTDIR)/arch/i86/boot
	cp -pf tools/Makefile tools/*.h $(DISTDIR)/arch/i86/tools
	cp -pf tools/mknbi-elks tools/*.c $(DISTDIR)/arch/i86/tools
	cp -pf tools/*.s tools/*.1 $(DISTDIR)/arch/i86/tools
	${MAKE} -C drivers/block distdir
	${MAKE} -C drivers/char distdir
	${MAKE} -C kernel distdir
	${MAKE} -C lib distdir
	${MAKE} -C mm distdir

#########################################################################
### Dependencies:
