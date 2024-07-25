# Makefile for ia16-elf-gcc build of ELKS system calls

SYSCALLDAT ?= ${TOPDIR}/elks/arch/i86/kernel/syscall.dat

$(info MULTISUBDIR $(MULTISUBDIR))

ifeq "$(VPATH)" ""
	dir	=
else
	dir	= $(VPATH)/
endif

ifeq "$(filter -mregparmcall,$(CC) $(CFLAGS) $(MULTILIB))" ""
	regparmcall = 0
else
	regparmcall = 1
endif

$(info regparmcall	$(regparmcall))

TABS = \
 $(dir)call_tab.v \
 $(dir)defn_tab.v \


OBJS = \
	abort.o \
	argcargv.o \
	closedir.o \
	dup.o \
	dup2.o \
	environ.o \
	errno.o \
	execl.o \
	execle.o \
	execlp.o \
	execlpe.o \
	execv.o \
	execve.o \
	execvp.o \
	execvpe.o \
	getegid.o \
	geteuid.o \
	getgid.o \
	getpgid.o \
	getpid.o \
	getppid.o \
	getuid.o \
	killpg.o \
	lseek.o \
	mkfifo.o \
	opendir.o \
	program_filename.o \
	readdir.o \
	rewinddir.o \
	seekdir.o \
	setjmp.o \
	setpgrp.o \
	signal.o \
	sleep.o \
	syscall01.o \
	syscall23.o \
	syscall4.o \
	syscall5.o \
	signalcb.o \
	telldir.o \
	time.o \
	times.o \
	usleep.o \
	wait.o \
	wait3.o \
	waitpid.o \

include syscall.mk

.PHONY: all
all:  out.a $(TABS)

out.a: $(OBJS)
	$(RM) $@
	$(AR) $(ARFLAGS_SUB) $@ $^

$(OBJS): CFLAGS += -DL_execl -DL_execle -DL_execlp -DL_execlpe -DL_sleep -DL_usleep -DL_times
$(OBJS): SDEFS += -DL_execl -DL_execle -DL_execlp -DL_execlpe -DL_sleep -DL_usleep -DL_times

%.v: $(SYSCALLDAT) $(dir)syscall.awk
	@echo 'TAB	$@'
	@awk -f $(dir)syscall.awk -v $(basename $(notdir $@))=$@ $<

syscall.mk: $(SYSCALLDAT) $(dir)syscall.awk
	awk -f $(dir)syscall.awk -v file_mk=$@ regparmcall=$(regparmcall) $<

syscall/%.o: $(dir)syscall/%.s
	@echo 'SYS-AS	$@'
	@mkdir -p $(dir $@)
	@$(AS) $(ASFLAGS) -o $@ $<

$(dir)syscall/%.s: $(SYSCALLDAT) $(dir)syscall.awk
	@echo 'DATA-S	$@'
	@mkdir -p $(dir $@)
	@if ! awk \
		-f $(dir)syscall.awk \
		-v $(basename syscall=$(notdir $@)) \
		regparmcall=$(regparmcall) \
		$< \
		> $@; \
	then \
		$(RM) $@; \
		false; \
	fi

.PHONY: clean
clean:
	$(RM) $(OBJS) $(dir)syscall.mk $(TABS)
	! test -d $(dir)syscall || rmdir $(dir)syscall

include $(TOPDIR)/libc/Makefile.inc
