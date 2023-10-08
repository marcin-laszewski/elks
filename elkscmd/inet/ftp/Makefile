# Makefile for ftp client and server

BASEDIR=../..

include $(BASEDIR)/Make.defs

INSTALL_DIR = $(DESTDIR)/bin

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

BINS = ftp ftpd
INSTALLS = $(addprefix $(INSTALL_DIR)/,$(BINS))

all:	$(BINS)

ftp:	LDFLAGS += -maout-stack=6144
ftpd:	LDFLAGS += -maout-stack=4096

%: %.c
	@echo 'CC-LD	$@'
	$(V)$(LD) $(LDFLAGS) -maout-heap=4096 -o $@ $< $(LDLIBS)

.PHONY: install
install: $(INSTALLS)

$(INSTALL_DIR)/%: %
	@echo 'INSTALL	$@'
	$(V)mkdir -p $(dir $@)
	$(V)$(INSTALL) $< $(dir $@)

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(BINS)

