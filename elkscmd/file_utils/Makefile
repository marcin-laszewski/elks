BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

# note: grep doesn't read stdin, replaced with minix1/grep
# removed: l
# df ??
PRGS = \
 cat \
 chgrp \
 chmod \
 chown \
 cmp \
 cp \
 dd \
 grep \
 ln \
 ls \
 md5sum \
 mkdir \
 mkfifo \
 mknod \
 more \
 mv \
 rm \
 rmdir \
 split \
 sync \
 touch \

all: $(PRGS)

cp: $(TINYPRINTF)
cp: LDFLAGS += -maout-heap=0xffff
dd: LDFLAGS += -maout-heap=12288
ls: LDFLAGS += -maout-heap=20480
rm: $(TINYPRINTF)
rm: LDFLAGS += -maout-stack=12228

%: %.c

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

install: $(PRGS)
	@echo 'INSTALL	$(PROGS)'
	$(V)$(INSTALL) $(PRGS) $(DESTDIR)/bin

clean:
	@echo 'CLEAN'
	$(V)$(RM) $(PRGS) $(addsuffix .o,$(PRGS))
