# Makefile for ktcp
BASEDIR=..
include $(BASEDIR)/Make.defs

SHELL		= /bin/sh

CFILES		= ktcp.c slip.c ip.c icmp.c tcp.c tcp_cb.c tcp_output.c \
		  timer.c tcpdev.c netconf.c vjhc.c deveth.c arp.c hexdump.c

LFILES		= $(addsuffix .lint,$(CFILES))

OBJS		= $(CFILES:.c=.o)

##############################################################################

.PHONY: all
all:	ktcp

ktcp:	$(OBJS)
	$(LD) $(LDFLAGS) -maout-heap=32768 -maout-stack=3072  -o ktcp $(OBJS) $(LDLIBS)

.PHONY: lint
lint: $(LFILES)

%.lint: %
	splint -weak -D__KERNEL__ $(LOCALFLAGS) $< 2>&1 > $@ || ( $(RM) $@ && false )

.PHONY: install
install: ktcp
	$(INSTALL) ktcp $(DESTDIR)/bin

.PHONY: clean
clean: 
	$(RM) *~ *.o ktcp core 

.PHONY: dep
dep:
	makedepend $(CFILES)

#######
# EOF #
#######
