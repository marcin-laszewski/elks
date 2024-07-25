BASEDIR=..

LOCALFLAGS=-D_POSIX_SOURCE

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

INSTALL	?= install
INSTDIR	?= $(DESTDIR)/bin

# TODO: lpd man mt install	# Do not compile.
# compiling but unused: pwdauth
PRGS=env lp lpd remsync synctree tget

env lp: OBJS += $(TINYPRINTF)

.PHONY: all
all: $(PRGS)

%: %.c

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $< $(OBJS) $(LDLIBS)

install: $(PRGS)
	$(INSTALL) $(PRGS) $(DESTDIR)/bin

.PHONY: install
install: $(addprefix $(INSTDIR)/,$(PRGS))

$(INSTDIR)/%: %
	@echo 'INSTALL	$@'
	$(V)mkdir -p $(dir $@)
	$(V)$(INSTALL) $< $@

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) core $(PRGS)
