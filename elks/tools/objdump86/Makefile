CFLAGS	+= -Wall
OUT	= ../bin/objdump86
OBJS	= objdump86.o

all: $(OUT)

$(OUT): $(OBJS)
	$(CC) -o $@ $^

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	$(RM) $(OBJS)
