# Makefile for the ELKS command set.
#
###############################################################################
#
# Include standard rules.

BASEDIR = .

include $(BASEDIR)/Make.defs

###############################################################################
#
# Subdirectories for clean / build / install

# All subdirectories to build & clean

# TODO: broken command compilations: byacc m4 xvi
# unused commands but working compilations: mtools nano prems
SUBDIRS =       \
	lib         \
	advent      \
	ash         \
	basic       \
	bc          \
	busyelks    \
	disk_utils  \
	elvis	    \
	file_utils  \
	inet        \
	ktcp        \
	levee       \
	minix1      \
	minix2      \
	minix3      \
	misc_utils  \
	nano-X      \
	sash        \
	screen      \
	cron        \
	sh_utils    \
	sys_utils   \
	tui         \
	test        \
	# EOL

PROGS	=
ifdef CONFIG_APP_CGATEXT
	PROGS += cgatext
endif
ifdef CONFIG_APP_ROMPRG
	PROGS += romprg
endif


###############################################################################
#
# Compile everything.

include $(BASEDIR)/Make.rules

.PHONY: all
all: $(SUBDIRS) $(PROGS)

$(TOPDIR)/include/autoconf.h:
	$(V)@if ! test -e $@; \
	then \
		echo "You must configure ELKS first: $@" >&2; \
		false; \
	fi

.PHONY: $(SUBDIRS)
$(SUBDIRS): $(TOPDIR)/include/autoconf.h
	@echo 'MAKE-DIR	$@'
	$(V)$(MAKE) -C $@ all

.PHONY: $(PROGS)
$(PROGS): $(TOPDIR)/include/autoconf.h
	@echo 'MAKE-PRG	$@'
	$(V)$(MAKE) -C $@

.PHONY: install
install:
	@echo 'INSTALL'
	$(V)$(MAKE) -f Make.install "CONFIG=$(TOPDIR)/.config"

CLEANS	= $(addprefix clean-,$(SUBDIRS) $(PROGS))

.PHONY: clean
clean: $(CLEANS) install-clean

.PHONY: $(CLEANS)
$(CLEANS):
	@echo 'CLEAN	$@'
	$(MAKE) -C $(subst clean-,,$@) clean V=$(V)

.PHONY: install-clean
install-clean:
	$(MAKE) -f Make.install clean
