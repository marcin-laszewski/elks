CFLAGS	+= -Wall
#CFLAGS	+= -O
#CFLAGS	+= -g

OUT	= ../bin/mfs
OBJS	= mkfs.o genfs.o dir.o iname.o inode.o main.o reader.o \
		super.o utils.o writer.o getoptx.o

all: $(OUT)

$(OUT):  $(OBJS)
	$(CC) -o $@ $(CFLAGS) $(OBJS)

$(OBJS): minix_fs.h bitops.h protos.h

.PHONY: distclean
distclean: clean
	find . -name '*~' | xargs $(RM) $(OUT)

.PHONY: clean
clean:
	$(RM) $(OBJS)
