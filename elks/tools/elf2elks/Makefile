# Convert ELF output file from gold linker to ELKS a.out
# Requires libelf to be installed
#
#########################################################################
#
# Note! Dependencies are done automagically by 'make dep', which also
# removes any old dependencies. DON'T put your own dependencies here
# unless it's something special (ie not a .c file).
#
#########################################################################
# Relative path to base directory.

TARBALL		= elftoolchain-0.7.1.tar.bz2
LIBELF 		= src/libelf/libelf.a
OBJS		= elf2elks.o
OUT		= ../bin/elf2elks

CFLAGS_ADD	= -Isrc/libelf -Isrc/common

all: $(OUT)

$(OUT): $(OBJS) $(LIBELF)
	$(CC) -o $@ $^

elf2elks.o: elf2elks.c $(LIBELF)
	$(CC) -c -o $@ $(CFLAGE) $(CFLAGS_ADD) $<

# libelf has its own makefile for building, but the makefile requires BSD
# make.  To avoid roping in BSD make as yet another dependency, we directly
# run the commands to generate and compile the libelf sources here.  This
# still requires m4 as a dependency though.
$(LIBELF): $(TARBALL) elftoolchain.patch
	$(RM) -r src
	mkdir src
	tar xjf $(TARBALL) -C src --strip-components=1
	cd src && patch -p1 < ../elftoolchain.patch
ifeq "Linux" "$(shell uname -s)"
	cd src/common && ./native-elf-format > native-elf-format.h
endif
	cd src/libelf \
	&& m4 -DSRCDIR=. libelf_convert.m4 > libelf_convert.c \
	&& m4 -DSRCDIR=. libelf_fsize.m4 > libelf_fsize.c \
	&& m4 -DSRCDIR=. libelf_msize.m4 > libelf_msize.c \
	&& for src in *.c; \
		do \
			$(CC) $(CFLAGS) $(CFLAGS_ADD) -c -I. -I../common "$$src"; \
		done \
	&& $(RM) libelf.a \
	&& $(AR) r libelf.a *.o

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	$(RM) -r $(OBJS) $(LIBELF) src/
