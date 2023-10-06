# Convert ELF output file from gold linker to ELKS a.out
# Requires libelf sources of 'elftoolchain' (tar, bz2, gz, xz)
#
# Usage: $ make info
#
#########################################################################
# Note! Dependencies are not done automagically.
#########################################################################
# Relative path to base directory.

DEFAULT_TARBALL	= elftoolchain-0.7.1.tar.bz2
DEFAULT_INSTDIR	= ../bin

TARBALL	?= $(DEFAULT_TARBALL)
NAME	= $(subst .xz,,$(subst .tar,,$(subst .gz,,$(subst .bz2,,$(TARBALL)))))
SRC	= $(NAME)
INSTDIR	?= $(DEFAULT_INSTDIR)
OUT	= elf2elks
PATCH_1	= elftoolchain.patch
INCS	= $(SRC)/libelf $(SRC)/common

ifndef V
	V = @
endif

override CFLAGS	+= $(addprefix -I,$(INCS))
#override CFLAGS	+= -g
override CFLAGS	+= -O

M4S = \
 $(SRC)/libelf/libelf_convert.m4 \
 $(SRC)/libelf/libelf_fsize.m4 \
 $(SRC)/libelf/libelf_msize.m4 \

OBJS = \
 elf2elks.o \
 $(subst .c,.o,$(SRCS)) \
 $(subst .m4,.o,$(M4S)) \

include srcs.mk

.PHONE: all
all: $(INSTDIR)/$(OUT)

$(INSTDIR)/$(OUT): $(OUT)
	@echo 'STRIP	$@'
	$(V)strip -o $@ $<

$(OUT): $(OBJS)
	@echo 'LD	$@'
	$(V)$(CC) $(LDFLAGS) -o $@ $^

$(OBJS): $(SRC)/common/native-elf-format.h

$(SRC)/common/native-elf-format.h: $(SRC)/.$(PATCH_1)
	@echo 'CREATE	$@'
	$(V)if ! (cd $(dir $@) && ./native-elf-format) > $@; \
	then \
		$(RM) $@; \
		false; \
	fi

$(SRC)/.$(PATCH_1): $(PATCH_1) $(addsuffix /.h,$(INCS)) $(SRCS)
	@echo 'PATCH	$<'
	$(V)patch -d $(dir $@) -p1 < $<
	$(V)touch $@

$(SRC)/%/.h: $(TARBALL)
	@echo 'UNTAR-H	$(dir $@)'
	$(V)tar xf $(TARBALL) $(dir $@)
	$(V)touch $@

$(SRCS) $(M4S) &: $(TARBALL)
	@echo 'UNTAR-C	$<'
	$(V)tar xf $< $(SRCS)
	$(V)touch $(SRCS) $(M4S)

%.o: %.c
	@echo 'CC	$@'
	$(V)$(CC) -c $(CFLAGS) -o $@ $<

%.c: %.m4
	@echo 'M4-C	$@'
	$(V)m4 -DSRCDIR=$(dir $<) $< > $@

.PHONY: info
info:
	@echo '$(MAKE) [-j<n>] [V=] [TARBALL=...] [INSTDIR=...] [ | all | clean | distclean ]' 1>&2
	@echo '-j<n>		<n> parallel tasks. For example: -j`nproc`'
	@echo 'V=		Print executed command.'
	@echo 'TARBALL:	Default: $(DEFAULT_TARBALL)'
	@echo 'INSTDIR:	Default: $(DEFAULT_INSTDIR)'
	@echo 'Default target:	all'
	@echo 'all:		Build "$(OUT)".'
	@echo 'clean:		Remove created object files.'
	@echo 'distclean:	Remove all created files, but "$(INSTDIR)/$(OUT)".'

srcs.mk: $(TARBALL)
	@echo 'SRCS	$<'
	$(V)tar tf $< --wildcards '$(NAME)/libelf/*.c' \
	| awk 'BEGIN { print "SRCS = \\"; } { printf " %s \\\n", $$1; }' \
	> $@

.PHONY: distclean
distclean: clean
	@echo 'DISTCLEAN $(OUT) $(SRC)'
	$(V)find . -name '*~' | xargs $(RM) -r $(OUT) $(SRC)

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(OBJS) $(SRC)/common/native-elf-format.h $(subst .m4,.c,$(M4S)) srcs.mk
