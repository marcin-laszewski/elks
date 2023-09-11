CFLAGS	+= -Wall
OUT	= ../bin/mkromfs
OBJS	= mkromfs.o list.o

all: $(OUT)

$(OUT): $(OBJS)
	$(CC) -o $@ $^

$(OBJS): list.h

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	$(RM) $(OBJS)

#distdir:
#	cp -pf Makefile *.c $(DISTDIR)/tools
