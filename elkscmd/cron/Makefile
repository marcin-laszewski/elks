##################################################################################

# Makefile for cron

BASEDIR=..

include $(BASEDIR)/Make.defs

LOCALFLAGS = -Wno-implicit-int -Wno-return-type $(OPTIONS)

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

INSTALL_DIR	= $(DESTDIR)/bin

common=readcrontab.o lib.o

CRON_OUT	= cron
CRON_OBJS	= cron.o runjob.o $(common)

CRONTAB_OUT	= crontab
CRONTAB_OBJS	= crontab.o $(common)

PROGS		= $(CRON_OUT) $(CRONTAB_OUT)

.PHONY: all
all: $(PROGS)

$(CRON_OUT): $(CRON_OBJS)
$(CRONTAB_OUT): $(CRONTAB_OBJS)

$(PROGS):
	@echo 'CC-LD	$@'
	$(V)$(CC) $(CFLAGS) -maout-heap=14336 -o $@ $^

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(PROGS) $(CRON_OBJS) $(CRONTAB_OBJS)

.PHONY: install
install: $(addprefix $(INSTALL_DIR)/,$(PROGS))

$(INSTALL_DIR)/%: %
	@echo 'INSTALL	$@'
	$(V)mkdir -p $(dir $@)
	$(V)$(INSTALL) $< $@

cron.o: cron.c cron.h config.h
crontab.o: crontab.c cron.h config.h
readcrontab.o: readcrontab.c cron.h config.h
lib.o: lib.c cron.h config.h
