# Makefile for the Linux/MT-kernel.
#
#########################################################################
#
# Note! Dependencies are done automagically by 'make dep', which also
# removes any old dependencies. DON'T put your own dependencies here
# unless it's something special (ie not a .c file).
#
#########################################################################
# Relative path to base directory.

BASEDIR 	= ../../..

#########################################################################
# Define the variables required by the standard rules - see the standard
# rules file (below) for details of these variables.

USEBCC 		= Y

CLEANDEP	=

CLEANME 	=

DEPEND  	=

DISTFILES	=

NOINDENT	= user.c

#########################################################################
# Include the standard commands.

include $(BASEDIR)/Makefile-rules

#########################################################################
# Objects to be compiled.

OBJS  = malloc.o user.o memcpyfs.o xms.o
LIB	= mm.a

#########################################################################
# Commands.

.PHONY: all
all:	$(LIB)

$(LIB): $(OBJS)
	@echo 'AR	$@'
	$(V)$(AR) rcs $@ $^

.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) $(LIB) $(OBJS)

#########################################################################
# Standard commands.

.PHONY: distdir
distdir:
	cp -pf Makefile *.c $(DISTDIR)/arch/i86/mm

#########################################################################
### Dependencies:
