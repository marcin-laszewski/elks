/*
 * meminfo.c
 *
 * Copyright (c) 2002 Harry Kalogirou
 * harkal@gmx.net
 *
 * Enhanced by Greg Haerr 24 Apr 2020
 *
 * This file may be distributed under the terms of the GNU General Public
 * License v2, or at your option any later version.
 */
#define __LIBC__            /* get all typedefs */
#include <linuxmt/types.h>
#include <linuxmt/mm.h>
#include <linuxmt/mem.h>
#include <linuxmt/heap.h>
#include <linuxmt/sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#define LINEARADDRESS(off, seg)     ((off_t) (((off_t)seg << 4) + off))

int aflag;      /* show application memory*/
int fflag;      /* show free memory*/
int tflag;      /* show tty and driver memory*/
int bflag;      /* show buffer memory*/
int sflag;      /* show system memory*/
int mflag;      /* show main memory*/
int allflag;    /* show all memory*/

int fd;
unsigned int ds;
unsigned int heap_all;
unsigned int seg_all;
unsigned int taskoff;
int maxtasks;
struct task_struct task_table;

int memread(word_t off, word_t seg, void *buf, int size)
{
    if (lseek(fd, LINEARADDRESS(off, seg), SEEK_SET) == -1)
        return 0;

    if (read(fd, buf, size) != size)
        return 0;

    return 1;
}

word_t getword(word_t off, word_t seg)
{
    word_t word;

    if (!memread(off, seg, &word, sizeof(word)))
        return 0;
    return word;
}

void process_name(unsigned int off, unsigned int seg)
{
    word_t argc, argv;
    char buf[80];

    argc = getword(off, seg);

    while (argc-- > 0) {
        off += 2;
        argv = getword(off, seg);
        if (!memread(argv, seg, buf, sizeof(buf)))
            return;
        printf("%s ",buf);
        break;      /* display only executable name for now */
    }
}

struct task_struct *find_process(unsigned int seg)
{
    int i;
    int off = taskoff;

    for (i = 0; i < maxtasks; i++) {
        if (!memread(off, ds, &task_table, sizeof(task_table))) {
            perror("taskinfo");
            exit(1);
        }
        if ((unsigned)task_table.mm[SEG_CODE] == seg ||
            (unsigned)task_table.mm[SEG_DATA] == seg) {
            return &task_table;
        }
        off += sizeof(struct task_struct);
    }
    return NULL;
}

static long total_segsize = 0;
static char *segtype[] =
    { "free", "CSEG", "DSEG", "DDAT", "FDAT", "BUF ", "RDSK" };

void display_seg(word_t mem)
{
    seg_t segbase = getword(mem + offsetof(segment_s, base), ds);
    segext_t segsize = getword(mem + offsetof(segment_s, size), ds);
    word_t segflags = getword(mem + offsetof(segment_s, flags), ds) & SEG_FLAG_TYPE;
    byte_t ref_count = getword(mem + offsetof(segment_s, ref_count), ds);
    struct task_struct *t;

    printf("   %04x   %s %7ld %4d  ",
        segbase, segtype[segflags], (long)segsize << 4, ref_count);
    if (segflags == SEG_FLAG_CSEG || segflags == SEG_FLAG_DSEG) {
        if ((t = find_process(mem)) != NULL) {
            process_name(t->t_begstack, t->t_regs.ss);
        }
    }

    total_segsize += (long)segsize << 4;
}

void dump_segs(void)
{
    word_t n, mem, arena = 2;
    seg_t segbase, oldbase = 0;

    printf("    SEG   TYPE    SIZE  CNT  NAME\n");
    n = getword (seg_all + offsetof(list_s, next), ds);
    while (n != seg_all) {
        mem = n - offsetof(segment_s, all);
        segbase = getword(mem + offsetof(segment_s, base), ds);
        if (segbase < oldbase)
            printf("[Arena %d]\n", arena++);
        oldbase = segbase;
        display_seg(mem);
        printf("\n");

        /* next in list */
        n = getword(n + offsetof(list_s, next), ds);
    }
}

void dump_heap(void)
{
    word_t total_size = 0;
    word_t total_free = 0;
    static char *heaptype[] =
        { "free", "MEM ", "DRVR", "TTY ", "TASK", "BUFH", "PIPE", "INOD", "FILE", "CACH"};

    /* split into two to save floppy space; linker will combine 2nd with above printf */
    printf("  HEAP   TYPE  SIZE");
    printf("    SEG   TYPE    SIZE  CNT  NAME\n");

    word_t n = getword (heap_all + offsetof(list_s, next), ds);
    while (n != heap_all) {
        word_t h = n - offsetof(heap_s, all);
        word_t size = getword(h + offsetof(heap_s, size), ds);
        byte_t tag = getword(h + offsetof(heap_s, tag), ds) & HEAP_TAG_TYPE;
        word_t mem = h + sizeof(heap_s);
        word_t segflags;
        int free, app, tty, buffer, system;

        if (tag == HEAP_TAG_SEG)
            segflags = getword(mem + offsetof(segment_s, flags), ds) & SEG_FLAG_TYPE;
        else segflags = -1;
        free = (tag == HEAP_TAG_FREE || segflags == SEG_FLAG_FREE);
        app = ((tag == HEAP_TAG_SEG)
            && (segflags == SEG_FLAG_CSEG || segflags == SEG_FLAG_DSEG ||
                segflags == SEG_FLAG_DDAT || segflags == SEG_FLAG_FDAT));
        tty = (tag == HEAP_TAG_TTY || tag == HEAP_TAG_DRVR);
        buffer = (tag == HEAP_TAG_SEG && segflags == SEG_FLAG_EXTBUF)
            || tag == HEAP_TAG_BUFHEAD || tag == HEAP_TAG_CACHE || tag == HEAP_TAG_PIPE;
        system = (tag == HEAP_TAG_TASK || tag == HEAP_TAG_INODE || tag == HEAP_TAG_FILE);

        if (allflag || (fflag && free) || (aflag && app) || (tflag && tty)
                    || (bflag && buffer) || (sflag && system)) {
            printf("  %04x   %s %5d", mem, heaptype[tag], size);
            total_size += size + sizeof(heap_s);
            if (tag == HEAP_TAG_FREE)
                total_free += size;

            switch (tag) {
            case HEAP_TAG_SEG:
                display_seg(mem);
                break;
            }
            printf("\n");
        }

        /* next in heap*/
        n = getword(n + offsetof(list_s, next), ds);
    }

    printf("  Heap/free   %5u/%5u Total mem %7ld\n", total_size, total_free, total_segsize);
}

void usage(void)
{
    printf("usage: meminfo [-amftbsh]\n");
}

int main(int argc, char **argv)
{
    int c;
    struct mem_usage mu;

    if (argc < 2)
        allflag = 1;
    else while ((c = getopt(argc, argv, "amftbsh")) != -1) {
        switch (c) {
            case 'a':
                aflag = 1;
                break;
            case 'm':
                mflag = 1;
                break;
            case 'f':
                fflag = 1;
                break;
            case 't':
                tflag = 1;
                break;
            case 'b':
                bflag = 1;
                break;
            case 's':
                sflag = 1;
                break;
            case 'h':
                usage();
                return 0;
            default:
                usage();
                return 1;
        }
    }

    if ((fd = open("/dev/kmem", O_RDONLY)) < 0) {
        perror("meminfo");
        return 1;
    }
    if (ioctl(fd, MEM_GETDS, &ds) ||
        ioctl(fd, MEM_GETHEAP, &heap_all) ||
        ioctl(fd, MEM_GETSEGALL, &seg_all) ||
        ioctl(fd, MEM_GETTASK, &taskoff) ||
        ioctl(fd, MEM_GETMAXTASKS, &maxtasks)) {
          perror("meminfo");
          return 1;
    }
    if (!memread(taskoff, ds, &task_table, sizeof(task_table))) {
        perror("taskinfo");
    }
    if (mflag)
        dump_segs();
    else dump_heap();

    if (!ioctl(fd, MEM_GETUSAGE, &mu)) {
        /* note MEM_GETUSAGE amounts are floors, so total may display less by 1k than actual*/
        printf("  Main %d/%dK used, %dK free, ",
            mu.main_used, mu.main_used + mu.main_free, mu.main_free);
        printf("XMS %d/%dK used, %dK free\n",
            mu.xms_used, mu.xms_used + mu.xms_free, mu.xms_free);
    }

    return 0;
}
