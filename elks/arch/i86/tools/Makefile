# Makefile for compiling assembler for Psion 3a - SDW 28/2/99
#
###########################################################################
# Relative path to base directory.

BASEDIR 	= ../../..

include	../$(BASEDIR)/.config

OUTS	= build mkbootloader
ifeq ($(CONFIG_ARCH_SIBO), y)
OUTS	+= wrt_disk.img imgconv
endif

#########################################################################
# Define the variables required by the standard rules - see the standard
# rules file (below) for details of these variables.

USEBCC  	= N

CLEANDEP	= 

CLEANME 	= build imgconv mkbootloader wrt_disk.img

DEPEND  	= 

DISTFILES	= mknbi-elks

NOINDENT	= 

###########################################################################
# Include the standard rules.

CFLAGS	+= -I$(BASEDIR)/include/ -I$(BASEDIR)/../include/

###########################################################################
# SIBO paramters.

STACK_SIZE	= 64		# paragraphs of 16 bytes
HEAP_SIZE	= 128		# paragraphs of 16 bytes

DATA_SEG	= 0x400 	# Segment address
HEAP_SEG	= 0x800 	# Segment address

###########################################################################
# Targets. You have to build the psion tree first to get driver stuff.

all: $(OUTS)

wrt_disk.o: wrt_disk.c

wrt_disk.tmp: wrt_disk.o file.o
	ld86 -0 -i -D $(DATA_SEG) -H $(HEAP_SEG) -o wrt_disk.tmp \
		wrt_disk.o file.o \
		../drivers/char/con_asm.o \
		../drivers/char/font.o \
		../drivers/char/key_asm.o \
		../drivers/block/ssd_asm.o \
		../lib/lib86.a

wrt_disk.img: wrt_disk.tmp imgconv
	./imgconv wrt_disk.tmp wrt_disk.img

###########################################################################
### Dependencies:
