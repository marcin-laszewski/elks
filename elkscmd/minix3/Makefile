BASEDIR=..

LOCALFLAGS=

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

INSTALL	?= install
INSTDIR	= $(DESTDIR)/bin

PRGS = file head sed sort tail tee cal diff find mail

#
# Rules
#

cal file: OBJS += $(TINYPRINTF)

find: LDFLAGS += -maout-heap=0x4000 -maout-stack=0x2000

# For ELKS, sort needs more data segment space than the kernel-given default.
# Use gcc-ia16's -maout-chmem= option so that the a.out header will ask the
# kernel for more non-static memory.
sort: LDFLAGS += -maout-heap=0xb000

.PHONY: all
all: $(PRGS)

%: %.c

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $^ $(OBJS) $(LDLIBS)

.PHONY: install
install: $(addprefix $(INSTDIR)/,$(PRGS))

$(INSTDIR)/%: %
	@echo 'INSTALL	$@'
	$(V)$(INSTALL) -d $(dir $@)
	$(V)$(INSTALL) $< $@

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) core $(PRGS)
