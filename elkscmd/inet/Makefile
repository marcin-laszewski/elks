BASEDIR=..

include $(BASEDIR)/Make.defs

###############################################################################
#
# Include standard packaging commands.

include $(BASEDIR)/Make.rules

###############################################################################

# All subdirectories to build & clean

SUBDIRS = \
    httpd \
    nettools \
    telnet \
    telnetd \
    tinyirc \
    urlget \
	ftp \
    # EOL

CLEANS		= $(addprefix clean-,$(SUBDIRS))
INSTALLS	= $(addprefix install-,$(SUBDIRS))

all: $(SUBDIRS)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	@echo 'BUILD	$@'
	$(V)$(MAKE) -C $@ all

.PHONY: install
install: $(INSTALLS)

.PHONY: $(INSTALLS)
$(INSTALLS):
	@echo 'subst install-,INSTALL	,$@)'
	$(V)$(MAKE) -C $(subst install-,,$@)) install

.PHONY: clean
clean: $(CLEANS)

.PHONY: $(CLEANS)
$(CLEANS):
	@echo '$(subst clean-,CLEAN	,$@)'
	$(V)make -C $(subst clean-,,$@) clean
