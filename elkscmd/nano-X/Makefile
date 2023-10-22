# Microwindows and Nano-X Makefile for ELKS
#
# originally from v0.86 10/29/99 g haerr
#

BASEDIR = ..
include $(BASEDIR)/Make.defs

LOCALFLAGS = -DELKS=1 -DUNIX=1 -DDEBUG=1 -I.
MATHLIB =

# nano-X demo programs
NANOXDEMOS = bin/nxlandmine
NANOXDEMOS += bin/nxworld
NANOXDEMOS += bin/nxclock
NANOXDEMOS += bin/nxterm			# enable pseudo ttys in ELKS
NANOXDEMOS += bin/nxtest
NANOXDEMOS += bin/nxtetris
NANOXDEMOS += bin/nxdemo
#NANOXDEMOS += bin/nxdemo2
#NANOXDEMOS += bin/nxvgatest		# low-level vga routines test

# mouse and kbd drivers
# SLOW_CPU discards unprocessed mouse input for slow systems
LOCALFLAGS += -DSLOW_CPU=1
ifeq ($(CONFIG_ARCH_PC98), y)
#DRIVERS += drivers/mou_null.o
DRIVERS += drivers/mou_pc98.o
else
DRIVERS += drivers/mou_ser.o
endif
DRIVERS += drivers/kbd_tty.o

# portable C VGA driver
ifeq ($(CONFIG_ARCH_PC98), y)
DRIVERS += drivers/scr_pc98.o drivers/vgaplan4_pc98.o drivers/mempl4.o
LDFLAGS += -maout-heap=0xffff
else
DRIVERS += drivers/scr_bios.o drivers/vgaplan4.o drivers/mempl4.o
endif

# higher speed asm VGA driver
#DRIVERS += drivers/scr_bios.o drivers/elkplan4.o drivers/mempl4.o

# hercules driver
#DRIVERS += drivers/scr_herc.o

ifeq ($(CONFIG_ARCH_PC98), y)
DRIVERS += drivers/ramfont.o drivers/X6x13.o drivers/elksutilasm.o
else
DRIVERS += drivers/romfont.o drivers/elksutilasm.o
endif

# The following line links the nano-X application with the server.
# This is required if no network is present, or for speed or debugging.
LINK_APP_INTO_SERVER=1

NANOXFILES = nanox/srvmain.o nanox/srvfunc.o nanox/srvutil.o nanox/srvevent.o
CLNTFILES = nanox/client.o
NETFILES = nanox/srvnet.o
STUBFILES = nanox/stubs.o

ifdef LINK_APP_INTO_SERVER
CFLAGS += -DNONETWORK=1
NANOXFILES += $(STUBFILES)
ALL += salibs $(NANOXDEMOS)
else
NANOXFILES += $(NETFILES)
DEMOLIBS += libnano-X.a
ALL += libnano-X.a nano-X nxdemos
endif

# remove any -mregparmcall as ASM files need cdecl calling convention
CFLAGS := $(filter-out -mregparmcall, $(CFLAGS))

SERVFILES = engine/devdraw.o engine/devmouse.o engine/devkbd.o engine/devclip1.o \
	engine/devpal1.o engine/devpal2.o engine/devpal4.o

SERVFILES += $(DRIVERS)

all: $(ALL)

libnano-X.a: $(CLNTFILES)
	$(AR) rc libnano-X.a $(CLNTFILES)

salibs: $(SERVFILES) $(NANOXFILES)

bin/nxlandmine: demos/landmine.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxworld: demos/world.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)
	cp demos/nxworld.map bin/nxworld.map

bin/nxclock: demos/nclock.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxterm: demos/nterm.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxtetris: demos/ntetris.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) -maout-heap=0xffff $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxtest: demos/nxtest.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxdemo: demos/demo.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxdemo2: demos/demo2.o $(NANOXFILES) $(SERVFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)

bin/nxvgatest: demos/demo-vga.o
	$(LD) $(LDFLAGS) $^ $(DRIVERS) $(LIBS) -o $@ $(MATHLIB) $(LDLIBS)


#
# client/server
#
.PHONY: nano-X
nano-X: bin/nano-X

bin/nano-X: $(SERVFILES) $(NANOXFILES)
	$(LD) $(LDFLAGS) $^ $(NANOLIBS) $(LIBS) -o $@ $(MATHLIB)

# only a few demos work in client/server mode
.PHONY: nxdemos
nxdemos: \
 bin/demo.sh \
 bin/demo \
 bin/demo2 \
 bin/landmine
# bin/nterm \
# bin/nclock \
# bin/world \

bin/demo.sh: scripts/demo.sh
	cp $< $@

$(info DEMOLIBS $(DEMOLIBS))

bin/demo \
bin/demo2 \
bin/landmine \
: $(DEMOLIBS)
# bin/nterm \
# bin/nclock \
# bin/world \

bin/%: demos/%.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) $^ $(DEMOLIBS) -o $@ $(MATHLIB)

install: $(NANOXDEMOS)
	$(INSTALL) $(NANOXDEMOS) $(DESTDIR)/bin
	$(INSTALL) demos/nxworld.map $(DESTDIR)/lib/nxworld.map

clean:
	$(RM) *.o *.a nano-X core
	$(RM) drivers/*.o
	$(RM) bin/*
	$(RM) nanox/*.o
	$(RM) engine/*.o
	$(RM) demos/*.o
