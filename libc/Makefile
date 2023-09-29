# Makefile of ELKS C Library

ifndef TOPDIR
TOPDIR	= ..
endif

include $(TOPDIR)/Make.defs

include Makefile.inc

DESTDIR ?= ../cross
IA16_LIBDIR ?= $(DESTDIR)/ia16-elf/lib

# Defines

SUBDIRS = \
	asm \
	ctype \
	error \
	gcc \
	getent \
	malloc \
	math \
	misc \
	net \
	regex \
	stdio \
	string \
	system \
	termcap \
	termios \
	time \
	# end of list

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
LIBS	= $(addsuffix /libc.a,$(addprefix build-ml/,$(MULTISUBDIR)))

TARGETS	= $(strip $(BUILDMULTIS))

target_get = $(word $(2), $(subst ;, ,$(1)))
target_name	= $(call target_get,$(1),1)
target_args	= $(call target_get,$(1),2)

TARGETS_NAME	= $(foreach t,$(TARGETS),$(call target_name,$(t)))

TARGETS_CLEAN	= $(addprefix clean-,$(TARGETS_NAME))
TARGETS_INSTALL	= $(addprefix install-,$(TARGETS_NAME))
TARGETS_UNINSTALL	= $(addprefix uninstall-,$(TARGETS_NAME))

TABS = \
 $(DESTDIR)/share/misc/elks/call_tab.v \
 $(DESTDIR)/share/misc/elks/defn_tab.v \


.PHONY: all
all: $(TARGETS_NAME)

.PHONY: show
show:
	@echo 'IA16_LIBDIR	$(IA16_LIBDIR)'
	@echo 'TARGETS	$(TARGETS)'
	@echo 'TARGETS_NAME	$(TARGETS_NAME)'
	@echo 'TARGETS_CLEAN	$(TARGETS_CLEAN)'
	@echo 'TARGETS_INSTALL	$(TARGETS_INSTALL)'

#--- clean ----------------------------------------
.PHONY: clean
clean: $(TARGETS_CLEAN)

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

# Install *.h: Create and use external file 'rules-h.mk',
# because this rule does not work well:
#$(foreach t,$(TARGETS_NAME),$(IA16_LIBDIR)/$(t)/%.h): %.h

include rules-h.mk

rules-h.mk:
	@echo 'MK	$@'
	@if ! for r in $(TARGETS_NAME); \
		do \
			echo "$(IA16_LIBDIR)/$$r/%.h: %.h"; \
			echo '	@echo "CP	$$@"'; \
			echo '	@mkdir -p $$(dir $$@)'; \
			echo '	@cp $$^ $$@'; \
			echo; \
			echo "$(IA16_LIBDIR)/$$r/%.h: ../elks/%.h"; \
			echo '	@echo "CP	$$@"'; \
			echo '	@mkdir -p $$(dir $$@)'; \
			echo '	@cp $$^ $$@'; \
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
.PHONY: $(TARGETS_NAME)
$(TARGETS_NAME): %: build-ml/%/crt0.o
$(TARGETS_NAME): %: build-ml/%/libc.a

get_param = $(subst @, -,$(subst $(1);,,$(filter $(1);%,$(TARGETS))))

%.o: %.asm
	$(AS) $(ASFLAGS) -o $@ $^

build-ml/%/crt0.asm: crt0.S
	mkdir -p $(dir $@)
	$(CC) -E $(call get_param,$(subst /crt0.asm,,$(subst build-ml/,,$@))) $(INCS) $(SDEFS) -MD -o $@ $<

build-ml/%/libc.a: $(foreach s,$(SUBDIRS),build-ml/%//$(s)/out.a)
	@echo "MAKE-LIBS: $@	$^"
	mkdir -p $(dir $@)
	( \
		echo CREATE $@.tmp; \
		for s in $^; \
			do echo ADDLIB "$$s"; done; \
			echo SAVE \
	) | $(AR) -M
	mv $@.tmp $@

get = $(word $(1),$(subst //, ,$(subst build-ml/,,$@)))
get_multi = $(call get,1)
get_lib = $(word 1,$(subst /, ,$(call get,2)))

build-ml/%/out.a: FORCE
	@echo 'BUILD	$@	$(call get_multi)'
	mkdir -p $(dir $@)
	make \
		-C $(dir $@) \
		-f $(abspath $(get_lib))/Makefile \
		all \
		SRCDIR=$(abspath $(get_lib)) \
		VPATH=$(abspath $(get_lib)) \
		MULTISUBDIR='$(call get_multi)' \
		MULTILIB='$(call get_param,$(call get_multi))'

.PHONY: FORCE
FORCE:
