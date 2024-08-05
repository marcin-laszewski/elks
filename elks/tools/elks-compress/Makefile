CFLAGS	+= -Wall
CFLAGS	+= -I../../include
OUTS	= ../bin/elks-compress ../bin/exomizer
OBJS	= elks-compress.o

all: $(OUTS)

../bin/elks-compress: $(OBJS)
	$(CC) -o ../bin/elks-compress $(CFLAGS) $(OBJS)

../bin/exomizer: exomizer/src/exomizer
	cp -p $< $@

.PHONY: exomizer/src/exomizer
exomizer/src/exomizer:
	$(MAKE) -C $(dir $@)

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUTS)

.PHONY: clean
clean: clean-elks-compress clean-exomizer

.PHONY: clean-elks-compress
clean-elks-compress:
	$(RM) $(OBJS)

.PHONY: clean-exomizer
clean-exomizer:
	$(MAKE) -C exomizer/src clean
