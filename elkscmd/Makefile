# Makefile for the ELKS command set.
#
###############################################################################

ifndef V
	V = @
endif

INFO = @echo

# Include standard rules.

BASEDIR = .

include $(BASEDIR)/Make.defs

ifndef TOPDIR
$(error TOPDIR is not defined, ELKS not configured yet)
endif

# include selected config file for installation instructions
include $(CONFIG)

#-----------------------------------------
###############################################################################
#
# Subdirectories for clean / build / install

# All subdirectories to build & clean

# unused commands but working compilations: nano levee
SUBDIRS =       \
	lib         \
	advent      \
	ash         \
	basic       \
	bc          \
	busyelks    \
	debug       \
	disk_utils  \
	fsck_dos    \
	elvis	    \
	file_utils  \
	inet        \
	ktcp        \
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

PROGS	=
ifdef CONFIG_APP_CGATEXT
	PROGS += cgatext
endif
ifdef CONFIG_APP_ROMPRG
	PROGS += romprg
endif
#------------------------------------

# Installation commands
INSTALL=install
LN=ln

# Application Package List
PACKAGE=$(TOPDIR)/elkscmd/Applications

# Install destination
DESTDIR=$(TOPDIR)/target
TAGS=

### Old-style installation
##INSTDIRS=
##export INSTALL LN DESTDIR

ifdef CONFIG_APP_TAGS
	TAGS += "$(CONFIG_APP_TAGS)"
endif

ifdef CONFIG_APP_ASH
	TAGS += ash
endif

ifdef CONFIG_APP_BUSYELKS
	TAGS += busyelks
endif

ifdef CONFIG_APP_DISK_UTILS
	TAGS += diskutil
	ifeq ($(CONFIG_APP_DISK_UTILS), y)
		TAGS += be-diskutil
	endif
endif

ifdef CONFIG_APP_FILE_UTILS
	TAGS += fileutil
	ifeq ($(CONFIG_APP_FILE_UTILS), y)
		TAGS += be-fileutil
	endif
endif

ifdef CONFIG_APP_ELVIS
	TAGS += elvis
endif

ifdef CONFIG_APP_KTCP
	TAGS += net
endif

ifdef CONFIG_APP_MINIX1
	TAGS += minix1
	ifeq ($(CONFIG_APP_MINIX1), y)
		TAGS += be-minix1
	endif
endif

ifdef CONFIG_APP_MINIX2
	TAGS += minix2
endif

ifdef CONFIG_APP_MINIX3
	TAGS += minix3
	ifeq ($(CONFIG_APP_MINIX3), y)
		TAGS += be-minix3
	endif
endif

ifdef CONFIG_APP_MISC_UTILS
	TAGS += miscutil
	ifeq ($(CONFIG_APP_MISC_UTILS), y)
		TAGS += be-miscutil
	endif
endif

ifdef CONFIG_APP_TUI
	TAGS += tui
endif

ifdef CONFIG_APP_NANOX
	TAGS += nanox
endif

ifdef CONFIG_APP_BASIC
	TAGS += basic
endif

ifdef CONFIG_APP_OTHER
	TAGS += other
endif

ifdef CONFIG_APP_SASH
	TAGS += sash
endif

ifdef CONFIG_APP_SCREEN
	TAGS += screen
endif

ifdef CONFIG_APP_CRON
	TAGS += cron
endif

ifdef CONFIG_APP_SH_UTILS
	TAGS += shutil
	ifeq ($(CONFIG_APP_SH_UTILS), y)
		TAGS += be-shutil
	endif
endif

ifdef CONFIG_APP_SYS_UTILS
	TAGS += sysutil
endif

ifdef CONFIG_APP_TEST
	TAGS += test
endif

#
# Install apps by image size
#
ifdef CONFIG_APPS_360K
	TAGS = boot 360k
endif

ifdef CONFIG_APPS_720K
	TAGS = boot 360k net 720k
endif

ifdef CONFIG_APPS_1200K
	TAGS = boot 360k net 720k 1200k
endif

ifdef CONFIG_APPS_1232K
	TAGS = boot 360k net 720k 1200k
endif

ifdef CONFIG_APPS_1440K
	TAGS = boot 360k net 720k 1200k 1440k
endif

ifdef CONFIG_APPS_2880K
    # below TAGS relies on :ash rule following :defsash rule in Applications
	#TAGS = :*|
	CONFIG_APP_MAN_PAGES=y
endif

#
# System startup
ifdef CONFIG_SYS_DEFSHELL_SASH
	TAGS += defsash
endif

ifdef CONFIG_APP_BUSYELKS
TARGET += busyelks-links
endif

ifdef CONFIG_APP_CGATEXT
	PKGS += cgatext
	INSTALL_TARGETS += $(DESTDIR)/usr/bin/cgatext
endif

ifdef CONFIG_APP_ROMPRG
	PKGS += romprg
	INSTALL_TARGETS += $(DESTDIR)/usr/bin/romprg
endif

ifdef CONFIG_APP_BUSYELKS
TARGET += busyelks-links
endif

MAN_SECTIONS = 1 2 4 5 7 8

ifdef CONFIG_APP_MAN_PAGES
INSTALL_TARGETS += $(addprefix $(DESTDIR)/lib/man,$(MAN_SECTIONS))
endif

INSTALL_TARGETS += $(addprefix install-,$(TAGS))

$(info TAGS	$(TAGS))
$(info PKGS	$(PKGS))
$(info DESTDIR	$(DESTDIR))
$(info PROGS	$(PROGS))
$(info INSTALL_TARGETS	$(INSTALL_TARGETS))

###############################################################################
#
# Compile everything.

include $(BASEDIR)/Make.rules

ifdef CONFIG_APPS_COMPRESS
	EXT = .cmr
else
	EXT =
endif

.PHONY: all
all: $(TAGS) $(PROGS)

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

#CLEANS	= $(addprefix clean-,$(SUBDIRS) $(PROGS))

#.PHONY: clean
#clean: $(CLEANS) install-clean

#.PHONY: $(CLEANS)
#$(CLEANS):
#	@echo 'CLEAN	$@'
#	$(MAKE) -C $(subst clean-,,$@) clean V=$(V)

#.PHONY: install-clean
#install-clean:
#	$(MAKE) -f Make.install clean


###############################################################################
#
# Install selected files.

.PHONY: install
install: $(INSTALL_TARGETS)

include elkscmd.mk
include apps.mk

apps.mk: Applications $(CONFIG) apps.awk
	if ! ./apps.awk -v 'srcdir=./' -v 'dstdir=$$(DESTDIR)/' -v "tags=$(TAGS)" < $< > $@; \
	then \
		$(RM) $@; \
		false; \
	fi

%.cmr: %
	$(INFO) 'COMPRESS	$@	$<'
	$(V)$(RM) $@
	$(V)if ! elks-compress -o $@ $< || ! test -f $@; \
	then \
		$(INFO) 'LN $< $@'; \
		ln -s -r $< $@; \
	fi

.PHONY: busyelks-links
busyelks-links:
	$(MAKE) -C busyelks links

$(info MAN	$(DESTDIR)/lib/man%)

$(DESTDIR)/lib/man%:
	@echo 'MAN	$(subst $(DESTDIR)/lib/,,$@)'
	$(V)cp -rp man/$(subst $(DESTDIR)/lib/,,$@) $(DESTDIR)/lib
	@echo 'MAN-Z	$(subst $(DESTDIR)/lib/,,$@)'
	$(V)find $@ -type f | xargs -r compress -b 12

.PHONY: clean
clean: $(addprefix clean-,$(SUBDIRS))
	$(RM) apps.mk

clean-%:
	@echo 'CLEAN	$@'
	$(V)$(MAKE) -C $(subst clean-,,$@) clean
