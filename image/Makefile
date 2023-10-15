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
export DESTDIR

TARGETS = image

ifdef CONFIG_IMG_EXTRA_IMAGES
TARGETS += images
endif

.PHONY: all clean

all: $(TARGETS)

.PHONY: image
image:
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/.config"

.PHONY: copy
copy: copyminix

.PHONY: copyminix copyfat copyrom
copyminix copyfat copyrom:
	$(MAKE) -f Make.image $@ "CONFIG=$(TOPDIR)/.config"

.PHONY: compress
compress:
	cd $(TOPDIR)/target/bin && elks-compress *

.PHONY: images
images: images-minix images-hd images-fat

.PHONY: images-minix
images-minix: fd360-minix fd720-minix fd1200-minix fd1440-minix fd2880-minix

.PHONY: images-fat
images-fat: fd360-fat fd720-fat fd1200-fat fd1440-fat fd2880-fat hd32-fat hd32mbr-fat

.PHONY: images-hd
images-hd: hd32-minix hd32mbr-minix hd64-minix

fd_size	= $(subst fd,,$(firstword $(subst -, ,$@)))

.PHONY: fd360-minix
fd360-minix: fd360-minix.img

.PHONY: fd720-minix
fd720-minix: fd720-minix.img

.PHONY: fd1200-minix
fd1200-minix: fd1200-minix.img

.PHONY: fd1440-minix
fd1440-minix: fd1440-minix.img

.PHONY: fd2880-minix
fd2880-minix: fd2880-minix.img

fd%-minix.img: $(TOPDIR)/.config Make.image
	echo CONFIG_APPS_$(fd_size)K=y		> Config
	echo CONFIG_IMG_FD$(fd_size)=y		>> Config
	echo CONFIG_IMG_MINIX=y		>> Config
	echo CONFIG_IMG_DEV=y		>> Config
	echo CONFIG_IMG_BOOT=y		>> Config
	sed -n -e '/CONFIG_TIME_/p'	>> Config < $<
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/image/Config" NAME=$(subst .img,,$@)
	$(RM) Config

.PHONY: hd32-minix
hd32-minix: hd32-minix.img

hd32-minix.img: BLOCKS=31752

.PHONY: hd64-minix
hd64-minix: hd64-minix.img

hd64-minix.img: BLOCKS=65535

hd%-minix.img: $(TOPDIR)/.config Make.image
	echo CONFIG_APPS_2880K=y	> Config
	echo CONFIG_IMG_HD=y		>> Config
	echo CONFIG_IMG_BLOCKS=$(BLOCKS)	>> Config
	echo CONFIG_IMG_SECT=63		>> Config
	echo CONFIG_IMG_HEAD=16		>> Config
	echo CONFIG_IMG_CYL=127		>> Config
	echo CONFIG_IMG_MINIX=y		>> Config
	echo CONFIG_IMG_DEV=y		>> Config
	echo CONFIG_IMG_BOOT=y		>> Config
	sed -n -e '/CONFIG_TIME_/p'	>> Config < $<
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/image/Config" NAME=$(subst .img,,$@)
	$(RM) Config

.PHONY: fd360-fat
fd360-fat: fd360-fat.img

.PHONY: fd720-fat
fd720-fat: fd720-fat.img

.PHONY: fd1200-fat
fd1200-fat: fd1200-fat.img

.PHONY: fd1440-fat
fd1440-fat: fd1440-fat.img

# FAT16 image
.PHONY: fd2880-fat
fd2880-fat: fd2880-fat.img

fd%-fat.img: $(TOPDIR)/.config Make.image
	echo CONFIG_APPS_$(fd_size)K=y		> Config
	echo CONFIG_IMG_FD$(fd_size)=y		>> Config
	echo CONFIG_IMG_FAT=y		>> Config
	echo CONFIG_IMG_DEV=y		>> Config
	echo CONFIG_IMG_BOOT=y		>> Config
	sed -n -e '/CONFIG_TIME_/p'	>> Config < $<
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/image/Config" NAME=$(subst .img,,$@)
	$(RM) Config

# FAT32 image
.PHONY: fd2880-fat
hd32-fat: hd32mbr-fat.img

hd32-fat.img: $(TOPDIR)/.config Make.image
	echo CONFIG_APPS_2880K=y	> Config
	echo CONFIG_IMG_HD=y		>> Config
	echo CONFIG_IMG_BLOCKS=31752 >> Config
	echo CONFIG_IMG_SECT=63		>> Config
	echo CONFIG_IMG_HEAD=16		>> Config
	echo CONFIG_IMG_CYL=63		>> Config
	echo CONFIG_IMG_FAT=y		>> Config
	echo CONFIG_IMG_DEV=y		>> Config
	echo CONFIG_IMG_BOOT=y		>> Config
	sed -n -e '/CONFIG_TIME_/p'	>> Config < $<
	$(MAKE) -f Make.image "CONFIG=$(TOPDIR)/image/Config" NAME=hd32-fat
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
	dd if=/dev/zero bs=512 count=63 | cat - $< > $@
	setboot $@ -P63,16,63 $(SETBOOT_OPS) $(HD_MBR_BOOT)

# Clean target

.PHONY: clean
clean:
	-$(RM) -r $(DESTDIR)
	-$(RM) *.img *.bin
