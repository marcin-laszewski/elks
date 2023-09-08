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
	@if ! test -e $@; \
	then \
		echo "You must configure ELKS first: $@" >&2; \
		false; \
	fi

.PHONY: $(SUBDIRS)
$(SUBDIRS): $(TOPDIR)/include/autoconf.h
	$(MAKE) -C $@ all

.PHONY: $(PROGS)
$(PROGS): $(TOPDIR)/include/autoconf.h
	$(MAKE) -C $@

.PHONY: install
install:
	$(MAKE) -f Make.install "CONFIG=$(TOPDIR)/.config"

.PHONY: clean
clean:
	for DIR in $(SUBDIRS); do $(MAKE) -C $$DIR clean || exit 1; done

###############################################################################
