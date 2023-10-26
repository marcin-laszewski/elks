# Makefile for the ELKS images

ifndef TOPDIR
$(error TOPDIR is not defined, ELKS not configured yet)
endif

# for CONFIG_IMG_EXTRA_IMAGES
include $(TOPDIR)/.config

# MBR boot sector
HD_MBR_BOOT = $(TOPDIR)/bootblocks/mbr.bin

# Directory for final filesystem to be generated from
DESTDIR = $(TOPDIR)/target

TARGETS = image

ifdef CONFIG_IMG_EXTRA_IMAGES
TARGETS += images
endif

FD_SIZES 	= 360 720 1200 1440 2880
FDS		= $(addprefix fd,$(FD_SIZES))

FDS_FAT		= $(addsuffix -fat,$(FDS))
IMAGES_FAT	= $(addsuffix .img,$(FDS_FAT))

FDS_MINIX	= $(addsuffix -minix,$(FDS))
IMAGES_MINIX	= $(addsuffix .img,$(FDS_MINIX))

.PHONY: all clean

all: $(TARGETS)

.PHONY: image
image:
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/.config" DESTDIR=$(DESTDIR)/$@

.PHONY: copy
copy: copyminix

.PHONY: copyminix copyfat copyrom
copyminix copyfat copyrom:
	$(MAKE) -f Make.image $@ "CONFIG=$(TOPDIR)/.config" DESTDIR=$(DESTDIR)/$@

.PHONY: compress
compress:
	cd $(TOPDIR)/target/bin && elks-compress *

.PHONY: images
images: images-minix images-hd images-fat

.PHONY: images-minix
images-minix: $(IMAGES_MINIX)

.PHONY: images-fat
images-fat: $(IMAGES_FAT)

.PHONY: images-hd
images-hd: hd32-minix hd32mbr-minix hd64-minix

fd_size	= $(subst fd,,$(firstword $(subst -, ,$@)))

.PHONY: $(FDS_MINIX)
fd360-minix: fd360-minix.img
fd720-minix: fd720-minix.img
fd1200-minix: fd1200-minix.img
fd1440-minix: fd1440-minix.img
fd2880-minix: fd2880-minix.img
$(IMAGES_MINIX): TYPE=MINIX

.PHONY: hd32-minix
hd32-minix: hd32-minix.img

hd32-minix.img: BLOCKS=31752

.PHONY: hd64-minix
hd64-minix: hd64-minix.img

hd64-minix.img: BLOCKS=65535

hd32-minix.img hd64-minix.img: CYL=127
hd32-minix.img hd64-minix.img: TYPE=MINIX

.PHONY: $(FDS_FAT)
fd360-fat: fd360-fat.img
fd720-fat: fd720-fat.img
fd1200-fat: fd1200-fat.img
fd1440-fat: fd1440-fat.img
fd2880-fat: fd2880-fat.img
$(IMAGES_FAT): TYPE=FAT

fd%.img: $(TOPDIR)/.config Make.image
	cp $< Config
	echo CONFIG_APPS_$(fd_size)K=y		>> Config
	echo CONFIG_IMG_FD$(fd_size)=y		>> Config
	echo CONFIG_IMG_$(TYPE)=y		>> Config
	echo CONFIG_IMG_DEV=y		>> Config
	echo CONFIG_IMG_BOOT=y		>> Config
	sed -n -e '/CONFIG_TIME_/p'	>> Config < $<
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/image/Config" \
		NAME=$(subst .img,,$@) DESTDIR=$(DESTDIR)/$(basename $@)
	$(RM) Config

# FAT32 image
.PHONY: fd2880-fat
hd32-fat: hd32-fat.img

hd32-fat.img: BLOCKS=31752
hd32-fat.img: CYL=63
hd32-fat.img: TYPE=FAT

hd%.img: $(TOPDIR)/.config Make.image
	echo CONFIG_APPS_2880K=y	> Config
	echo CONFIG_IMG_HD=y		>> Config
	echo CONFIG_IMG_BLOCKS=$(BLOCKS)	>> Config
	echo CONFIG_IMG_SECT=63		>> Config
	echo CONFIG_IMG_HEAD=16		>> Config
	echo CONFIG_IMG_CYL=$(CYL)	>> Config
	echo CONFIG_IMG_$(TYPE)=y	>> Config
	echo CONFIG_IMG_DEV=y		>> Config
	echo CONFIG_IMG_BOOT=y		>> Config
	sed -n -e '/CONFIG_TIME_/p'	>> Config < $<
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/image/Config" \
		NAME=$(subst .img,,$@) DESTDIR=$(DESTDIR)/$(basename $@)
	$(RM) Config

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
	if ! dd if=/dev/zero of=$@ bs=512 count=63; then $(RM) $@; false; fi
	if ! cat $< >> $@; then $(RM) $@; false; fi
	if ! setboot $@ -P63,16,63 $(SETBOOT_OPS) $(HD_MBR_BOOT); then $(RM) $@; false; fi

# Clean target

.PHONY: clean
clean:
	-$(RM) -r $(DESTDIR)
	-$(RM) *.img *.bin
