BASEDIR=../..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

PRGS=netstat nslookup arp

LOCALFLAGS=-I$(ELKSCMD_DIR)

.PHONY: all
all: $(PRGS)

.PHONY: install
install: $(addprefix $(DESTDIR)/bin/,$(PRGS))
#install: $(DESTDIR)/etc/resolv.cfg

$(DESTDIR)/bin/%: %
	@echo 'INSTALL	$@'
	$(V)$(INSTALL) -d $(dir $@)
	$(V)$(INSTALL) $< $@

arp netstat: OBJS += $(TINYPRINTF)

# Disable
%: %.c

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) $< $(OBJS) -o $@ $(LDLIBS)

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) core $(PRGS)
