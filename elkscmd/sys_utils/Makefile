BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

INSTALL ?= install

ELKS_LIB=$(ELKS_DIR)/arch/i86/lib

# clock enabled and has direct I/O port access
# knl, insmod removed as useless
# exitemu disabled because it calls INT directly to DOSEMU
PRGS = \
	init \
	min_init \
	getty \
	login \
	kill \
	mount \
	umount \
	passwd \
	reboot \
	shutdown \
	ps \
	meminfo \
	who \
	man \
	poweroff \
	chmem \
	clock \
	unreal16 \
	mouse \
	sercat \
	console \
	makeboot \
	#knl \

PRGS_OBJ = $(addsuffix .o,$(PRGS))

all: $(PRGS)

init:		LDFLAGS += -maout-heap=4096	-maout-stack=1024
min_init:	LDFLAGS += -maout-heap=256	-maout-stack=256
getty:		LDFLAGS += -maout-heap=1024	-maout-stack=1024
login:		LDFLAGS += -maout-stack=2048
meminfo:	LDFLAGS += -maout-heap=1	-maout-stack=512
ps:		LDFLAGS += -maout-heap=1024	-maout-stack=2048

chmem getty makeboot meminfo mount mouse ps: $(TINYPRINTF)

#exitemu: exitemu.o
#	$(LD) $(LDFLAGS) -o exitemu exitemu.o $(LDLIBS)

%: %.c

%: %.o
	@echo 'LD	$@'
	$(V)$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

makeboot.o: ../../bootblocks/mbr_autogen.c

../../bootblocks/mbr_autogen.c:
	$(MAKE) -C $(dir $@) $(notdir $@)

unreal.o: $(ELKS_LIB)/unreal.S
	$(LD) -melks-libc -mcmodel=small -c $< -o $@

unreal16: unreal16.o unreal.o
	$(LD) -melks-libc -mcmodel=small -nostdlib -o unreal16 unreal16.o unreal.o

unreal16.o: unreal16.S
	$(LD) -melks-libc -mcmodel=small -c $< -o $@

.PHONY: all
all: $(PRGS)

PRGS_INSTALL = $(addprefix $(DESTDIR)/bin/,$(PRGS))

.PHONY: install
install: $(PRGS_INSTALL)

$(DESTDIR)/bin/%: %
	@echo 'INSTALL	$@'
	$(V)$(INSTALL) -d $(dir $@)
	$(V)$(INSTALL) $< $@

.PHONY: clean
clean:
	$(RM) $(PRGS_OBJ) unreal.o core $(PRGS)
