CFLAGS	+= -Wall
OUT	= ../bin/setboot
OBJS	= setboot.o

all: $(OUT)

$(OUT): $(OBJS)
	$(CC) -o $@ $^

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	$(RM) $(OBJS)
