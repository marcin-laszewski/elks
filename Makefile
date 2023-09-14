
ifndef TOPDIR
$(error TOPDIR is not defined; did you mean to run './build.sh' instead?)
endif

include $(TOPDIR)/Make.defs

LIB86	= elks/arch/i86/lib/lib86.a

.PHONY: all clean libc kconfig defconfig config menuconfig

all: image
ifneq ($(shell uname), Darwin)
	$(MAKE) -C elksemu PREFIX='$(TOPDIR)/cross' elksemu
endif

.PHONY: image
image: .config include/autoconf.h kernel boot elkscmd
	$(MAKE) -C image all

.PHONY: kernel
kernel: .config include/autoconf.h
	$(MAKE) -C elks all

kclean:
	$(MAKE) -C elks kclean

.PHONY: boot
boot: .config include/autoconf.h
	$(MAKE) -C bootblocks all

.PHONY: elkscmd
elkscmd: .config include/autoconf.h libc-install tools-elf2elks \
 $(LIB86) \
 bootblocks/mbr_autogen.c
	$(MAKE) -C elkscmd all

.PHONY: bootblocks/mbr_autogen.c
bootblocks/mbr_autogen.c:
	$(MAKE) -C $(dir $@) $(notdir $@)

.PHONY: tools-elf2elks
tools-elf2elks:
	$(MAKE) -C elks/tools/elf2elks CC=cc CFLAGS= AR=ar

.PHONY: $(LIB86)
$(LIB86):
	$(MAKE) -C $(dir $@) $(notdir $@)

clean: libc-clean libc-uninstall
	$(MAKE) -C elks clean
	$(MAKE) -C bootblocks clean
	$(MAKE) -C elkscmd clean
	$(MAKE) -C image clean
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
	$(MAKE) -C libc DESTDIR='$(TOPDIR)/cross' $(subst libc-,,$@)

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
