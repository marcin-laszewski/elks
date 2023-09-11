TOPDIR	= ../../..
CFLAGS	+= -Wall
OUT	= ../bin/eman
SRCS	= $(TOPDIR)/elkscmd/sys_utils/man.c

all: $(OUT)

$(OUT): $(SRCS)
	$(CC) -D_PATH_MANPAGES=\"$(TOPDIR)/elkscmd/man\" -o $@ $(CFLAGS) $^

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	touch $(SRCS)
