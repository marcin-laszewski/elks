# Makefile for ash.
#
# 19980209 Claudio Matsuoka <claudio@conectiva.com>
# Modified for ELKS and bcc

BASEDIR = ..

include $(BASEDIR)/Make.defs

LOCALFLAGS = -DSHELL -I. -D_MINIX -D_POSIX_SOURCE -Dlint
LOCALFLAGS += -Wno-implicit-int

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

SRCS=	builtins.c cd.c dirent.c error.c eval.c exec.c expand.c input.c \
	jobs.c mail.c main.c memalloc.c miscbltin.c mystring.c nodes.c \
	options.c parser.c redir.c show.c signames.c syntax.c trap.c \
	output.c var.c linenoise_elks.c autocomplete.c

OBJS = $(addsuffix .o,$(basename $(SRCS)))
OBJS += init.o

# builtins must be manually added
OBJS += bltin/echo.o
OBJS += bltin/expr.o bltin/regexp.o bltin/operators.o

LDFLAGS += -maout-heap=12288 -maout-stack=2304

#
# Set READLINE in shell.h and add -ledit to LIBS if you want to use the
# editline package by Simmule Turner and Rich Salz.  (The big, bloated
# and GPL contaminated FSF readline should work too.)
#

CLEANFILES= $(OBJS) \
	builtins.c builtins.h init.c mkinit mknodes mksignames mksyntax \
	nodes.c nodes.h syntax.c syntax.h token.def \
	bltin/operators.h bltin/operators.c

.PHONY: all
all:	ash

ash: $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)

.PHONY: install
install: ash
	$(INSTALL) $^ $(DESTDIR)/bin/sh

.PHONY: clean
clean:
	$(RM) core ash $(CLEANFILES)

parser.o: token.def

token.def: mktokens
	sh $<

builtins.c builtins.h: shell.h builtins.table
	sh mkbuiltins $^

init.o: mkinit $(SRCS)
	./mkinit '$(CC) -c $(CFLAGS) init.c' $(SRCS)

mkinit: mkinit.c
	gcc -O2 -o $@ $^

nodes.c nodes.h: mknodes nodetypes nodes.c.pat
	./mknodes nodetypes nodes.c.pat

mknodes: mknodes.c
	gcc -O2 -o $@ $^

#signames.c signames.h: mksignames
#	./$<

#mksignames: mksignames.c
#	gcc -O2 -o $@ $^

syntax.c syntax.h: mksyntax
	./$<

mksyntax: mksyntax.c parser.h
	gcc -O2 -o $@ $<

bltin/operators.h:	bltin/mkexpr bltin/binary_op bltin/unary_op
	cd $(dir $@) && sh $(notdir $<)

bltin/echo.o:	bltin/echo.c
	cd $(dir $@) && $(CC) -I.. $(CFLAGS) -c $(notdir $<)

bltin/expr.o:	bltin/expr.c
	cd $(dir $@) && $(CC) -I.. $(CFLAGS) -c $(notdir $<)

bltin/operators.o:	bltin/operators.c
	cd $(dir $@) && $(CC) -I.. $(CFLAGS) -c $(notdir $<)

bltin/regexp.o:	bltin/regexp.c
	cd $(dir $@) && $(CC) -I.. $(CFLAGS) -c $(notdir $<)

# Dependencies you say?  This will have to do.
$(OBJS): error.h eval.h exec.h expand.h init.h input.h \
	jobs.h machdep.h mail.h main.h memalloc.h mystring.h options.h \
	output.h parser.h redir.h shell.h trap.h var.h \
	builtins.h nodes.h signames.h syntax.h

bltin/expr.o bltin/operators.o:	bltin/operators.h
