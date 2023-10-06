# Makefile for Berkeley yacc.

BASEDIR = ..
    
include ../Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

BINDIR	      = /bin

HDRS	      = defs.h

LOCALFLAGS    = -DNDEBUG -D_POSIX_SOURCE

LIBS	      =

LINKER	      = $(CC)

MAKEFILE      = Makefile

OBJS	      = closure.o \
		error.o \
		lalr.o \
		lr0.o \
		main.o \
		mkpar.o \
		output.o \
		reader.o \
		skeleton.o \
		symtab.o \
		verbose.o \
		warshall.o

PRINT	      = pr -f -l88

PROGRAM	      = yacc

SRCS = $(subst .o,.c,$(OBJS)

.PHONY: all
all:		$(PROGRAM)

$(PROGRAM):	$(OBJS) $(LIBS)
	@echo 'LD	$@'
	$(V)$(LINKER) $(LDFLAGS) -o $(PROGRAM) $(OBJS) $(LIBS)

.PHONY: install
install: $(PROGRAM)
	@echo 'INSTALL	$^'
	$(V)$(INSTALL) $(PROGRAM) $(DESTDIR)/bin

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(OBJS) $(PROGRAM) core

#depend:;	@mkmf -f $(MAKEFILE) PROGRAM=$(PROGRAM) DEST=$(DEST)
#
#index:;	@ctags -wx $(HDRS) $(SRCS)
#
#listing:;	@$(PRINT) Makefile $(HDRS) $(SRCS) | lpr
#
#lint:;		@lint $(SRCS)
#
#program:        $(PROGRAM)
#
#tags:           $(HDRS) $(SRCS); @ctags $(HDRS) $(SRCS)

###

$(OBJS): defs.h
