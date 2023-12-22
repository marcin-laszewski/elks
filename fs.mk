# Makefile for ELKS filesystem

#include Make.defs

ifndef V
	V = @
	INFO = @echo '[fs.mk]	'
endif

ifndef DESTDIR
$(error	Undefined: DESTDIR)
endif

# include selected config file for image instructions
ifdef CONFIG
include $(CONFIG)
endif

ROOT		?= .
ELKSKERNEL	?= $(ROOT)/elks
ELKSCMD		?= $(ROOT)/elkscmd
IMAGE		?= $(ROOT)/image
TEMPLATE	?= $(ELKSCMD)/rootfs_template

ELKSIMG	?= $(ELKSKERNEL)/arch/i86/boot/Image

ifeq "$(CONFIG_IMG_BOOT)" "y"
TARGETS += $(DESTDIR)/linux
endif

ifdef CONFIG_TIME_RTC_LOCALTIME
TARGETS += .config_rtc
endif

ifdef CONFIG_TIME_TZ
TARGETS += .config_timezone
endif

MODE	= 775

.PHONY: all
all: \
 elkscmd \
 $(DESTDIR)/etc/issue \
 $(DESTDIR)/etc/motd \
 $(TARGETS)

.PHONY: elkscmd
elkscmd: template
	$(INFO) 'MAKE	$(ELKSCMD)'
	$(V)$(MAKE) -C $(ELKSCMD) install "CONFIG=$(abspath $(CONFIG))"

.PHONY: template
template: | $(DESTDIR)/tmp
	$(INFO) 'TEMPLATE	$(TEMPLATE)'
	$(V)cp -a $(TEMPLATE)/. $(DESTDIR)
	$(V)find $(DESTDIR) -name .keep -delete

$(DESTDIR)/etc/issue: | $(DESTDIR)/etc
	$(INFO) 'CREATE	$@'
	$(V)if ! $(IMAGE)/ver.pl $(ELKSKERNEL)//Makefile-rules > $@; \
	then \
		$(RM) $@; \
		false; \
	fi

$(DESTDIR)/etc/motd: | $(DESTDIR)/etc
	$(INFO) 'CREATE	$@'
	$(V)if ! git log --abbrev-commit \
	| head -1 \
	| sed 's/commit/ELKS built from commit/' \
	> $@; \
	then \
		$(RM) $@; \
		false; \
	fi

$(DESTDIR)/linux: | $(DESTDIR)
$(DESTDIR)/linux: $(ELKSIMG)
	$(INFO) 'INSTALL	$@'
	$(V)install $< $@

.config_rtc: $(DESTDIR)/etc/rc.sys
	$(INFO) 'UPDATE	$@	LOCALTIME'
	$(V)sed -e 's/clock -s -u/clock -s/' < $< > @<.new
	$(V)mv $<.new $<
	$(V)touch $@

.config_timezone: $(DESTDIR)/etc/profile
	$(INFO) 'UPDATE	TZ=$(CONFIG_TIME_TZ)'
	$(V)echo 'test -z "$$TZ" && export TZ="$(CONFIG_TIME_TZ)"' >> $<
	$(V)touch $@

$(DESTDIR)/etc: | $(DESTDIR)
$(DESTDIR)/tmp: MODE = 777
$(DESTDIR)/tmp: | $(DESTDIR)

$(DESTDIR) \
$(DESTDIR)/etc \
$(DESTDIR)/tmp:
	$(INFO) 'MKDIR	$(MODE)	$@'
	$(V)mkdir -p --mode=$(MODE) $@

.PHONY: clean
clean:
	$(INFO) 'CLEAN $(TARGETS) $(DESTDIR)'
	$(V)$(RM) $(TARGETS)
	$(V)$(RM) -r $(DESTDIR)
