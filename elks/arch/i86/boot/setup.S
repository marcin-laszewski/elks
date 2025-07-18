/*
!
!	setup.S		Copyright (C) 1991, 1992 Linus Torvalds
!
! setup.s is responsible for getting the system data from the BIOS,
! and putting them into the appropriate places in system memory.
! both setup.s and system has been loaded by the bootblock.
!
! This code asks the bios for memory/disk/other parameters, and
! puts them in a "safe" place: REL_INITSEG:0-REL_INITSEG:01FF, ie where
! the boot-block used to be. It is then up to the kernel to read them
! from there before the area is released to the main memory allocator.
!
! Move PS/2 aux init code to psaux.c
! (troyer@saifr00.cfsat.Honeywell.COM) 03Oct92
!
! some changes and additional features by Christoph Niemann,
! March 1993/June 1994 (Christoph.Niemann@linux.org)
!
! changes for ROM-Version (ELKS) by Christian Mardmoller
! Juni / 1999 chm@kdt.de
!   This code is called after the BIOS-POST and replaces
!   the BIOS OS/loader
!
! changes to support having setup + ELKS kernel as one single blob
! March 2020 https://github.com/tkchia
!
! changes to support .fartext headers and relocation
! Sep 2020 Greg Haerr
!
! load /bootopts file for FAT fs using boot sector's ram buffers
! Feb 2022 Greg Haerr
!
! read /bootopts hma=kernel to load kernel into HMA memory for IBM PC and PC-98
! March 2025 Greg Haerr
!
! The following data is passed to the main kernel (relative to INITSEG)
!
! index
!	...
!	4:	display page, 1 byte UNUSED
!	6:	video mode, 1 byte
!	7:	screen_cols, 1 byte
!	8:	video data, 2 bytes
!	10:	mono/color, video memory size, 2 bytes 
!	14:	screen_lines, 1 byte
!	15:	VGA present, 1 byte
!	0x20:	cpu_type	byte Processor type
!			0  = 8088
!			1  = 8086
!			2  = NEC V20
!			3  = NEC V30
!			4  = 80188
!			5  = 80186
!			6  = 80286
!			7  = 32-bit CPU (80386+)
!			8  = 80486 UNUSED
!			9  = Pentium UNUSED
!			10 = Pentium PRO UNUSED
!			255 = Unknown
!	...
!	0x2a:	mem_kbytes	word size of base memory in kbytes
!	0x30:	proc_name	byte[16] processor name string UNUSED
!	0x50:	cpu_id		byte[13] cpuid string UNUSED
!	...
!	0x1e2:	part_offset	long Sector offset of booted MBR partition
!	0x1e6:	elks_magic	long "ELKS", written by build tool
!	0x1ea:	xms_kbytes	word size of xms memory in kbytes
!	0x1ec:	hma_kernel	byte hma=kernel seen in /bootopts
!	0x1ed-0x1ee:		2 bytes UNUSED
!	0x1ef:	SETUPSEG	word UNUSED
!	0x1f1:	setup_sects	byte in 512-byte sectors, written by build tool
!	0x1f2:	ROOTFLAGS	word UNUSED
!	0x1f4:	syssize		word kernel size in paragraphs, written by build tool
!	0x1f6:	elks_flags	byte EF_AS_BLOB|EF_BIOS_DEV_NUM
!	0x1f7:			byte UNUSED
!	0x1f8:	RAMDISK		word UNUSED
!	0x1fa:	SVGA_MODE	word UNUSED
!	0x1fc:	root_dev	word Either BIOS boot device or actual kdev_t ROOT_DEV
!	0x1fe:	boot_flag	word UNUSED (0xAA55 in real boot sector)
*/

#include <linuxmt/config.h>
#include <linuxmt/devnum.h>
#include <linuxmt/boot.h>

// Relocating loader debug option
debug_output    =       0       // display various register values during execution
serial_output   =       0       // use INT 14 serial instead of INT 10 console out
debug_loader    =       0       // display relocations


// Signature words to ensure LILO loaded us right
#define SIG1	0xAA55
#define SIG2	0x5A5A

#define MINIX_SPLITID_LOW 0x0301L
#define KERNEL_MAGICNUMBER MINIX_SPLITID_LOW
#define HMA_SEG 0xffff

#ifndef CONFIG_ROMCODE
  INITSEG  = DEF_INITSEG	// initial setup data seg and initial Image load address
  SYSSEG   = DEF_SYSSEG 	// first kernel blob copy load point before relocation
  SETUPSEG = DEF_SETUPSEG	// this is the current code segment
#else
  INITSEG  = CONFIG_ROM_SETUP_DATA
  SYSSEG   = CONFIG_ROM_KERNEL_CODE
  SETUPSEG = CONFIG_ROM_SETUP_CODE
#endif

	.arch i8086, nojumps
	.code16
	.text
	.section .text
	.section .text.const
	.section .text

	.macro	.hex4sp	reg,msg
	.if	debug_output
	push	%ax
	.ifnb	\msg
	.section .text.const
1:	.ascii	"\msg","\0"
	.section .text
	push	%ax		// in case reg is AX
	mov	$1b,%ax
	call	csputs
	pop	%ax
	.endif
	mov	\reg,%ax
	call	hex4sp
	pop	%ax
	.endif
	.endm

	.global _start
_start:

#if defined(CONFIG_ROMCODE) && !defined(CONFIG_ARCH_SWAN)
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Entry point for IBM PC compatible option ROMs

	.byte 0x55,0xaa		// sign for ROM-Extension
	.byte 2*CONFIG_ROM_CHECKSUM_SIZE // space for lengthcode (promsize/512)

	push	%ds
	xor	%ax,%ax		// DS = 0
	mov	%ax,%ds
	movw	$start_os,4*0x19 // set INT 19 os/loader vector
	mov	%cs,4*0x19+2
	pop	%ds 
	lret			// back to BIOS

#else


//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Entry point for kernels loaded from DISK

	.hex4sp	%ss,"\nSETUP boot SS:"
	.hex4sp	%sp,"SP:"
	.hex4sp	$INITSEG,"\nDEF_INITSEG:"
	.hex4sp	$REL_INITSEG,"-> REL_INITSEG:"
	.hex4sp	$SETUPSEG,"DEF_SETUPSEG:"
	.hex4sp	$SYSSEG,"\nDEF_SYSSEG: "
	.hex4sp	$REL_SYSSEG,"-> REL_SYSSEG: "

// Check signature at end of setup
	cli
	mov	$SETUPSEG,%ax	// DS = setup CS
	mov	%ax,%ds
	cmpw	$SIG1,setup_sig1
	jne	no_sig
	cmpw	$SIG2,setup_sig2
	je	chk_blob

no_sig:	lea	no_sig_mess,%si
	call	puts
1:                             // And halt
	jmp	1b

no_sig_mess:	.ascii	"No ELKS setup signature found ...\0"

// If setup and kernel were loaded as a blob, we need to separate them out,
// then move to our own stack

chk_blob:
	mov	$INITSEG,%ax
	mov	%ax,%ds
	testb	$EF_AS_BLOB,elks_flags
	jz	no_blob
	std			// move backwards --- we are moving from a
				// lower address to a higher one
	mov	setup_sects,%al	// find start of a.out kernel
	xor	%ah,%ah
	.hex4sp	%ax,"\nSetup sectors "
	mov	$5,%cl
	shl	%cl,%ax
	add	$SETUPSEG,%ax
	mov	syssize,%bp
	.hex4sp	%bp,"System paras "
	.hex4sp	%ax,"a.out seg "

	mov	%bp,%cx		// first move the last sub-64KiB piece in place
	and	$0x0fff,%cx
	xor	%cx,%bp		// and $0xf000,%bp
	mov	%ax,%dx
	add	%bp,%dx
	mov	%dx,%ds
	lea	SYSSEG(%bp),%dx	// move %bp,dx; add $SYSSEG,%dx
	mov	%dx,%es
	jcxz	move_kernel_in_64ks
	shl	%cx
	shl	%cx
	shl	%cx
	mov	%cx,%si
	dec	%si
	shl	%si
	mov	%si,%di
	.hex4sp	%ds,"\nCopy a.out to DEF_SYSSEG (last) DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"
	.hex4sp	%cx,"CX:"

	rep
	movsw
move_kernel_in_64ks:
	mov	%es,%ax
	cmp	$SYSSEG,%ax
	jz	done_move_kernel
	sub	$0x1000,%ax
	mov	%ax,%es
	mov	%ds,%ax
	sub	$0x1000,%ax
	mov	%ax,%ds
	mov	$0x80,%ch
	mov	$0xfffe,%si
	mov	%si,%di
	.hex4sp	%ds,"\nCopy a.out to DEF_SYSSEG (64K)  DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"

	rep
	movsw
	jmp	move_kernel_in_64ks

done_move_kernel:
	cld
	mov	$INITSEG,%ax
	mov	%ax,%ss
	mov	$0x1000,%sp	// 4k gives 7 setup sectors and 512 byte stack above
	.hex4sp	%ss,"\nNew INIT SS:"
	.hex4sp	%sp,"SP:"

no_blob:
#endif

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Shared setup starts here for DISK and ROM cases
// Entry point for EMU86 ROM emulation

start_os:
#ifdef CONFIG_ARCH_SWAN
	// Enable UART serial
	mov	$0xE0,%al
	out	%al,$0xB3
#endif

	push	%cs
	pop	%ds
	mov	$hello_mess,%si
	call	puts

	mov	$INITSEG,%ax	// DS = setup data segment
	mov	%ax,%ds

#ifdef CONFIG_ROMCODE
	mov	%ax,%es		// clear setup data segment
	xor	%di,%di
	xor	%ax,%ax
	mov	$256,%cx
	cld
	rep
	stosw
#endif

// Set various INITSEG values used by kernel SETUP_xxx defines (see config.h)

	call	arch_set_initseg

// End of shared setup code
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#ifdef CONFIG_ROMCODE
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Case for kernel in ROM
// Check for correct a.out header

#ifdef CONFIG_ROMFS_FS
	movw $DEV_ROM,root_dev	// ROMFS
#else
	movw $DEV_FD0,root_dev	// floppy 0
#endif
	mov $CONFIG_ROM_KERNEL_CODE,%ax	// DS = ROM a.out image
   	mov %ax,%ds

	cmpw $KERNEL_MAGICNUMBER,0 // 0 = hdr.magic
	jne aout_err

	cmpb $0x04,3		// 3 = hdr.a_cpu = 8086
	jne 1f
	jmp aout_ok

1:	cmpb $0x10,3		// 3 = hdr.a_cpu = 80386
	jne aout_err
	jmp aout_ok

aout_err:
   	push %cs	
   	pop %ds
   	lea msg_aout_err,%si
	call puts
err_loop:
	jmp err_loop


msg_aout_err:
	.ascii "\r\nERROR: Wrong kernel a.out format\0"
msg_too_big:
	.ascii "\r\nERROR: kernel size > 64k\0"

aout_ok:
	mov 10,%cx		// 10 = hiword hdr.a_text size
	jcxz 2f			// max 64k
size_error:
   	mov %cs,%ax
   	mov %ax,%ds
	lea msg_too_big,%si
	call puts
	jmp err_loop		// and halt

2:	cmp %cx,14		// 14 = hiword of hdr.a_data size
				// max 64k
				// CX = 0
	jnz size_error
	cmpb $0x20,4		// 4 = hdr.a_hdrlen
				// check for small 32 byte hdr
	jnz size_error		// error, stray fartext or relocations present

// Now copy kernel data segment to RAM
	mov 8,%ax		// 8 = hdr.a_text size
	mov %ax,%si		// Build up normalized pointer to point to
	and $0x000f,%si		// data contents to copy to RAM
				// SI = offset
	mov $4,%cl		// Compute segment
	ror %cl,%ax
	add $CONFIG_ROM_KERNEL_CODE+2,%ax
	mov 0x0c,%cx		// 12 = hdr.a_data size
	push %ds
	mov %ax,%ds		// DS:SI -> contents to copy
	mov $CONFIG_ROM_KERNEL_DATA,%ax	// ES = RAM kernel data segment
	mov %ax,%es
	xor %di,%di
	inc %cx
	shr $1,%cx		// copy words
	cld
	rep
	movsw
	pop %ds

// BX,CX,DX,SI,DI,DS,ES are expected in kernel crt0.S

	mov 16,%dx		// 16 = hdr.a_bss size
	mov 12,%si		// 12 = hdr.a_data size
	mov 8,%bx		//  8 = hdr.a_text size
	mov 20,%ax		// 20 = hdr.a_entry point
	mov %es,%cx		// ES = DS = kernel data segment
	mov %cx,%ds

#ifdef CONFIG_ROM_DEBUG
	int $3			// break for debugger just before kernel
#endif

	mov $CONFIG_ROM_KERNEL_CODE+2,%di // a.out + 32 = kernel CS
	push %di
	push %ax		// IP
	xor %di,%di		// far text size always 0
	lret			// jump to _start in crt0.S

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Case for normal kernel loaded from DISK and relocated
//
#else /* REL_SYS*/

	mov $INITSEG,%ax
	mov %ax,%ds

// Get the memory size in Kbytes in AX
	call arch_get_mem
	mov $6,%cl  // to paragraphs
	shl %cl,%ax

// Move to the highest & aligned 64K

	sub $0x1000,%ax
	and $0xF000,%ax
	mov %ax,%es

	mov setup_sects,%al  // setup sector count
	xor %ah,%ah
	mov $8,%cl     // to words
	shl %cl,%ax
	mov %ax,%cx
	mov $512,%si   // skip raw sector
	xor %di,%di
	cld
	.hex4sp	%ds,"\nCopy DEF_SETUPSEG code to high mem DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"
	.hex4sp	%cx,"CX:"

	rep
	movsw

// Rebase CS DS ES SS to work in the 64K segment

	mov %es,%ax
	mov %ax,%ss   // automatic CLI for next instruction
	xor %sp,%sp
	.hex4sp	%ss,"\nNew HMEM SS:"
	.hex4sp	%sp,"SP:"

	push %ax
	mov $_next1,%ax
	push %ax
	lret

_next1:

// Relocate setup data (= raw boot sector)

	mov	$INITSEG,%ax
	mov	%ax,%ds
	mov	$REL_INITSEG,%ax
	mov	%ax,%es
	xor	%si,%si
	xor	%di,%di
	mov	$256,%cx
	cld
	.hex4sp	%ds,"\nCopy DEF_INITSEG data to REL_INITSEG DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"
	.hex4sp	%cx,"CX:"

	rep
	movsw

// Check system header

	mov	$SYSSEG,%ax
	mov	%ax,%ds

	cmpw $0x0301,0   // ELKS a.out magic
	jne sys_hdr_bad
	cmpw $0x0430,2   // i8086 - executable with separated I & D
	jne sys_hdr_bad
	mov 4,%bx        // BX = header size
	cmp $0x20,%bx    // header size (no relocs)
	je sys_hdr_good
	cmp $0x40,%bx    // header size (relocs)
	je sys_hdr_good

sys_hdr_bad:
	mov %ss,%ax
	mov %ax,%ds
	lea sys_hdr_msg,%si
	call puts
1:                       // halt
	jmp 1b
sys_hdr_msg:
	.ascii "Bad system header!\0"

// System header is good

sys_hdr_good:
	mov %sp,%bp
	mov 8,%dx     // -2(%bp) .text code size
	push %dx
	add $15,%dx   // align on next paragraph (issue #209)
	mov $4,%cl
	shr %cl,%dx   // DX = code size in paragraphs
	shr %cl,%bx   // BX = header size in paragraphs

	mov 12,%ax    // -4(%bp) data size
	push %ax
	mov 16,%ax    // -6(%bp) bss size
	push %ax
	mov 20,%ax    // -8(%bp) entry point
	push %ax
	xor %ax,%ax   // -10(%bp) far text size
	push %ax
	push %ax      // -12(%bp) text reloc size
	push %ax      // -14(%bp) far text reloc size
	push %ax      // -16(%bp) data reloc size
	push %ax      // -18(%bp) kernel .text segment
	push %ax      // -20(%bp) kernel .fartext segment
	push %ax      // -22(%bp) kernel .data segment

// Relocate kernel code

	mov $'t',%ax     // display kernel .text segment
	call putc

	mov $SYSSEG,%ax  // start of a.out
	add %bx,%ax      // skip header
	mov %ax,%ds
	xor %si,%si
	xor %di,%di

#ifdef CONFIG_BOOTOPTS
// Check whether relocating .text to HMA is possible
	call checkhma
	jc 2f		 // no HMA
	mov $HMA_SEG,%ax
	jmp 1f
#endif
2:	mov $REL_SYSSEG,%ax
1:	mov %ax,%es
	mov %ax,-18(%bp) // save .text segment
	.ifeq debug_output
	call hex4sp
	.endif

	mov -2(%bp),%cx  // code size in bytes
	add %dx,%ax      // add code paragraphs = .fartext start
	jnc 1f		 // skip if didn't overflow (no HMA)
	mov $REL_SYSSEG,%ax // .fartext starts at normal .text location
	add $16,%si	 // skip first paragraph at FFFF:0000
	add $16,%di
	sub $16,%cx
1:	mov %ax,-20(%bp) // save .data start in case no .fartext

	.hex4sp	%ds,"\nCopy DEF_SYSSEG .text to  REL_SYSSEG DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"
	.hex4sp	%cx,"CX:"

	cld
	rep
	movsb

// Relocate kernel far text

	cmp $0x04,%bx    // extended header?
	jne sys_no_far_text
	mov $SYSSEG,%ax  // readdress a.out header
	mov %ax,%ds
	mov 0x20,%ax     // text reloc size
	mov %ax,-12(%bp)
	mov 0x34,%ax     // far text reloc size
	mov %ax,-14(%bp)
	mov 0x24,%ax     // data reloc size
	mov %ax,-16(%bp)
	mov 0x30,%cx     // far text size
	mov %cx,-10(%bp)
	and %cx,%cx
	jz sys_no_far_text

	mov $'f',%ax      // display kernel .fartext segment
	call putc

	mov $SYSSEG,%ax
	add %bx,%ax       // skip header
	mov %ax,%ds
	xor %si,%si
	mov -2(%bp),%ax   // skip code bytes
	call add_ptr

	mov -18(%bp),%ax  // kernel .text segment
	add %dx,%ax       // skip code paragraphs
	jnc 1f
	mov $REL_SYSSEG,%ax // if text in HMA, start fartext here
1:	mov %ax,%es
	mov %ax,-20(%bp)  // save .fartext segment
	xor %di,%di

	.ifeq debug_output
	call hex4sp
	.endif
	.hex4sp	%ds,"\nCopy DEF_SYSSEG .ftext to REL_SYSSEG DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"
	.hex4sp	%cx,"CX:"

	rep
	movsb
sys_no_far_text:

// Relocate kernel data (not bss)
// Kernel resets bss itself

	mov -10(%bp),%ax // conv far text size to paras
	mov $4,%cl
	shr %cl,%ax
	mov %ax,%cx

	mov $'d',%ax
	call putc

	mov $SYSSEG,%ax
	add %bx,%ax      // skip header
	mov %ax,%ds
	xor %si,%si
	mov -2(%bp),%ax  // skip code bytes
	call add_ptr
	mov -10(%bp),%ax // far text size
	call add_ptr
	push %si

	mov -20(%bp),%ax // kernel .fartext segment
	add %cx,%ax      // skip far text
	mov %ax,%es
	mov %ax,-22(%bp) // save .data segment
	xor %di,%di
	mov -4(%bp),%cx  // data size

	.ifeq debug_output
	call hex4sp
	.endif
	.hex4sp	%ds,"\nCopy DEF_SYSSEG .data to  REL_SYSSEG DS:"
	.hex4sp	%si,"SI:"
	.hex4sp	%es,"ES:"
	.hex4sp	%di,"DI:"
	.hex4sp	%cx,"CX:"

	rep
	movsb

// Handle code/far text/data segment relocation

	pop %si          // get src ptr at fartext
	mov -4(%bp),%ax  // skip data size
	call add_ptr     // now at relocation entries

	mov -12(%bp),%cx // text reloc size
text_reloc:
	jcxz 1f
//	mov $'t',%ax
//	call putc
	mov -18(%bp),%ax // kernel .text segment
	mov %ax,%es

	call relocat
	sub $8,%cx
	add $8,%si
	jmp text_reloc
1:

	mov -14(%bp),%cx // far text reloc size
ftext_reloc:
	jcxz 2f
//	mov $'f',%ax
//	call putc
	mov -20(%bp),%ax // kernel .fartext segment
	mov %ax,%es

	call relocat
	sub $8,%cx
	add $8,%si
	jmp ftext_reloc
2:

	mov -16(%bp),%cx // data reloc size
data_reloc:
	jcxz 3f
//	mov $'d',%ax
//	call putc
	mov -22(%bp),%ax   // kernel .data segment
	mov %ax,%es

	call relocat
	sub $8,%cx
	add $8,%si
	jmp data_reloc
3:

//	mov $'\r',%ax
//	call putc
//	mov $'\n',%ax
//	call putc

// Load registers as kernel expects

	mov -22(%bp),%ax   // kernel .data segment
	mov %ax,%es
	mov %ax,%ds
	mov -2(%bp),%bx    // code size
	mov -4(%bp),%si    // data size
	mov -6(%bp),%dx    // bss size
	mov -8(%bp),%cx    // entry point
	mov -10(%bp),%di   // far text size

// Jump to kernel entry point

	mov -18(%bp),%ax   // kernel .text segment
	push %ax
	push %cx

	.hex4sp	%ss,"\nDone SS:"
	.hex4sp	%ds,"DS/ES:"
	.hex4sp	%bx,".text size:"
	.hex4sp	%di,".fartext size:"
	.hex4sp	%si,".data size:"
	.hex4sp	%ax,"\nJump CS:"
	.hex4sp	%cx,"entry:"
	.if debug_output
	.ifeq serial_output // if not serial output
	mov $debug_prompt,%ax
	call csputs
	xor %ah,%ah         // read key press
	int $0x16
	.endif
	.endif

	lret               // jump to REL_SYSSEG:_start to start kernel

// Relocate segment at ES: from relocation record at DS:SI
relocat:
	mov (%si),%di      // get r_vaddr
	mov 6(%si),%ax     // get r_type
	cmp $80,%ax        // R_SEGWORD
	jnz 9f
	mov 4(%si),%ax     // get r_symndx
	cmp $-2,%ax        // S_TEXT
	jnz 1f

	mov -18(%bp),%ax   // kernel .text segment
	jmp 3f
1:
	cmp $-5,%ax        // S_FTEXT
	jnz 2f

	mov -20(%bp),%ax   // kernel .fartext segment
	jmp 3f
2:
	cmp $-3,%ax        // S_DATA
	jnz 9f

	mov -22(%bp),%ax   // kernel .data segment
3:
	mov %ax,%es:(%di)

	.if debug_loader
	push %ax           // display [seg:off=val]
	mov $'[',%ax
	call putc
	mov %es,%ax
	call hex4
	mov $':',%ax
	call putc
	mov %di,%ax
	call hex4
	mov $'=',%ax
	call putc
	pop %ax
	call hex4
	push %ax
	mov $']',%ax
	call putc
	pop %ax
	.endif

	ret
9:
	jmp sys_hdr_bad

// Add AX to DS:SI and normalize segment
add_ptr:
	push %cx
	add %si,%ax
	mov	%ax,%si
	and $15,%si
	mov $4,%cl
	shr %cl,%ax
	mov %ds,%cx
	add %cx,%ax
	mov %ax,%ds
	pop %cx
	ret
#endif /* REL_SYS*/

// Utility/debugging routines

// Write DS:SI asciiz string to console
1:	call	putc
puts:	lodsb
	test	%al,%al
	jnz	1b
	ret

.if debug_output
// Write AL to console, convert LF -> CR LF
putcc:	cmp	$'\n',%al
	jnz	1f
	push	%ax
	mov	$'\r',%al
	call	putc
	pop	%ax
1:	jmp	putc

// Write CS:AX asciiz string to console
csputs:	push	%bx
	mov	%ax,%bx
1:	mov	%cs:(%bx),%al
	test	%al,%al
	jz	2f
	call	putcc
	inc	%bx
	jmp	1b
2:	pop	%bx
	ret

debug_prompt:
	.ascii	"\r\nPress key to boot: \0"
.endif

// Output hex nibble, byte and word. All registers saved.
hex1:	push %ax
	and $0x0F,%al
	add $'0',%al
	cmp $'9',%al
	jle 1f
	add $('A'-'9'-1),%al
1:	call putc
	pop %ax
	ret

hex2:	push %ax
	push %cx
	push %dx
	mov %al,%dl
	mov $4,%cl
	shr %cl,%al
	call hex1
	mov %dl,%al
	call hex1
	pop %dx
	pop %cx
	pop %ax
	ret

hex4:	push %ax
	push %ax
	mov %ah,%al
	call hex2
	pop %ax
	call hex2
	pop %ax
	ret

hex4sp: call hex4
	push %ax
	mov $' ',%ax
	call putc
	pop %ax
	ret

hello_mess:
	.ascii "\r\nELKS Setup \0"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Architecture specific routines for IBM PC
//	Entry points specific for platform setup of SETUP_xxx variables (see config.h)
//		arch_set_initseg
//		arch_get_mem

#ifdef CONFIG_ARCH_IBMPC

// Return total memory in Kbytes
arch_get_mem:
#if SETUP_MEM_KBYTES_ASM
	mov $SETUP_MEM_KBYTES_ASM,%ax  // force available memory (usually for testing)
#else
	int $0x12   // AX in KB
#endif
	ret

// Set INITSEG values for IBM PC
// Determine display type using INT 10h AH=12 and INT 10h AH=1A
// Get display page and mode using INT 10h AH=0F
// Determine size of main memory using INT 12h
// FIXME move to separate setup-bios.S file or individual drivers

arch_set_initseg:

#ifdef CONFIG_HW_VGA
// check for EGA/VGA and some config parameters
	mov	$0x12,%ah	// Get video data
	mov	$0x10,%bl
	int	$0x10
	mov	%ax,8
	mov	%bx,10
	mov	%cx,12
	mov	$0x5019,%ax
	cmp	$0x10,%bl
	je	novga
	mov	$0x1a00,%ax	// Added check for EGA/VGA discrimination
	int	$0x10
	mov	%ax,%bx
	mov	$0x5019,%ax
	movb	$0,15		// by default, no VGA
	cmp	$0x1a,%bl	// 1a means VGA, anything else EGA or lower
	jne	novga
	movb	$1,15		// we've detected a VGA
#else
        movb  $0,15		// no VGA in system
        mov   $25,%al		// height of display in rows
#endif /* CONFIG_HW_VGA*/

novga:	mov	%al,14		// CGA 25 rows

// Get video-card data

	mov	$0x0f,%ah
	int	$0x10
	mov	%ax,6		// al = video mode, ah = window width

	call	getcpu		// implemented in cputype.S

	mov	$INITSEG,%ax
	mov	%ax,%ds
	call	arch_get_mem	// save base memory size
	mov	%ax,mem_kbytes
	mov	$0x8800,%ax	// get xms size
	int	$0x15
	jc	1f
	mov	%ax,xms_kbytes
1:
#ifdef CONFIG_BOOTOPTS
	call	bootopts	// load /bootopts into DEF_OPTSEG (0050:0000)
	call    hmabootopts	// check /bootopts for hma=kernel
	mov	%al,hma_kernel
#endif
	ret

// Write AL to console, save all registers
putc:	push %ax
	push %bx
	push %cx
	push %dx
	push %bp        	// some BIOS may destroy BP
	.if serial_output
	mov $1,%ah
	xor %dx,%dx		// COM1
	int $0x14		// serial out
	.else
	mov $0x0E,%ah
	mov $7,%bx		// page 0
	int $0x10		// console out
	.endif
	pop %bp
	pop %dx
	pop %cx
	pop %bx
	pop %ax
	ret

// include code to determine CPU type
// needed for guessing system capabilities (sys_caps) for XT vs AT BIOS
// needed for XMS access using unreal vs INT 15
// TODO: remove and use alternate mechanism for XT vs AT BIOS capabilities
#include "cputype.S"

// include code to enable/verify A20 address gate
#include "../lib/a20-ibm.inc"

#endif /* CONFIG_ARCH_IBMPC*/


#ifdef CONFIG_BOOTOPTS
//
// load /bootopts file for FAT filesystem boot
//      If size > 512 bytes, both sectors must be contiguous.
//      This is currently guaranteed by providing a 1K /bootopts in
//      distribution images, so later edits will remain contiguous.
//
// Uses previous boot sector's BPB contents for disk geometry
// and previous boot sector's buffer which still holds root directory sector.
// No disk I/O is performed unless /bootopts found.
// Will fail gracefully on MINIX filesystems, no need for check of fs fstype.
bootopts:
	push	%ds
	push	%es

	// set ES = boot sector (BPB) address in high memory
	mov	$INITSEG,%ax
	mov	%ax,%ds
	mov	mem_kbytes,%ax	// Kbytes of memory
	mov	$6,%cl		// to paras
	shl	%cl,%ax
	sub	$0x1000,%ax	// find highest aligned 64K
	and	$0xf000,%ax
	mov	%ax,%es		// ES = boot sector w/BPB

	// set DS = boot sector buffer (rootdir) address in high memory
#ifdef CONFIG_IMG_FD1232
	add	$0x40,%ax	// buffer follows boot block in high mem
#else
	add	$0x20,%ax	// buffer follows boot block in high mem
#endif
	mov	%ax,%ds

	// get bootopts logical sector address (LBA)
	call	get_bootopts_sector
	and	%ax,%ax
	jz	0f
	call	getchs		// convert LBA in AX to CHS in CX,DH

#ifdef CONFIG_ARCH_PC98
	push	%bp
	mov	$INITSEG,%ax
	mov	%ax,%ds

	mov	$DEF_OPTSEG,%ax	// ES:BP = DEF_OPTSEG:0
	mov	%ax,%es
	xor	%bp,%bp

	mov	root_dev,%al	// Physical Device Address
	mov	$0xD6,%ah	// Read Data
	mov	$1024,%bx	// 1K bytes
	test	$0x10,%al	// Check Floppy Disk or Hard Disk
	jz	pc98_int1b
#ifdef CONFIG_IMG_FD1232
	mov	$0x03,%ch	// 1024 Bytes per sector
	inc	%dl		// sector number for PC_98 Floppy Disk
#else
	mov	$0x02,%ch	// 512 Bytes per sector
	inc	%dl		// sector number for PC_98 Floppy Disk
#endif
pc98_int1b:
	int	$0x1B		// BIOS disk interrupt
	pop	%bp
#else
	mov	$INITSEG,%ax
	mov	%ax,%ds
	mov	root_dev,%dl	// DL = boot drive

	mov	$DEF_OPTSEG,%ax	// ES:BX = DEF_OPTSEG:0
	mov	%ax,%es
	xor	%bx,%bx
	mov	$0x0202,%ax	// BIOS read disk, 2 sectors
	int	$0x13		// BIOS disk interrupt
#endif

	jnc	1f
0:	mov	$'F',%al
	jmp	2f
1:	mov	$' ',%al
2:	call	putc
	pop	%es
	pop	%ds
	ret

// BPB offsets in boot sector already in high memory
sec_per_clus	= 13
rsvd_sec_cnt	= 14
num_fats	= 16
root_ent_cnt	= 17
fat_sz_16	= 22
sec_per_trk	= 24
sect_offset	= 28
num_heads	= 26
fat_sz_32	= 36

root_ents_to_check = 8			// # dir entries to check for /bootopts

// return logical sector number (LBA) for bootopts file in AX
//
// Searches root directory previously read into boot sector's buffer to
// find starting cluster, then converts to LBA based on boot sector's BPB info.
get_bootopts_sector:
	push	%es

	mov	%es:root_ent_cnt,%ax	// push root directory entry count
	push	%ax

	mov	%es:num_fats,%al	// calculate # sectors before root directory
	xor	%ah,%ah
	mov	%es:fat_sz_16,%bx	// check FAT16 fat size
	and	%bx,%bx
	jnz	1f			// nonzero means FAT16 filesystem
	mov	%es:fat_sz_32,%bx	// get loword FAT32 fat size instead
1:	mulw	%bx
	add	%es:rsvd_sec_cnt,%ax
	push	%ax			// push # sectors before root directory

	mov	%es:sec_per_clus,%bl	// BL = sectors per cluster

	push	%cs			// ES = our code segment
	pop	%es

	mov	$-0x20,%si
find:	add	$0x20,%si		// look for /bootopts in root directory at DS:SI
	mov	$'.',%ax
	call	putc
	cmp	$root_ents_to_check*0x20,%si
	jz	no_find
	mov	$bootopts_name,%di
	mov	$8+3,%cx
	push	%si
	repz
	cmpsb				// %ds:(%si) with %es:(%di)
	lodsb				// AL = %ds:(%si)
	pop	%si
	jnz	find
	test	$0b11011000,%al		// check attr for normal (non-dir/volume)
	jnz	find

	mov	26(%si),%ax		// first cluster number
	dec	%ax
	dec	%ax
	mov	%bl,%cl			// CH = 0, CX = sectors per cluster
	mul	%cx
	pop	%bx			// BX = # sectors before root directory
	add	%ax,%bx
	pop	%ax			// AX = root directory entry count
#ifdef CONFIG_IMG_FD1232
	add	$0x1f,%ax
	mov	$5,%cl
#else
	add	$0xf,%ax
	mov	$4,%cl
#endif
	shr	%cl,%ax			// AX = # sectors of root directory
	add	%bx,%ax			// AX = sector of /bootopts file

	pop	%es
	ret

no_find:pop	%ax
	pop	%ax
	xor	%ax,%ax
	pop	%es
	ret

bootopts_name:
	.ascii	"BOOTOPTS   "

// translate LBA in AX to CHS in CX,DH (for IBM PC)
getchs:
	push	%ax
	mov	$'L',%ax
	call	putc
	pop	%ax
	call	hex4

	xchg	%ax,%bx			// BX = LBA
	mov	%es:num_heads,%cl	// head max
	mov	%es:sec_per_trk,%al	// sect max
	mulb	%cl			// AX = H*S
	xchg	%ax,%bx			// AX = LBA, BX = H*S
	xor	%dx,%dx
	add	%es:sect_offset,%ax	// sect_offset
	adc	%es:sect_offset+2,%dx	// DX:AX = disk LBA
	div	%bx			// AX = cylinder, DX = head
#ifdef CONFIG_ARCH_PC98
	mov	%ax,%cx			// PC-98 cylinder
#else
	mov	%al,%ch			// CH = low 8 bits of cylinder
	ror	%ah
	ror	%ah
	mov	%ah,%cl			// CL = high 2 bits of cylinder
#endif
	xchg	%ax,%dx			// move head to AX
	xor	%dx,%dx
	mov	%es:sec_per_trk,%bx	// BX = sect max
	div	%bx			// DL = sector - 1
#ifdef CONFIG_ARCH_PC98
#else
	or	%dl,%cl			// stash sector - 1 in CL
	inc	%cx			// CX = sector
#endif
	mov	%al,%dh			// DH = head

	mov	$'C',%ax
	call	putc
	mov	%ch,%al
	call	hex2

	mov	$'H',%ax
	call	putc
	mov	%dh,%al
	call	hex2

	mov	$'S',%ax
	call	putc
	mov	%cl,%al
	call	hex2

	ret

// check for hma=kernel in /bootopts, return AX = 0 if not
hmabootopts:
	push	%ds
	push	%es

	push	%cs			// ES = our code segment
	pop	%es
	mov	$DEF_OPTSEG,%ax		// DS:SI = /bootopts in memory
	mov	%ax,%ds

	xor	%si,%si			// look for hma=kernel in /bootopts segment
look:	mov	(%si),%al		// done when NUL seen
	test	%al,%al
	jz	1f
	mov	$hma_string,%di
	mov	$11,%cx
	push	%si
	repz
	cmpsb				// %ds:(%si) with %es:(%di)
	pop	%si
	inc	%si
	test	%cx,%cx
	jnz	look			// NZ = no match
	mov	$'H',%ax
	call	putc
	jmp	2f
1:	xor	%ax,%ax			// no HMA
2:	pop	%es
	pop	%ds
	ret

hma_string:
	.ascii	"\nhma=kernel"		// size = 11

// check whether HMA can be enabled, return NC if so with A20 enabled
checkhma:
	push	%ds
	mov	$INITSEG,%ax
	mov	%ax,%ds
	mov	xms_kbytes,%ax		//. must have xms size >= 64k
	cmp	$64,%ax
	jc	1f
	mov	hma_kernel,%al		// and hma=kernel in /bootopts
	test	%al,%al
	jz	1f
	call	enable_a20_gate		// and A20 enabled
	test	%ax,%ax
	jz	1f
	clc				// success
	jmp 	2f
1:	stc				// fail
2:	pop	%ds
	ret

#endif /* ifdef CONFIG_BOOTOPTS */

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Architecture specific routines for 8018X
//	Entry points specific for platform setup of SETUP_xxx variables (see config.h)
//		arch_set_initseg
//		arch_get_mem

#ifdef CONFIG_ARCH_8018X

// Return total memory in Kbytes
arch_get_mem:
	mov $SETUP_MEM_KBYTES,%ax
	ret

// Set INITSEG values for 8081X architecture
// currently hard-coded in config.h
arch_set_initseg:
	mov	$INITSEG,%ax
	mov	%ax,%ds
	ret

// Write AL to console, save all other registers
putc:	push %bx
	push %cx
	push %dx
	// TODO: send character in AL to console
	pop %dx
	pop %cx
	pop %bx
	ret

#endif /* CONFIG_ARCH_8018X*/

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Architecture specific routines for Solo/86
//	Entry points specific for platform setup of SETUP_xxx variables (see config.h)
//		arch_set_initseg
//		arch_get_mem

#ifdef CONFIG_ARCH_SOLO86

// Return total memory in Kbytes
arch_get_mem:
	mov $SETUP_MEM_KBYTES,%ax
	ret

// Set INITSEG values for Solo/86 architecture
// currently hard-coded in config.h
arch_set_initseg:
	mov	$INITSEG,%ax
	mov	%ax,%ds
	ret

// Write AL to console, save all other registers
putc:
	outb %al,$0x22
	ret

#endif /* CONFIG_ARCH_SOLO86 */

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Architecture specific routines for NEC PC98
//	Entry points specific for platform setup of SETUP_xxx variables (see config.h)
//		arch_set_initseg
//		arch_get_mem

#ifdef CONFIG_ARCH_PC98

// Return total memory in Kbytes
arch_get_mem:
#if SETUP_MEM_KBYTES_ASM
	mov $SETUP_MEM_KBYTES_ASM,%ax  // force available memory (usually for testing)
#else
	push %es
	push %cx
	push %bx
	xor %ax,%ax
	mov %ax,%es
	mov $0x501,%bx                  // 3 bit size - 1 in 128k of 0-1M mem range
	mov %es:(%bx),%cl
	and $7,%cl
	inc %cl
	mov $128,%al
	mul %cl
	pop %bx
	pop %cx
	pop %es
#endif
	ret

// Set INITSEG values for PC98 architecture
// currently hard-coded in config.h
arch_set_initseg:

// mov $0x30,%si
// call puts
// mov $'\n',%ax
// call putc

   push %es
   mov $INITSEG,%ax
   mov %ax,%es
   mov $24,%cx
   mov $0x90,%di
   xor %ax,%ax
   cld
   rep
   stosw
   pop %es

   call	getcpu                  // implemented in cputype.S

   xor %ax,%ax                  // get xms size in CX
   mov %ax,%ds
   mov $0x401,%bx               // byte size in 128k of 1M-16M mem range
   mov (%bx),%al
   mov $128,%cl
   mul %cl
   mov %ax,%cx
// Check for possible hole between end of 1M-16M range and 16M+ range
// When 0401h = 78h (=15MiB), hole does not exist
   cmp $15360,%ax               // 15M, no hole
   jnz 2f
   mov $0x594,%bx               // word size in 1024k of 16M-4G range
   mov (%bx),%ax
   cmp $49,%ax                  // don't allow overflow when > 64MB
   jl 1f
   mov $0xffff,%cx              // 64MB - 1024
   jmp 2f
1: mov $1024,%bx
   mul %bx
   add %ax,%cx

2: mov $INITSEG,%ax
   mov %ax,%ds
   call arch_get_mem		// save base memory for bootopts routine
   mov %ax,mem_kbytes
   mov %cx,xms_kbytes           // save xms memory for checkhma

#ifdef CONFIG_BOOTOPTS
   call bootopts		// attempting loading /bootopts config file
   call hmabootopts		// check /bootopts for hma=kernel
   mov %al,hma_kernel
#endif
   ret

putc:
   push %ds
   push %bx
   push %di
   push %es
   push %dx
   push %cs
   pop %ds
   cmp $'\r',%al
   jz putesc_r
   cmp $'\n',%al
   jz putesc_n
   xor %ah,%ah
   mov $tvram_x,%bx
   mov (%bx),%di
   mov $0xa000,%dx
   mov %dx,%es
   mov %ax,%es:(%di)
   inc %di
   inc %di
   mov %di,(%bx)
put_end:
   pop %dx
   pop %es
   pop %di
   pop %bx
   pop %ds
   ret
putesc_r:
   mov $tvram_x,%bx
   mov (%bx),%ax
   mov $160,%dl
   div %dl
   mul %dl
   mov %ax,(%bx)
   jmp put_end
putesc_n:
   mov $tvram_x,%bx
   mov (%bx),%ax
   mov $160,%dl
   div %dl
   inc %al
   mul %dl
   mov %ax,(%bx)
   jmp put_end
tvram_x:
   .word 160

// include code to determine 286 vs 386 CPU type
// needed for XMS access using unreal vs INT 1F
#include "cputype.S"

// include code to enable/verify A20 address gate
#include "../lib/a20-pc98.inc"

#endif /* CONFIG_ARCH_PC98 */

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Architecture specific routines for WonderSwan
//	Entry points specific for platform setup of SETUP_xxx variables (see config.h)
//		arch_set_initseg
//		arch_get_mem

#ifdef CONFIG_ARCH_SWAN

// Return total memory in Kbytes
arch_get_mem:
	mov $SETUP_MEM_KBYTES,%ax
	ret

// Set INITSEG values for WonderSwan
// currently hard-coded in config.h
arch_set_initseg:
        // Force color mode early to enable 64 KiB RAM
	mov	$0x80,%al
	out	%al,$0x60

	mov	$INITSEG,%ax
	mov	%ax,%ds
	ret

// Write AL to console, save all other registers
putc:
	push	%ax
1:	in	$0xB3,%al
	test	$0x04,%al
	jz	1b
	pop	%ax
	out	%al,$0xB1
	ret

#endif /* CONFIG_ARCH_SWAN */

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// This must be last
setup_sig1:	.word	SIG1
setup_sig2:	.word	SIG2
