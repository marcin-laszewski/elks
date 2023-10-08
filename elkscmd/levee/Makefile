# makefile for Levee

BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

LOCALFLAGS=-DSIZE=16000L

OBJS = blockio.o display.o editcor.o exec.o find.o \
    unixcall.o globals.o insert.o main.o misc.o \
    modify.o move.o ucsd.o undo.o wildargs.o

OUT = lev

DEPS = $(subst .o,.d,$(OBJS))

.PHONY: all
all: $(OUT)

$(OUT): $(OBJS)
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: install
install: $(DESTDIR)/bin/vi

$(DESTDIR)/bin/vi: $(OUT)
	@echo 'INSTALL	$@'
	$(V)$(INSTALL) -d $(dir $@)
	$(V)$(INSTALL) $< $@

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(OBJS) $(DEPS) $(OUT) dep.mk

# Dependencies
include dep.mk

dep.mk: $(DEPS)
	@echo 'DEP	$@'
	$(V)if ! cat $^ > $@; then $(RM) $@; false; fi

%.d: %.c
	@echo 'MKDEP	$@'
	$(V)$(CC) -o $@ -M $(CFLAGS) $<
