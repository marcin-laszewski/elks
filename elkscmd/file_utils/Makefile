BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

# note: grep doesn't read stdin, replaced with minix1/grep
# removed: l
PRGS = ln ls mkdir mkfifo mknod more mv rm rmdir sync touch \
	cat chgrp chmod chown cmp cp dd grep md5sum split

all: $(PRGS)

cat: cat.o

chgrp: chgrp.o

chmod: chmod.o

chown: chown.o

cmp: cmp.o

cp: cp.o $(TINYPRINTF)

cp: LDFLAGS += -maout-heap=0xffff

dd: dd.o

dd: LDFLAGS += -maout-heap=12288

grep: grep.o

l: l.o

ln: ln.o

ls: ls.o

ls: LDFLAGS += -maout-heap=20480

md5sum: md5sum.o

mkdir: mkdir.o

mkfifo: mkfifo.o

mknod: mknod.o

more: more.o

mv: mv.o

rm: rm.o $(TINYPRINTF)

rm: LDFLAGS += -maout-stack=12228

rmdir: rmdir.o

split: split.o

sync: sync.o

touch: touch.o

cat chgrp chmod chown cmp cp dd grep l ln ls md5sum mkdir mkfifo mknod more mv rm rmdir split sync touch:
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

install: $(PRGS)
	$(INSTALL) $(PRGS) $(DESTDIR)/bin

clean:
	$(RM) $(PRGS) *.o
