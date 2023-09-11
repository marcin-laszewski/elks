CFLAGS	+= -Wall

OUT	= ../bin/mfsck
OBJS	= mfsck.o

all: $(OUT)

$(OUT): $(OBJS)
	$(CC) -o $@ $^

$(OBJS): mfsck.h bitops.h

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	$(RM) $(OBJS)
