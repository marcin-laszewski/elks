BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

PRGS = ramdisk mkfs mkfat fsck partype fdisk df

SPRGS=mkfs

.PHONY: all
all: $(PRGS)

.PHONY: install_sibo
install_sibo: all
	$(INSTALL) $(SPRGS) $(DESTDIR)/bin

.PHONY: install
install: $(PRGS)
	$(V)$(INSTALL) $^ $(DESTDIR)/bin

fsck: LDFLAGS += -maout-heap=0xffff

df mkfs mkfat: OBJS += $(TINYPRINTF)

%: %.c
	@echo 'CC-LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $< $(OBJS) $(LDLIBS)

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(FORMATMOD) core $(PRGS)
