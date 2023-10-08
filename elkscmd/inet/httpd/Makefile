BASEDIR=../..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

PRG=httpd
OBJS	= httpd.o

LOCALFLAGS=-I$(ELKSCMD_DIR)
LDFLAGS += -maout-heap=1024 -maout-stack=1024

.PHONY: all
all: $(PRG)

$(PRG): $(OBJS) $(TINYPRINTF)
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $(PRG) $^ $(LDLIBS)

.PHONY: install
install: \
 $(DESTDIR)/bin/$(PRG) \
 $(DESTDIR)/var/www/index.html

$(DESTDIR)/bin/$(PRG): $(PRG)
$(DESTDIR)/var/www/index.html: sample_index.html

$(DESTDIR)/bin/$(PRG) \
$(DESTDIR)/var/www/index.html:
	@echo 'INSTALL	$@'
	$(V)$(INSTALL) -d $(dir $@)
	$(V)$(INSTALL) $< $@

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(OBJS) $(PRG)
