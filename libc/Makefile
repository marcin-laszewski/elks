# ia16-elf-gcc Makefile for ELKS C Library

%.o: %.S
%.o: %.asm
%.o: %.c
%.o: %.s
%.s: %.asm

ifndef TOPDIR
TOPDIR	= ..
endif

INCLUDES = \
 $(TOPDIR)/include \
 $(TOPDIR)/libc/include \
 $(TOPDIR)/elks/include \

PREFIX ?= ia16-elf-
include ia16.inc

CC=$(PREFIX)gcc
AS=$(PREFIX)as
AR=$(PREFIX)ar
LD=$(PREFIX)ld
RANLIB=$(PREFIX)ranlib

DEFINES = -D__LIBC__

# General FLAGS
FLAGS	+= -mtune=i8086

# FLAGS for $(CPP)
CPPFLAGS += $(addprefix -I,$(INCLUDES))
CPPFLAGS += $(DEFINES)

# FLAGS for $(CC): %.c -> %.o
CFLAGS	+= $(FLAGS)
CFLAGS	+= -ffreestanding -fno-inline -melks
CFLAGS	+= $(CPPFLAGS)
CFLAGS	+= -Wall
CFLAGS	+= -Os

# FLAGS for $(AS): %.s, %.asm -> %.o
ASFLAGS	+= --32-segelf
ASFLAGS	+= $(FLAGS)

# FLAGS for $(CC): %.S -> $.asm
SFLAGS	+= $(INCS)
SFLAGS	+= $(CPPFLAGS)

# FLAFS for $(LD)
LDFLAGS	+= $(FLAGS)

BUILD	?= build-ml

ifndef V
	V=@
endif

DESTDIR ?= ../cross
IA16_LIBDIR ?= $(DESTDIR)/ia16-elf/lib

#--- asm
ASM_SRCS = \
 asm/memcpy-s.S \
 asm/memset-s.S \
 asm/strcpy-s.S \
 asm/strlen-s.S \

ASM_LEFTOUT = \
 asm/memcmp-s.S \
 asm/strcmp-s.S \

OBJS += $(subst .S,.o,$(ASM_SRCS))

#--- ctype
OBJS += \
 ctype/ctype.o \
 ctype/isalnum.o \
 ctype/isalpha.o \
 ctype/isascii.o \
 ctype/isblank.o \
 ctype/isdigit.o \
 ctype/islower.o \
 ctype/isprint.o \
 ctype/ispunct.o \
 ctype/issspace.o \
 ctype/isupper.o \
 ctype/isxdigit.o \
 ctype/toupper.o \
 ctype/tolower.o \

#--- error
OBJS += \
 error/__assert.o \
 error/error.o \
 error/perror.o \

#--- gcc
# This module implements the infrastructure used by GCC-generated code for
# calling static initialization functions (constructors) & termination
# functions (destructors).  These may be registered by the application or by
# library routines, & are meant to be called by libc before entry to main( )
# and after exit( ) respectively.
#
# The gccint info page for GCC 6.3.0 says:
#
#	"Each list [of constructors or destructors] always begins with an
#	 ignored function pointer (which may hold 0, -1, or a count of the
#	 function pointers after it, depending on the environment).  This is
#	 followed by a series of zero or more function pointers to
#	 constructors (or destructors), followed by a function pointer
#	 containing zero. ...
#
#	"The best way to handle static constructors works only for object
#	 file formats which provide arbitrarily-named sections.  A section is
#	 set aside for a list of constructors, and another for a list of
#	 destructors.  Traditionally these are called `.ctors' and `.dtors'.
#	 ..."
#
# C functions can be marked as constructors or destructors in GCC using
# `__attribute__((constructor( )))' or `__attribute__((destructor( )))'.
#
# (Older versions of elks-libc used bcc's "autorun" mechanism to register
# constructors.  See github.com/jbruchon/dev86/blob/master/libc/Pre_main .)
#
# (Also, this module used to contain implementations of low-level routines
# __ashlsi3, __udivsi3, etc. used by GCC generated code.  It is now feasible
# to link programs with the real libgcc, so these routines are no longer
# needed.)	-- tkchia 20221204

# SRCS = divmodsi3.s ldivmod.s ashlsi3.s
GCC_SRCS = \
 do-global-ctors.S \
 do-global-dtors.S \

OBJS += $(addprefix gcc/,$(subst .S,.o,$(GCC_SRCS)))

#--- getent
OBJS += \
 getent/utent.o \
 getent/pwent.o \
 getent/getpwuid.o \
 getent/getpwnam.o \
 getent/__getpwent.o \
 getent/grent.o \
 getent/getgrgid.o \
 getent/getgrnam.o \
 getent/__getgrent.o \
 getent/putpwent.o \

#--- malloc
#MALLOC_CFLAGS	+= -DL_alloca
#MALLOC_CFLAGS	+= -DLAZY_FREE
# MCHUNK is word not byte min allocation size
MALLOC_CFLAGS	+= -DMCHUNK=512
#MALLOC_CFLAGS	+= -DMINALLOC
#MALLOC_CFLAGS	+= -DVERBOSE

# use V7 malloc for heap integrity checking
#MALLOC_OBJS += \
# malloc/v7malloc.o \
# malloc/calloc.o \
# malloc/sbrk.o \
# malloc/brk.o \

MALLOC_OBJS = \
 malloc/__alloca_alloc.o \
 malloc/__freed_list.o \
 malloc/__mini_malloc.o \
 malloc/alloca.o \
 malloc/brk.o \
 malloc/calloc.o \
 malloc/free.o \
 malloc/malloc.o \
 malloc/noise.o \
 malloc/realloc.o \
 malloc/sbrk.o \
 malloc/fmemalloc.o \

OBJS += $(MALLOC_OBJS)

#--- math
MATH_CFLAGS += -I$(TOPDIR)/libc/math -D__BSD_VISIBLE

MATH_OBJS += \
 math/s_floor.o \
 math/e_rem_pio2.o \
 math/k_rem_pio2.o \
 math/s_scalbn.o \
 math/s_copysign.o \
 math/e_log.o \
 math/e_log10.o \
 math/e_exp.o \
 math/e_pow.o \
 math/e_sqrt.o \
 math/s_fabs.o \
 math/s_cos.o \
 math/s_sin.o \
 math/k_cos.o \
 math/k_sin.o \
 math/s_tan.o \
 math/k_tan.o \
 math/e_acos.o \
 math/e_asin.o \
 math/s_atan.o \

MATH_OBJS += \
 math/s_floorf.o \
 math/e_rem_pio2f.o \
 math/s_scalbnf.o \
 math/s_copysignf.o \
 math/e_logf.o \
 math/e_log10f.o \
 math/e_expf.o \
 math/e_powf.o \
 math/e_sqrtf.o \
 math/s_fabsf.o \
 math/s_cosf.o \
 math/s_sinf.o \
 math/k_cosf.o \
 math/k_sinf.o \
 math/s_tanf.o \
 math/k_tanf.o \
 math/e_acosf.o \
 math/e_asinf.o \
 math/s_atanf.o \

OBJS += $(MATH_OBJS)

#--- misc
OBJS += \
 misc/aliases.o \
 misc/atexit.o \
 misc/atof.o \
 misc/atoi.o \
 misc/atol.o \
 misc/basename.o \
 misc/crypt.o \
 misc/devname.o \
 misc/dirname.o \
 misc/dtostr.o \
 misc/ecvt.o \
 misc/getcwd.o \
 misc/getenv.o \
 misc/getpass.o \
 misc/getopt.o \
 misc/itoa.o \
 misc/ltoa.o \
 misc/ltostr.o \
 misc/lltostr.o \
 misc/mktemp.o \
 misc/popen.o \
 misc/putenv.o \
 misc/qsort.o \
 misc/rand.o \
 misc/strtod.o \
 misc/strtol.o \
 misc/strtoul.o \
 misc/system.o \
 misc/tmpnam.o \
 misc/uitoa.o \
 misc/ultostr.o \
 misc/ulltostr.o \
 misc/wildcard.o \

OBJS += \
 misc/instrument.o \

#--- net
NET_SRCS = \
 in_aton.c \
 in_ntoa.c \
 in_gethostbyname.c \
 getsocknam.c \
 in_connect.c \
 in_resolv.c \

OBJS += $(addprefix net/,$(subst .c,.o,$(NET_SRCS)))

#--- regex
OBJS += regex/regex.o

#--- stdio
STDIO_CFLAGS = -DL_ftell

STDIO_OBJS = \
 stdio/init.o \
 stdio/__fopen.o \
 stdio/__io_list.o \
 stdio/fclose.o \
 stdio/fdopen.o \
 stdio/fflush.o \
 stdio/fgetc.o \
 stdio/fgets.o \
 stdio/fopen.o \
 stdio/fprintf.o \
 stdio/fputc.o \
 stdio/fputs.o \
 stdio/fread.o \
 stdio/freopen.o \
 stdio/fscanf.o \
 stdio/fseek.o \
 stdio/ftell.o \
 stdio/fwrite.o \
 stdio/puts.o \
 stdio/getdelim.o \
 stdio/getline.o \
 stdio/gets.o \
 stdio/printf.o \
 stdio/putchar.o \
 stdio/rewind.o \
 stdio/scanf.o \
 stdio/setbuffer.o \
 stdio/setvbuf.o \
 stdio/sprintf.o \
 stdio/snprintf.o \
 stdio/sscanf.o \
 stdio/stderr.o \
 stdio/stdin.o \
 stdio/stdout.o \
 stdio/putchar.o \
 stdio/ungetc.o \
 stdio/vfprintf.o \
 stdio/vfscanf.o \
 stdio/vprintf.o \
 stdio/vscanf.o \
 stdio/vprintf.o \
 stdio/vsprintf.o \
 stdio/vsnprintf.o \

OBJS += $(STDIO_OBJS)

#--- string
OBJS += \
 string/bzero.o \
 string/memccpy.o \
 string/memchr.o \
 string/memcmp.o \
 string/memcpy-c.o \
 string/memmove.o \
 string/memset-c.o \
 string/fmemset-c.o \
 string/movedata.o \
 string/strcasecmp.o \
 string/strcat.o \
 string/strchr.o \
 string/strcmp-c.o \
 string/strcspn.o \
 string/strcpy-c.o \
 string/strdup.o \
 string/strlen-c.o \
 string/strncasecmp.o \
 string/strncat.o \
 string/strncmp.o \
 string/strncpy.o \
 string/strpbrk.o \
 string/strrchr.o \
 string/strspn.o \
 string/strstr.o \
 string/strtok.o \

#--- system
SYSCALLDAT ?= ${TOPDIR}/elks/arch/i86/kernel/syscall.dat

TABS = \
 $(dir)call_tab.v \
 $(dir)defn_tab.v \

SYSTEM_CPPFLAGS = \
 -DL_execl \
 -DL_execle \
 -DL_execlp \
 -DL_execlpe \
 -DL_sleep \
 -DL_usleep \
 -DL_times \

SYSTEM_CFLAGS = $(SYSTEM_CPPFLAGS)
SYSTEM_SFLAGS = $(SYSTEM_CPPFLAGS)

SYSTEM_OBJS += \
 system/abort.o \
 system/argcargv.o \
 system/closedir.o \
 system/dup.o \
 system/dup2.o \
 system/environ.o \
 system/errno.o \
 system/execl.o \
 system/execle.o \
 system/execlp.o \
 system/execlpe.o \
 system/execv.o \
 system/execve.o \
 system/execvp.o \
 system/execvpe.o \
 system/getegid.o \
 system/geteuid.o \
 system/getgid.o \
 system/getpgid.o \
 system/getpid.o \
 system/getppid.o \
 system/getuid.o \
 system/killpg.o \
 system/lseek.o \
 system/mkfifo.o \
 system/opendir.o \
 system/program_filename.o \
 system/readdir.o \
 system/rewinddir.o \
 system/seekdir.o \
 system/setjmp.o \
 system/setpgrp.o \
 system/signal.o \
 system/sleep.o \
 system/syscall01.o \
 system/syscall23.o \
 system/syscall4.o \
 system/syscall5.o \
 system/signalcb.o \
 system/telldir.o \
 system/time.o \
 system/times.o \
 system/usleep.o \
 system/wait.o \
 system/wait3.o \
 system/waitpid.o \

OBJS += $(SYSTEM_OBJS)

include system/syscall.mk

#--- termcap
#TERMCAP_CFLAGS	+= -DDEBUG
#TERMCAP_CFLAGS	+= -DHAVE_CONFIG_H
#TERMCAP_CFLAGS	+= -DTIOCGWINSZ
#TERMCAP_CFLAGS	+= -DNO_ARG_ARRAY
ifeq "$(EMACS)" "yes"
TERMCAP_CFLAGS += -Demcas
endif

TERMCAP_OBJS = \
 termcap/entry.o \
 termcap/find.o \
 termcap/memout.o \
 termcap/tgetent.o \
 termcap/tgetflag.o \
 termcap/tgetnum.o \
 termcap/tgetst1.o \
 termcap/tgetstr.o \
 termcap/tgoto.o \
 termcap/tp-main.o \
 termcap/tparam.o \
 termcap/tparam1.o \
 termcap/tputs.o \
 termcap/xmalloc.o \
 termcap/xrealloc.o \

OBJS += $(TERMCAP_OBJS)

##TC_OBJS = termcap.o
##
##termcap: $(TC_OBJS)
##	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $^
##
##TP_OBJS = tp-main.o memout.o tparam1.o xmalloc.o xrealloc.o
##
##tparam: $(TP_OBJS)
##	$(CC) $(LDFLAGS) $(CFLAGS) -o $@ $^

#--- termios
OBJS += \
 termios/cfgetispeed.o \
 termios/cfgetospeed.o \
 termios/cfmakeraw.o \
 termios/cfsetispeed.o \
 termios/cfsetospeed.o \
 termios/isatty.o \
 termios/tcdrain.o \
 termios/tcflow.o \
 termios/tcflush.o \
 termios/tcgetattr.o \
 termios/tcgetpgrp.o \
 termios/tcsendbreak.o \
 termios/tcsetattr.o \
 termios/tcsetpgrp.o \
 termios/ttyname.o \

#--- time
OBJS += \
 time/asc_conv.o \
 time/asctime.o \
 time/ctime.o \
 time/gmtime.o \
 time/localtime.o \
 time/mktime.o \
 time/tm_conv.o \
 time/tzset.o \

# Stuff for handling multilibs (https://wiki.gentoo.org/wiki/Multilib),
# which ia16-elf-gcc uses to support separate library files for multiple ABIs
# for the same architecture and OS.
#
# Much of the complexity in the code below is for processing the output of
# GCC's -print-multi-lib option.  `ia16-elf-gcc -print-multi-lib' prints
# something like this:
#
#	.;
#	...
#	rtd;@mrtd
#	...
#	regparmcall/any_186/size;@mregparmcall@march=any_186@Os
#	...
#
# The last line above means that the options `-mregparmcall -march=any_186
# -Os' (listed after the `;') will make GCC look in the subdirectories
# regparmcall/any_186/size/ within the library search path's directories,
# when looking for library files.  `.' in the first line is the subdirectory
# for default compiler options.
#
# Depending on the version of ia16-elf-gcc, there are two possibilities:
#   * gcc has separate elks-libc multilibs, and supports the option
#     -melks-libc and possibly also (post-May 2022) -mr=elks.
#   * In a slightly older (pre-April 2019) arrangement, gcc supports -melks,
#     and possibly -melks-libc, but does not have separate elks-libc
#     multilibs.
#
# For the first case, arrange to build elks-libc for the available elks-libc
# multilib settings.  Furthermore, if $(DESTDIR) is defined, add an
# `install' makefile rule which will install the elks-libc files under
# $(DESTDIR), such that they can be used from outside the ELKS source tree;
# and also add an `uninstall' rule to allow elks-libc to be cleaned away.
#
# For the second case, arrange to build elks-libc only for default compiler
# settings.  Installing the libraries outside the ELKS tree is not supported
# in this case.
#
# $(MAINMULTISUBDIR) gives the multilib subdirectory containing the files we
# want to get the generated syscall tables from --- which should be the same
# anyway across all multilibs.  $(MAINMULTISUBDIR) is expected to be either
# `elkslibc' (first case) or `.' (second case).
#	-- tkchia

ALLMULTIS:=$(strip $(shell $(CC) -print-multi-lib))
ELKSLIBCMULTIS:=$(sort $(foreach ml,$(ALLMULTIS), \
    $(if $(findstring elks-libc,$(ml))$(findstring elkslibc,$(ml)),$(ml))))

ifneq "" "$(ELKSLIBCMULTIS)"
BUILDMULTIS:=$(ELKSLIBCMULTIS)
MAINMULTI:=$(firstword $(foreach ml,$(ELKSLIBCMULTIS), \
    $(if $(findstring /,$(ml)),,$(ml))))
else
MAINMULTI:=$(filter .;,$(ALLMULTIS))
BUILDMULTIS:=$(MAINMULTI)
override DESTDIR=
endif

ifeq "" "$(BUILDMULTIS)"
$(error no multilib variants to build for elks-libc)
endif

MULTISUBDIR	?= $(foreach ml,$(BUILDMULTIS),$(firstword $(subst ;, ,$(ml))))
TARGETS_DATA	= $(strip $(BUILDMULTIS))

target_get = $(word $(2), $(subst ;, ,$(1)))
target_name	= $(call target_get,$(1),1)
target_args	= $(call target_get,$(1),2)

TARGETS_NAME	= $(foreach t,$(TARGETS_DATA),$(call target_name,$(t)))
TARGETS_CLEAN	= $(addprefix clean-,$(TARGETS_NAME))
TARGETS_INSTALL	= $(addprefix install-,$(TARGETS_NAME))
TARGETS_UNINSTALL	= $(addprefix uninstall-,$(TARGETS_NAME))

# `ia16-elf-ar -M' errors out if the path argument to `CREATE' contains any
# weird characters such as `~'.  This caused problems when building elks-libc
# pre-releases on launchpad.net.  To work around this, make all paths in the
# `ia16-elf-ar -M' MRI script relative to $(TOPDIR).
$(LIBC): $(SUBLIBSINMULTILIB)
	mkdir -p $(@D)
	$(RM) -r $@.tmp
	set -e; \
	cd $(TOPDIR); \
	( \
		echo CREATE $(patsubst $(TOPDIR)/%,%,$(abspath $@.tmp)); \
		for s in $(patsubst $(TOPDIR)/%,%,$(abspath $^)); \
			do echo ADDLIB "$$s"; done; \
		echo SAVE \
	) | $(AR) -M
	mv $@.tmp $@

TABS = \
 $(DESTDIR)/share/misc/elks/call_tab.v \
 $(DESTDIR)/share/misc/elks/defn_tab.v \

.PHONY: all
all: $(LIBS)

.PHONY: info
info:
	@echo 'IA16_LIBDIR	$(IA16_LIBDIR)'
	@echo 'TARGETS_DATA	$(TARGETS_DATA)'
	@echo 'TARGETS_NAME	$(TARGETS_NAME)'
	@echo 'TARGETS_CLEAN	$(TARGETS_CLEAN)'
	@echo 'TARGETS_INSTALL	$(TARGETS_INSTALL)'

%.v: $(SYSCALLDAT) system/syscall.awk
	@echo 'TAB	$@'
	$(V)mkdir -p $(dir $@)
	$(V)awk -f system/syscall.awk -v $(basename $(notdir $@))=$@ $<

system/syscall.mk: $(SYSCALLDAT) system/syscall.awk
	$(V)mkdir -p $(dir $@)
	awk -f system/syscall.awk -v file_mk=$@ $<

include syscall.mk

syscall.mk: Makefile
	@echo 'MK	$@'
	@for t in $(TARGETS); \
	do \
		echo "$(BUILD)/$$t/%.asm: %.S"; \
		echo "	@echo 'AS-SYS	\$$@	\$$<'"; \
		echo '	$$(V)mkdir -p $$(dir $$@)'; \
		echo '	$$(V)$$(AS) $(ASFLAGS) -o $$@ $$<'; \
	done > $@

$(BUILD)/syscall/reg/%.s: REGPARMCALL=1
$(BUILD)/syscall/stack/%.s: REGPARMCALL=0
$(BUILD)/syscall/%.s: $(SYSCALLDAT) system/syscall.awk
	@echo 'DATA-S	$@'
	$(V)mkdir -p $(dir $@)
	$(V)if ! awk \
		-f system/syscall.awk \
		-v syscall=$(basename $(notdir $@)) \
		regparmcall=$(REGPARMCALL) \
		$< \
		> $@; \
	then \
		$(RM) $@; \
		false; \
	fi

.PHONY: system-clean
system-clean:
	$(RM) $(OBJS) $(dir)syscall.mk $(TABS)
	! test -d $(dir)syscall || rmdir $(dir)syscall

#--- clean ----------------------------------------
.PHONY: clean
clean:
	@echo 'CLEAN'
	$(V)$(RM) asm.mk h.mk libc.mk o.mk syscall.mk $(LIBS) \
		$(foreach t,$(TARGETS),$(addprefix $(BUILD)/$(t)/,$(OBJS))) \
		$(foreach a,reg stack,$(addprefix $(BUILD)/syscall/$(a)/,$(SYSCALL_OBJS)))

.PHONY: $(TARGETS_CLEAN)
$(TARGETS_CLEAN): clean-%: $(foreach s,$(SUBDIRS),clean-lib-%/$(s))

CLEAN_LIBS = $(foreach t,$(TARGETS_NAME),$(foreach s,$(SUBDIRS),clean-lib-$(t)/$(s)))

.PHONY: $(CLEAN_LIBS)
$(CLEAN_LIBS):
	! test -d $(subst clean-lib-,build-ml/,$@) \
	|| $(MAKE) \
		-f $(abspath $(lastword $(subst /, ,$@)))/Makefile \
		-C $(subst clean-lib-,build-ml/,$@) \
		VPATH=$(abspath $(lastword $(subst /, ,$@))) \
		clean

#--- install -----------------------------------------------
INCS_H = $(wildcard include/*.h include/arpa/*.h include/asm/*.h include/netinet/*.h include/sys/*.h)
INCS_H += $(subst ../elks/,,$(wildcard ../elks/include/arch/*.h ../elks/include/linuxmt/*.h))

.PHONY: install
install: $(TARGETS_INSTALL)

.PHONY: $(TARGETS_INSTALL)
$(TARGETS_INSTALL): install-%: $(IA16_LIBDIR)/%/crt0.o
$(TARGETS_INSTALL): install-%: $(IA16_LIBDIR)/%/libc.a
$(TARGETS_INSTALL): install-%: $(IA16_LIBDIR)/%/include/autoconf.h
$(TARGETS_INSTALL): $(TABS)
$(TARGETS_INSTALL): $(IA16_LIBDIR)/rt-specs/r-elks.spec

target_medium		= $(foreach t,$(TARGETS_INSTALL),$(if $(findstring /medium,$(t)),$(t),))
target_no_medium	= $(foreach t,$(TARGETS_INSTALL),$(if $(findstring /medium,$(t)),,$(t)))

$(call target_medium): install-%: $(IA16_LIBDIR)/%/elks-medium.ld

$(call target_no_medium): install-%: $(IA16_LIBDIR)/%/elks-small.ld
$(call target_no_medium): install-%: $(IA16_LIBDIR)/%/elks-tiny.ld

$(IA16_LIBDIR)/%/elks-medium.ld: ../elks/elks-medium.ld
	cp $^ $@

$(IA16_LIBDIR)/%/elks-small.ld: ../elks/elks-small.ld
	cp $^ $@

$(IA16_LIBDIR)/%/elks-tiny.ld: ../elks/elks-tiny.ld
	cp $^ $@

$(IA16_LIBDIR)/%: build-ml/%
	mkdir -p $(dir $@)
	cp $< $@

$(IA16_LIBDIR)/%/include/autoconf.h: ../include/autoconf.h
	mkdir -p $(dir $@)
	cp $< $@

$(TARGETS_INSTALL): install-%: $(addprefix $(IA16_LIBDIR)/%/,$(INCS_H))
#	@echo 'CHECK-H	$@'
#	@for f in $^; \
#	do \
#		! test -f \
#		&& echo "missing file: $$f" \
#		&& exit 1; \
#	done; \
#	true

include h.mk

h.mk: Makefile
	@echo 'MK	$@'
	@if ! for r in $(TARGETS_NAME); \
		do \
			echo "$(IA16_LIBDIR)/$$r/%.h: %.h"; \
			echo '	@echo "CP-H1	$$@"'; \
			echo '	$$(V)mkdir -p $$(dir $$@)'; \
			echo '	$$(V)cp $$^ $$@'; \
			echo; \
			echo "$(IA16_LIBDIR)/$$r/%.h: ../elks/%.h"; \
			echo '	@echo "CP-H2	$$@"'; \
			echo '	$$(V)mkdir -p $$(dir $$@)'; \
			echo '	$$(V)cp $$^ $$@'; \
			echo; \
		done > $@; \
	then \
		$(RM) $@; \
		false; \
	fi

$(DESTDIR)/share/misc/elks/%.v: system/%.v
	mkdir -p $(dir $@)
	cp $^ $@

$(IA16_LIBDIR)/rt-specs/r-elks.spec: $(TOPDIR)/elks/r-elks.spec
	mkdir -p $(dir $@)
	cp $^ $@

#--- uninstall--------------------------------------
.PHONY: uninstall
uninstall: $(TARGETS_UNINSTALL)
	$(RM) $(TABS) $(IA16_LIBDIR)/rt-specs/r-elks.spec

.PHONY: $(TARGETS_UNINSTALL)
$(TARGETS_UNINSTALL):
	@echo '$@'
	$(RM) -r $(addprefix $(IA16_LIBDIR)/$(subst uninstall-,,$@)/, \
		crt0.o elks-medium.ld elks-small.ld elks-tiny.ld include libc.a)

#--- build -----------------------------------------
#.PHONY: $(TARGETS_NAME)
#$(TARGETS_NAME): %: build-ml/%/crt0.o
#$(TARGETS_NAME): %: build-ml/%/libc.a

get_param = $(subst @, -,$(subst $(1);,,$(filter $(1);%,$(TARGETS_DATA))))

build-ml/%/crt0.asm: crt0.S
	mkdir -p $(dir $@)
	$(CC) -E $(call get_param,$(subst /crt0.asm,,$(subst build-ml/,,$@))) $(SFLAGS) -o $@ $<

$(foreach t,$(TARGETS),build-ml/$(t)/libc.a):
	@echo 'AR	$@	$?'
	$(V)$(AR) cr $@ $?
	@echo 'RANLIB	$@'
	$(V)$(RANLIB) $@

include libc.mk

libc.mk: Makefile
	@echo 'MK	$@'
	@for t in $(TARGETS); \
	do \
		if echo "$$t" | grep -q '/regparmcall'; \
		then \
			type='reg'; \
		else \
			type='stack'; \
		fi; \
		name=`echo "$$t" | sed 's|/|_|g'`; \
		echo "build-ml/$$t/libc.a: \$$(addprefix \$$(BUILD)/$$t/,\$$(OBJS)) \$$(addprefix \$$(BUILD)/syscall/$$type/,\$$(SYSCALL_OBJS))"; \
		echo "\$$(addprefix \$$(BUILD)/$$t/,\$$(MALLOC_OBJS)): CFLAGS += \$$(MALLOC_CFLAGS)"; \
		echo "\$$(addprefix \$$(BUILD)/$$t/,\$$(MATH_OBJS)): CFLAGS += \$$(MATH_CFLAGS)"; \
		echo "\$$(addprefix \$$(BUILD)/$$t/,\$$(STDIO_OBJS)): CFLAGS += \$$(STDIO_CFLAGS)"; \
		echo "\$$(addprefix \$$(BUILD)/$$t/,\$$(SYSTEM_OBJS)): CFLAGS += \$$(SYSTEM_CFLAGS)"; \
		echo "\$$(addprefix \$$(BUILD)/$$t/,\$$(subst .o,.asm,\$$(SYSTEM_OBJS))): SFLAGS += $(SYSTEM_SFLAGS)"; \
		echo "\$$(addprefix \$$(BUILD)/$$t/,\$$(TERMCAP_OBJS)): CFLAGS += \$$(TERMCAP_CFLAGS)"; \
	done > $@

%.o: %.s
	@echo 'AS	$@'
	$(V)$(AS) $(ASFLAGS) -o $@ $<

include asm.mk

asm.mk: Makefile
	@echo 'MK	$@'
	@for t in $(foreach d,$(TARGETS_DATA),'$(d)'); \
	do \
		echo "$$t" | sed -e 's|;.*|/%.asm: %.S|' -e 's|^|$$(BUILD)/|'; \
		echo "	@echo 'CC-AS	\$$@	\$$<'"; \
		echo '	$$(V)mkdir -p $$(dir $$@)'; \
		echo "$$t" | sed \
			-e 's|@| -|g' \
			-e 's|^.*;|	$$(V)$$(CC) -E|' \
			-e 's|$$| -I/tmp $$(SFLAGS) -I/tmp -I$$(dir $$<) -o $$@ $$<|'; \
		echo; \
	done > $@

%.o: %.asm
	@echo 'AS-ASM	$@'
	$(V)$(AS) $(ASFLAGS) -o $@ $<

include o.mk

o.mk: Makefile
	@echo 'MK	$@'
	@for t in $(foreach d,$(TARGETS_DATA),'$(d)'); \
	do \
		echo "$$t" | sed -e 's|;.*|/%.o: %.c|' -e 's|^|$$(BUILD)/|'; \
		echo "	@echo 'CC	\$$@'"; \
		echo '	$$(V)mkdir -p $$(dir $$@)'; \
		echo "$$t" | sed \
			-e 's|@| -|g' \
			-e 's|^.*;|	$$(V)$$(CC) |' \
			-e 's|$$| $$(CFLAGS) -I$$(dir $$<) -c -o $$@ $$<|'; \
		echo; \
	done > $@
