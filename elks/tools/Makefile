OUTS = mfs mfsck mkromfs setboot objtools elf2elks elks-compress eman
CLEANS = $(addprefix clean-,$(OUTS))

all: $(OUTS)

.PHONY: $(OUTS)
$(OUTS):
	$(MAKE) -C $@

.PHONY: clean
clean: $(CLEANS)

.PHONY: $(CLEANS)
$(CLEANS):
	$(MAKE) -C $(subst clean-,,$@) clean

nodep:

doclean: $(CLEANS)
