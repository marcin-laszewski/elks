ELKS	= ../..
BASEDIR	= ../
include $(BASEDIR)/Make.defs
include $(BASEDIR)/Make.rules

# Install destination
DESTDIR		= $(TOPDIR)/target
ELKS_LIB86	= $(ELKS)/elks/arch/i86/lib/

NAME	= cgatext

OUT	= $(NAME)
CFLAGS	+= -I$(ELKS)/elks/include/arch
OBJS	+= main.o
LIBS	= $(ELKS_LIB86)/lib86.a

.PHONY: all
all: $(OUT)

$(OUT):	$(OBJS) $(LIBS)
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $^

.PHONY: distclean
distclean: clean
	@echo 'DISTCLEAN'
	$(V)$(RM) *~ $(OUT)

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(OBJS)

.PHONY: install
install: $(OUT)
	@echo 'INSTALL $(DESTDIR)/bin/$(notdir $<)'
	$(V)cp $(OUT) $(DESTDIR)/bin
