# Makefile for the ELKS images

ifndef V
	V = @
endif

INFO = @echo

ifndef TOPDIR
$(error TOPDIR is not defined, ELKS not configured yet)
endif

# for CONFIG_IMG_EXTRA_IMAGES
include $(TOPDIR)/.config

# MBR boot sector
HD_MBR_BOOT = $(TOPDIR)/bootblocks/mbr.bin

BOOTBLOCKS_DIR	= $(TOPDIR)/bootblocks
FD_MINIX_BOOT	= $(BOOTBLOCKS_DIR)/minix.bin
FD_FAT_BOOT	= $(BOOTBLOCKS_DIR)/fat.bin
CONFIG_IMG_BOOT	= y

# Directory for final filesystem to be generated from
DESTDIR = $(TOPDIR)/target

TARGETS = image

ifdef CONFIG_IMG_EXTRA_IMAGES
TARGETS += images
endif

FD_SIZES 	= 360 720 1200 1440 2880
FDS		= $(addprefix fd,$(FD_SIZES))

FDS_FAT		= $(addsuffix -fat,$(FDS))
IMAGES_FAT	= $(addsuffix .img,$(FDS_FAT) hd32-fat hd32mbr-fat)

FDS_MINIX	= $(addsuffix -minix,$(FDS))
IMAGES_MINIX	= $(addsuffix .img,$(FDS_MINIX))

.PHONY: all clean

all: $(TARGETS)

.PHONY: image
image: fd1440-minix.img

.PHONY: copy
copy: copyminix

# Temporary unavailable
#.PHONY: copyminix copyfat copyrom
#copyminix copyfat copyrom:
#	$(INFO) 'MAKE	$@'
#	$(V)$(MAKE) -f Make.image $@ "CONFIG=$(TOPDIR)/.config" DESTDIR=$(DESTDIR)/$@

.PHONY: compress
compress:
	$(INFO)	'COMPRESS'
	$(V)cd $(TOPDIR)/target/bin && elks-compress * || true

.PHONY: images
images: images-minix images-hd images-fat

.PHONY: images-minix
images-minix: $(IMAGES_MINIX)

.PHONY: images-fat
images-fat: $(IMAGES_FAT)

.PHONY: images-hd
images-hd: hd32-minix hd32mbr-minix hd64-minix

.PHONY: $(FDS_MINIX)
fd360-minix: fd360-minix.img
fd720-minix: fd720-minix.img
fd1200-minix: fd1200-minix.img
fd1440-minix: fd1440-minix.img
fd2880-minix: fd2880-minix.img
$(IMAGES_MINIX): TYPE=MINIX

.PHONY: hd32-minix
hd32-minix: hd32-minix.img

hd32%.img: TARGET_BLKS=31752
hd32%.img: INODES=2048

.PHONY: hd64-minix
hd64-minix: hd64-minix.img

hd64%.img: TARGET_BLKS=65535
hd64%.img: INODES=32736

hd32-minix.img hd64-minix.img: CYLS=127
hd32-minix.img hd64-minix.img: TYPE=MINIX

.PHONY: $(FDS_FAT)
fd360-fat: fd360-fat.img
fd720-fat: fd720-fat.img
fd1200-fat: fd1200-fat.img
fd1440-fat: fd1440-fat.img
fd2880-fat: fd2880-fat.img
$(IMAGES_FAT): TYPE=FAT

fd360-%.img: MINIX_MKFSOPTS = -1 -n14

fd360-%.img: TARGET_BLKS = 360
fd360-%.img: BPB = -B9,2,40
fd360-%.img: MINIX_MKFSOPTS += -i128
fd360-%.img: CONFIG_IMG_BOOT = n

fd720-%.img: TARGET_BLKS = 720
fd720-%.img: BPB = -B9,2,80
fd720-%.img: MINIX_MKFSOPTS += -i192

fd1200-%.img: TARGET_BLKS = 1200
fd1200-%.img: BPB = -B15,2,80
fd1200-%.img: MINIX_MKFSOPTS += -i256

fd1232-%.img: TARGET_BLKS = 1232
fd1232-%.img: BPB = -B8,2,77
fd1232-%.img: MINIX_MKFSOPTS += -i256

fd1440-%.img: TARGET_BLKS = 1440
fd1440-%.img: BPB = -B18,2,80
fd1440-%.img: MINIX_MKFSOPTS += -i256

fd2880-%.img: TARGET_BLKS = 2880
fd2880-%.img: BPB = -B36,2,80
fd2880-%.img: MINIX_MKFSOPTS += -i720
# FAT12 2880k, use cluster size 2
fd2880-%.img: FAT_MKFSOPTS = -f $(TARGET_BLKS) -M 512 -d 2 -L 9 -r 14 -k -N 0 -c 2

hd%.img: SECT = 63
hd%.img: HEAD = 16
hd%.img: BPB = -B$(SECT),$(HEAD),$(CYLS)
hd%.img: MINIX_MKFSOPTS = -1 -n14 -i$(INODES) -s$(TARGET_BLKS)

# FAT16 HD, cluster size 2, autocalc num root directory sectors
hd%.img: FAT_MKFSOPTS=-s $(SECT) -h $(HEAD) -t $(CYLS) -M 512 -d 2 -k -N 0 -c 2

# minix:
# * MINICMKSOPTS
# * BPB
# * FD_MINIX_BOOT
# * TARGET_BLKS
%-minix.img: $(DESTDIR)/%-minix/.ts
	$(INFO) 'IMG-MINIX	$@'
	$(V)$(RM) $@
	$(V)mfs $(VERBOSE) $@ genfs $(MINIX_MKFSOPTS) -s$(TARGET_BLKS) $(dir $<)
	$(V)$(MAKE) -f Make.devices "MKDEV=mfs $@ mknod"
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

%-fat.img: $(DESTDIR)/%-fat/.ts
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

$(DESTDIR)/%/.ts: %.fs
	$(INFO) 'FS	$@	$(fd_size)'
	$(V)$(MAKE) -C $(TOPDIR) -f fs.mk \
		DESTDIR=$(abspath $(dir $@)) \
		CONFIG=$(abspath $<) \
		CONFIG_IMG_BOOT=$(CONFIG_IMG_BOOT) \

fd%.fs: $(TOPDIR)/.config
	$(INFO) 'FS-FD	$@'
	$(V)cp $< $@
	$(V)echo CONFIG_APPS_$(fd_size)K=y	>> $@
	$(V)echo CONFIG_IMG_FD$(fd_size)=y	>> $@
	$(V)echo CONFIG_IMG_$(TYPE)=y		>> $@
	$(V)sed -n -e '/CONFIG_TIME_/p'		>> $@ < $<

# FAT32 image
.PHONY: hd32-fat
hd32-fat: hd32-fat.img

hd32-fat.img: BLOCKS=31752
hd32-fat.img: CYLS=63
hd32-fat.img: TYPE=FAT

hd%.fs: $(TOPDIR)/.config
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
hd32mbr-minix: hd32mbr-minix.img

.PHONY: hd32mbr-fat
hd32mbr-fat: hd32mbr-fat.img

hd32mbr-minix.img: hd32-minix.img $(HD_MBR_BOOT)
hd32mbr-minix.img: SETBOOT_OPS += -Sm

hd32mbr-fat.img: hd32-fat.img $(HD_MBR_BOOT)
hd32mbr-fat.img: SETBOOT_OPS += -Sf

hd32mbr-minix.img hd32mbr-fat.img:
	$(INFO) 'IMG-MBR	$@'
	$(V)if ! dd if=/dev/zero of=$@ bs=512 count=63; then $(RM) $@; false; fi
	$(V)if ! cat $< >> $@; then $(RM) $@; false; fi
	$(V)if ! setboot $@ -P63,16,63 $(SETBOOT_OPS) $(HD_MBR_BOOT); then $(RM) $@; false; fi

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
	mkromfs -d $@ $(DESTDIR)

.PHONY: clean
clean: clean-destdir clean-images

.PHONY: clean-destdir
clean-destdir:
	$(INFO) 'CLEAN	$@'
	$(V)$(RM) -r $(DESTDIR)

.PHONY: clean-images
clean-images:
	$(INFO) 'CLEAN	$@'
	$(V)$(RM) $(IMAGES_FAT) $(IMAGES_MINIX) \
		fd1440.img \
		hd32-minix.img hd64-minix.img \
		hd32mbr-fat.img hd32mbr-minix.img \
