BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

PRGS = fm matrix cons ttyinfo sl ttyclock ttypong ttytetris

#PRGS_HOST =

CFLAGS += -DELKS=1
TUILIB = tty.o runes.o unikey.o

.PHONY: all
all: $(PRGS) $(PRGS_HOST)

fm: fm.o strverscmp.o realpath.o strlcpy.o strlcat.o curses.o curses2.o $(TUILIB) v7malloc.o
	$(LD) $(LDFLAGS) -maout-heap=0xffff -o $@ $^ $(LDLIBS)

matrix: matrix.o tty-cp437.o kcp437.o tty.o runes.o

cons: cons.o tty-cp437.o kcp437.o tty.o runes.o

ttyinfo: ttyinfo.o $(TUILIB)

sl: sl.o curses.o tty.o unikey.o

matrix cons ttyinfo sl:
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

ttyclock: ttyclock.o curses.o curses2.o curses3.o tty.o unikey.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

ttypong: ttypong.o curses.o curses2.o tty.o unikey.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

ttytetris: ttytetris.o tetris-frame.o tetris-shapes.o tetris-util.o
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: install
install: $(PRGS)
	$(INSTALL) $^ $(DESTDIR)/bin

.PHONY: all clean
clean:
	$(RM) $(PRGS) $(PRGS_HOST) *~ *.o
