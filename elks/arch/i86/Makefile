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
 $(addprefix ../../,$(ARCHIVES)) \
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

.PHONY: toolkit

boot/bootsect:   boot/bootsect.o

boot/setup:   boot/setup.o

boot/bootsect boot/setup:
	$(LD) $(LDFLAGS) -M -T $(TOPDIR)/elks/elks-tiny.ld -o $@ $< > $(basename $@).map
	$(POSTLINK) --tiny $@

boot/netbootsect:	boot/netbootsect.o
	$(LD) $(LDFLAGS) -M $(ARCH_LD) -s -o $@ $< > $(basename $@).map
	$(POSTLINK) $@

boot/netbootsect.o:	boot/netbootsect.s

toolkit:
	${MAKE} -C tools all

$(BASEDIR)/include/arch/asm-offsets.h: kernel/asm-offsets.c asm-offsets.awk
	$(CC) $(CFLAGS) -S -o asm-offsets.s $<
	awk -f asm-offsets.awk asm-offsets.s > $@
	$(RM) asm-offsets.s

#########################################################################
# Image selection.

# Begin PC image build

boot/system.sym: boot/system

boot/system: boot/system.elf
		cp $< $@
		$(POSTLINK) --symfile $(basename $@).sym $@

boot/system.map: boot/system.elf
		$(NM) $< | sed -e '/&/d; /!/d' | sort > $@

boot/system-full.map: boot/system.elf

boot/system.elf: $(XINCLUDE) $(AARCHIVES) $(ADRIVERS) boot/crt0.o
	$(LD) -o $@ $(CPU_LD) -M $(ARCH_LD) -T $(TOPDIR)/elks/elks-small.ld \
		boot/crt0.o ../../init/main.o \
		'-(' $(ARCHIVES) $(DRIVERS) '-)' $(LIBGCC) \
	> $(basename $@)-full.map

ifneq ($(CONFIG_ROMCODE), y)

Image:	toolkit boot/bootsect boot/setup boot/system
	tools/build boot/bootsect boot/setup boot/system > boot/Image

nbImage:	Image boot/netbootsect
	tools/mknbi-elks boot/netbootsect boot/Image boot/nbImage

else

ifeq ($(CONFIG_ROM_BOOTABLE_BY_RESET), y)
    RVECT = -r $(CONFIG_ROM_RESET_ADDRESS)   
endif

Image:	toolkit boot/setup boot/system  
	tools/mkbootloader $(RVECT) -c $(CONFIG_ROM_SETUP_CODE) $(CONFIG_ROM_CHECKSUM_SIZE) boot/Image $(CONFIG_ROM_BASE) -a boot/setup $(CONFIG_ROM_SETUP_CODE) -s boot/system $(CONFIG_ROM_KERNEL_CODE) $(CONFIG_ROM_BIOS_MODULE) $(CONFIG_ROM_BIOS_MODULE_ADDR)
	$(CONFIG_ROM_SIMULATOR_PROGRAM)

# End PC image build

endif

#########################################################################
# Other commands.

boot:	Image
	dd if=boot/Image of=/dev/fd0 bs=8192

disk:	boot

setup:	toolkit boot/setup  
	tools/mkbootloader $(RVECT) -c $(CONFIG_ROM_SETUP_CODE) $(ROM_MAX_SETUP_SIZE) Image $(CONFIG_ROM_BASE) -a boot/setup $(CONFIG_ROM_SETUP_CODE) -s boot/system $(CONFIG_ROM_KERNEL_CODE) $(CONFIG_ROM_BIOS_MODULE) $(CONFIG_ROM_BIOS_MODULE_ADDR)
	$(CONFIG_ROM_SIMULATOR_PROGRAM)

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
	$(MAKE) -C $(dir $@) $(notdir $@)

#########################################################################
# commands.

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
