
ifndef TOPDIR
$(error TOPDIR is not defined; did you mean to run './build.sh' instead?)
endif

include $(TOPDIR)/Make.defs

.PHONY: all clean libc kconfig defconfig config menuconfig

all: .config include/autoconf.h libc-install
	$(MAKE) -C elks all
	$(MAKE) -C bootblocks all
	$(MAKE) -C elkscmd all
	$(MAKE) -C image all
ifneq ($(shell uname), Darwin)
	$(MAKE) -C elksemu PREFIX='$(TOPDIR)/cross' elksemu
endif

kclean:
	$(MAKE) -C elks kclean

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
