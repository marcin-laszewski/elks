BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

LOCALFLAGS=-D_POSIX_SOURCE

PRGS = banner decomp16 fgrep grep proto sum uniq wc cksum cut du

INSTALL_PRGS = $(addprefix $(DESTDIR)/bin/,$(PRGS))

.PHONY: all
all: $(PRGS)

cksum du sum: OBJS += $(TINYPRINTF)

%: %.c

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $^ $(OBJS) $(LDLIBS)

.PHONY: install
install: $(INSTALL_PRGS)

$(DESTDIR)/bin/%: %
	@echo 'INSTALL	$@'
	$(V)$(INSTALL) -d $(dir $@)
	$(V)$(INSTALL) $< $@

.PHONY: clean
clean:
	$(RM) $(PRGS) *.o
