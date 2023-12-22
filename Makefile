ifndef V
	V = @
endif

INFO = @echo

ifndef TOPDIR
$(error TOPDIR is not defined; did you mean to run './build.sh' instead?)
endif

include $(TOPDIR)/Make.defs

ARCH86	= elks/arch/i86/
LIB86	= $(ARCH86)/lib/lib86.a
ELKSIMG	= $(ARCH86)/boot/Image

# for CONFIG_IMG_EXTRA_IMAGES
-include .config

# MBR boot sector
FD_FAT_BOOT	= bootblocks/fat.bin
FD_MINIX_BOOT	= bootblocks/minix.bin
HD_MBR_BOOT	= bootblocks/mbr.bin

BOOTS = \
 $(HD_MBR_BOOT) \
 $(FD_MINIX_BOOT) \
 $(FD_FAT_BOOT) \

CONFIG_IMG_BOOT	= y

# target: Directory for final filesystem to be generated from

IMAGE_DEFAULT = image/fd1440-minix.img

IMAGES = $(IMAGE_DEFAULT)

FD_SIZES 	= 360 720 1200 1440 2880
FDS		= $(addprefix image/fd,$(FD_SIZES))

FDS_FAT		= $(addsuffix -fat,$(FDS))
IMAGES_FAT	= $(addsuffix .img,$(FDS_FAT) hd32-fat hd32mbr-fat)

FDS_MINIX	= $(addsuffix -minix,$(FDS))
IMAGES_MINIX	= $(addsuffix .img,$(FDS_MINIX))

ifdef CONFIG_IMG_EXTRA_IMAGES
	IMAGES += $(filter-out %/fd360-fat.img,$(filter-out $(IMAGE_DEFAULT),$(IMAGES_FAT) $(IMAGES_MINIX)))
endif

.PHONY: all clean libc kconfig defconfig config menuconfig

all: images

.PHONY: images
images: $(IMAGES)
ifneq ($(shell uname), Darwin)
	$(MAKE) -C elksemu PREFIX='$(TOPDIR)/cross' elksemu
endif

$(IMAGES): .config include/autoconf.h kernel libc-install

#.PHONY: copy
#copy: copyminix
#
# Temporary unavailable
#.PHONY: copyminix copyfat copyrom
#copyminix copyfat copyrom:
#	$(INFO) 'MAKE	$@'
#	$(V)$(MAKE) -f Make.image $@ "CONFIG=$(TOPDIR)/.config" DESTDIR=target/$@
#
#.PHONY: compress
#compress:
#	$(INFO)	'COMPRESS'
#	$(V)cd $(TOPDIR)/target/bin && elks-compress * || true

.PHONY: images-all
images-all: \
 images-minix \
 images-hd \
 images-fat \

.PHONY: images-minix
images-minix: $(IMAGES_MINIX)

.PHONY: images-fat
images-fat: $(IMAGES_FAT)

.PHONY: images-hd
images-hd: hd32-minix hd32mbr-minix hd64-minix

.PHONY: $(FDS_MINIX)
fd360-minix: image/fd360-minix.img
fd720-minix: image/fd720-minix.img
fd1200-minix: image/fd1200-minix.img
fd1440-minix: image/fd1440-minix.img
fd2880-minix: image/fd2880-minix.img
$(IMAGES_MINIX): TYPE=MINIX

.PHONY: hd32-minix
hd32-minix: image/hd32-minix.img

image/hd32%.img: TARGET_BLKS=31752
image/hd32%.img: INODES=2048

.PHONY: hd64-minix
hd64-minix: image/hd64-minix.img

image/hd64%.img: TARGET_BLKS=65535
image/hd64%.img: INODES=32736

image/hd%-minix.img: CYLS=127
image/hd%-minix.img: TYPE=MINIX

.PHONY: $(FDS_FAT)
fd360-fat: image/fd360-fat.img
fd720-fat: image/fd720-fat.img
fd1200-fat: image/fd1200-fat.img
fd1440-fat: image/fd1440-fat.img
fd2880-fat: image/fd2880-fat.img
$(IMAGES_FAT): TYPE=FAT

image/fd360-%.img: MINIX_MKFSOPTS = -1 -n14

image/fd360-%.img: TARGET_BLKS = 360
image/fd360-%.img: BPB = -B9,2,40
image/fd360-%.img: MINIX_MKFSOPTS += -i198
image/fd360-%.img: CONFIG_IMG_BOOT = n

image/fd720-%.img: TARGET_BLKS = 720
image/fd720-%.img: BPB = -B9,2,80
image/fd720-%.img: MINIX_MKFSOPTS += -i192

image/fd1200-%.img: TARGET_BLKS = 1200
image/fd1200-%.img: BPB = -B15,2,80
image/fd1200-%.img: MINIX_MKFSOPTS += -i256

image/fd1232-%.img: TARGET_BLKS = 1232
image/fd1232-%.img: BPB = -B8,2,77
image/fd1232-%.img: MINIX_MKFSOPTS += -i256

image/fd1440-%.img: TARGET_BLKS = 1440
image/fd1440-%.img: BPB = -B18,2,80
image/fd1440-%.img: MINIX_MKFSOPTS += -i256

image/fd2880-%.img: TARGET_BLKS = 2880
image/fd2880-%.img: BPB = -B36,2,80
image/fd2880-%.img: MINIX_MKFSOPTS += -i720
# FAT12 2880k, use cluster size 2
image/fd2880-%.img: FAT_MKFSOPTS = -f $(TARGET_BLKS) -M 512 -d 2 -L 9 -r 14 -k -N 0 -c 2

image/hd%.img: SECT = 63
image/hd%.img: HEAD = 16
image/hd%.img: BPB = -B$(SECT),$(HEAD),$(CYLS)
image/hd%.img: MINIX_MKFSOPTS = -1 -n14 -i$(INODES) -s$(TARGET_BLKS)

# FAT16 HD, cluster size 2, autocalc num root directory sectors
image/hd%.img: FAT_MKFSOPTS=-s $(SECT) -h $(HEAD) -t $(CYLS) -M 512 -d 2 -k -N 0 -c 2

# minix:
# * MINICMKSOPTS
# * BPB
# * FD_MINIX_BOOT
# * TARGET_BLKS
image/%-minix.img: target/%-minix/.ts $(FD_MINIX_BOOT)
	$(INFO) 'IMG-MINIX	$@'
	$(V)$(RM) $@
	$(V)mfs $(VERBOSE) $@ genfs $(MINIX_MKFSOPTS) -s$(TARGET_BLKS) $(dir $<)
	$(V)$(MAKE) -f image/Make.devices "MKDEV=mfs $@ mknod"
	$(V)setboot $@ $(BPB) $(FD_MINIX_BOOT)
	$(V)mfsck -fv $@
	$(V)mfs $@ stat

# fat:
# * TARGET_BLKS
# * FAT_MKFSOPTS
# * CPFS_OPTS
# * FAT_COPYOPTS
# * BPB
# * FD_FAT_BOOT

SETBOOT_OPS =

%/fd1232-fat.img: SETBOOT_OPS = -K

image/%-fat.img: target/%-fat/.ts $(FD_FAT_BOOT)
	$(INFO) 'IMG-FAT	$@'
	$(RM) $@
	dd if=/dev/zero of=$@ bs=1024 count=$(TARGET_BLKS)
	mformat -V
	mformat -i $@ $(FAT_MKFSOPTS)
	@# Linux has to be the first file for the boot sector loader
	$(RM) linux; touch linux
	mcopy -i $@ $(CPFS_OPTS) linux ::/linux
	$(RM) linux
	mmd -i $@ ::/dev
	for f in $$(cd $(dir $<) && find * -name '*'); do \
		if [ -d $(dir $<)/$$f -a "$$f" != "dev" ]; then echo mmd -D o -i $@ ::$$f || exit 1; fi; \
		if [ -f $(dir $<)/$$f ]; then echo mcopy -i $@ $(FAT_COPYOPTS) $(dir $<)/$$f ::$$f || exit 1; fi; \
	done
	@# Protect contiguous /linux by marking as RO, System and Hidden
	mattrib -i $@ +r +s +h ::/linux
	@# Read boot sector, skip FAT BPB, set ELKS PB sectors/heads and write boot
	setboot $@ $(SETBOOT_OPS) -F $(BPB) $(FD_FAT_BOOT)

fd_size = $(subst fd,,$(firstword $(subst -, ,$(lastword $(subst /, ,$(dir $@))))))

target/%/.ts: %.fs
	$(INFO) 'FS	$@	$(fd_size)'
	$(V)$(MAKE) -C $(TOPDIR) -f fs.mk \
		DESTDIR=$(abspath $(dir $@)) \
		CONFIG=$(abspath $<) \
		CONFIG_IMG_BOOT=$(CONFIG_IMG_BOOT) \

fd%.fs: .config
	$(INFO) 'FS-FD	$@'
	$(V)cp $< $@
	$(V)echo CONFIG_APPS_$(fd_size)K=y	>> $@
	$(V)echo CONFIG_IMG_FD$(fd_size)=y	>> $@
	$(V)echo CONFIG_IMG_$(TYPE)=y		>> $@
	$(V)sed -n -e '/CONFIG_TIME_/p'		>> $@ < $<

# FAT32 image
.PHONY: hd32-fat
hd32-fat: image/hd32-fat.img

image/hd32-fat.img: BLOCKS=31752
image/hd32-fat.img: CYLS=63
image/hd32-fat.img: TYPE=FAT

hd%.fs: .config
	$(INFO) 'FS-HD	$@'
	$(V)cp $< $@
	$(V)echo CONFIG_APPS_2880K=y		>  $@
	$(V)echo CONFIG_IMG_HD=y		>> $@
	$(V)echo CONFIG_IMG_HEAD=16		>> $@
	$(V)echo CONFIG_IMG_$(TYPE)=y		>> $@
	$(V)echo CONFIG_IMG_DEV=y		>> $@
	$(V)sed -n -e '/CONFIG_TIME_/p'		>> $@ < $<

# MBR images
.PHONY: hd32mbr-minix
hd32mbr-minix: image/hd32mbr-minix.img

.PHONY: hd32mbr-fat
hd32mbr-fat: image/hd32mbr-fat.img

image/hd32mbr-minix.img: image/hd32-minix.img $(HD_MBR_BOOT)
image/hd32mbr-minix.img: SETBOOT_OPS += -Sm

image/hd32mbr-fat.img: image/hd32-fat.img $(HD_MBR_BOOT)
image/hd32mbr-fat.img: SETBOOT_OPS += -Sf

image/hd32mbr-minix.img \
image/hd32mbr-fat.img \
: $(HD_MBR_BOOT)
	$(INFO) 'IMG-MBR	$@'
	$(V)if ! dd if=/dev/zero of=$@ bs=512 count=63; then $(RM) $@; false; fi
	$(V)if ! cat $< >> $@; then $(RM) $@; false; fi
	$(V)if ! setboot $@ -P63,16,63 $(SETBOOT_OPS) $<; then $(RM) $@; false; fi

#--- rawfs
.PHONY: raw
raw: $(ELKS_DIR)/arch/i86/boot/Image
	dd if=/dev/zero of=$(TARGET_FILE) bs=1024 count=$(TARGET_BLKS)
	dd if=$(ELKS_DIR)/arch/i86/boot/Image of=$(TARGET_FILE) conv=notrunc

#--- romfs
.PHONY: copyrom
copyrom: romfs

.PHONY: romfs
romfs: romfs.device

romfs.device:
	$(RM) $@
	$(MAKE) -f Make.devices "MKDEV=echo >> romfs.devices"
	mkromfs -d $@ target

.PHONY: image-clean
image-clean: image-clean-destdir image-clean-images

.PHONY: image-clean-destdir
image-clean-destdir:
	$(INFO) 'IMG-CLEAN	$@'
	$(V)$(RM) -r target

.PHONY: image-clean-images
image-clean-images:
	$(INFO) 'IMG-CLEAN	$@'
	$(V)$(RM) \
		$(IMAGES_FAT) \
		$(IMAGES_MINIX) \
		image/fd1440.img \
		image/hd32-minix.img \
		image/hd64-minix.img \
		image/hd32mbr-fat.img \
		image/hd32mbr-minix.img \

.PHONY: kernel
kernel: $(ELKSIMG)
$(ELKSIMG): .config include/autoconf.h
	@echo 'ELKSIMG	$@'
	$(V)$(MAKE) -C elks all

kclean:
	$(MAKE) -C elks kclean

.PHONY: boot
boot: $(BOOTS)

$(BOOTS): .config include/autoconf.h
	@echo 'BOOT	$@'
	$(V)$(MAKE) -C $(dir $@) $(notdir $@)

.PHONY: boot-clean
boot-clean:
	@echo 'BOOT-CLEAN'
	$(V)$(MAKE) -C bootblocks clean

.PHONY: elkscmd
elkscmd: .config include/autoconf.h libc-install $(LIB86)
	$(MAKE) -C elkscmd all

.PHONY: elkscmd-clean elkscmd-install
elkscmd-clean elkscmd-install:
	$(MAKE) -C elkscmd $(subst elkscmd-,,$@)

.PHONY: tools-elf2elks
tools-elf2elks:
	$(MAKE) -C elks/tools/elf2elks

.PHONY: $(LIB86)
$(LIB86):
	$(MAKE) -C $(dir $@) $(notdir $@)

clean: libc-clean libc-uninstall image-clean boot-clean
	$(MAKE) -C elks clean
	$(MAKE) -C elkscmd clean
ifneq ($(shell uname), Darwin)
	$(MAKE) -C elksemu clean
endif
	@echo
	@if [ ! -f .config ]; then \
	    echo ' * This system is not configured. You need to run' ;\
	    echo ' * `make config` or `make menuconfig` to configure it.' ;\
	    echo ;\
	fi

.PHONY: libc-reinstall
libc-reinstall: libc-uninstall libc-install

.PHONY: libc-clean
libc-clean:
	$(MAKE) -C libc clean

.PHONY: libc-install libc-uninstall

libc-install: libc

libc-install libc-uninstall:
	$(MAKE) -C libc $(subst libc-,,$@)

.PHONY: libc
libc:
	$(MAKE) -C libc all

elks/arch/i86/drivers/char/KeyMaps/config.in:
	$(MAKE) -C $(dir $@) $(notdir $@)

kconfig:
	$(MAKE) -C config all

defconfig:
	$(RM) .config
	@yes '' | ${MAKE} config

include/autoconf.h: .config
	@yes '' | config/Configure -D config.in

config: elks/arch/i86/drivers/char/KeyMaps/config.in kconfig
	config/Configure config.in

menuconfig: elks/arch/i86/drivers/char/KeyMaps/config.in kconfig
	config/Menuconfig config.in

.config:
	@echo 'No "$@". Run "make config" or "make menuconfig".'
	@false
