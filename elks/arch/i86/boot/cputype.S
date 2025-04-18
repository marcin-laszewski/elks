// obsolete and inaccurate, but required for arch_cpu = 6 and 7 (286, 386+)
// XT vs AT BIOS system capabilities (sys_caps) auto-detection by kernel
// Note: enables, then disables interrupts when called

/*
! Probe for the CPU
! These information is taken from "PC intern 3.0", Data Becker Verlag, 1992
! and from the Linux-Kernel, arch/i386/kernel/head.S
!
*/
getcpu:
	mov	$SETUPSEG,%ax   // setup code segment
	mov	%ax,%ds
	pushf                   // check for 8088/8086/V20/V30/80188/80186
	xor	%ax,%ax
	push	%ax
	popf
	pushf
	pop	%ax
	popf
	and	$0xf000,%ax
	cmp	$0xf000,%ax
	je	is8086
	mov	$0x7000,%ax     // check for 80286
	pushf
	push	%ax
	popf
	pushf
	pop	%ax
	popf
	and	$0x7000,%ax
	je	is80286
	pushf			// check for 32-bit CPU (80386+)
	pushf
	pop	%bx             // old FLAGS -> BX
	mov	%bx,%ax
	xor	$0x70,%ah       // try changing b14 (NT) or b13:b12 (IOPL)
	push	%ax
	popf
	pushf
	pop	%ax             // new FLAGS -> AX
	popf
	xor	%ah,%bh
	xor	%ax,%ax
	and	$0x70,%bh       // 32-bit CPU if we changed NT or IOPL
	je	not_32bit
	mov	$7,%cl          // 80386+
	#lea	p80386,%si
	jmp	cpu_store

not_32bit:			// Unknown CPU
	mov	$255,%cl
	#lea	px86,%si
	jmp	cpu_store

is8086:
	mov	$0xff,%al
	mov	$0x21,%cl	// 80188/86 uses only the five lower
	shr	%cl,%al		// bits of cl to determine the number
	jnz	is80186		// of shifts.
	sti             
	xor	%si,%si
	mov	$0xffff,%cx
	nop
	rep
	lodsb
	or	%cx,%cx
	jz	isv30
	call	queue
	jz	is8088
	mov	$1,%cl
	#lea	p8086,%si
	jmp	cpu_store
is8088:	xor	%cl,%cl
	#lea	p8088,%si
	jmp	cpu_store
is80186:call	queue
	jz	is80188
	mov	$5,%cl
	#lea	p80186,%si
	jmp	cpu_store
is80188:mov	$4,%cl
	#lea	p80188,%si
	jmp	cpu_store
isv30:	
	call	queue
	jz	isv20
	mov	$3,%cl
	#lea	pv30,%si
	jmp	cpu_store
isv20:	mov	$2,%cl
	#lea	pv20,%si
	jmp     cpu_store

is80286:mov	$6,%cl
	#lea	p80286,%si
//	jmp	cpu_store

cpu_store:
#if UNUSED
	push	%cx		// Store processor name
	mov	$INITSEG,%ax
	mov	%ax,%es
	mov	$0x30,%di
	mov	$16,%cx
	cld
con_cp1:
	lodsb
	stosb
	or	%al,%al
	loopnz	con_cp1
	mov	$0x50,%di
	lea	v_id,%si
	mov	$13,%cx
	rep
	movsb
	pop	%cx
#endif
	mov	$INITSEG,%ax	// Store processor type
	mov	%ax,%ds
	mov	%cl,0x20
	cli			// FIXME reset to cli; shouldn't have sti's above
	ret

/*
!
! Determine the length of the prefetch queue. 8088/188/v20 has
! a 4 bytes queue, 8086/186/v30 has 6 bytes.
!
! In ROM we can't change the code, we must copy to RAM
! Using Kernel dataseg
!
*/
queue:
#ifdef CONFIG_ROMCODE
	pushw	%ds
	movw	$CONFIG_ROM_KERNEL_DATA,%ax
	movw	%ax,%es
	movw	%cs,%ax
	movw	%ax,%ds
	movw	$queue_start,%si
	xorw	%di,%di
	movw	$0x20,%cx
	cli
	cld
	rep movsw
	sti
	xorw	%ax,%ax
	popw	%ds
	pushw	%es
	pushw	%ax
	lret
#endif
queue_start:

	mov	%cs,%ax
	mov	%ax,%es
	xor	%dx,%dx
	std
	lea	q_end,%di
#ifdef CONFIG_ROMCODE
        sub $queue_start,%di   //;we have new offset
#endif	
	mov	$0xfb,%al
	mov	$0x03,%cx
	cli
	rep
	stosb
	cld
	nop
	nop
	nop
	inc	%dx
q_end:	nop
	sti

#ifdef CONFIG_ROMCODE
        ljmp $CONFIG_ROM_SETUP_CODE,$queue_end
queue_end:
#endif

	or	%dx,%dx
	ret

#if UNUSED
//
// The processor name must not be longer than 15 characters!
//
p8088:	.ascii "Intel 8088\0"
p8086:	.ascii "Intel 8086\0"
pv20:	.ascii "NEC V20\0"
pv30:	.ascii "NEC V30\0"
p80188:	.ascii "Intel 80188\0"
p80186:	.ascii "Intel 80186\0"
p80286:	.ascii "Intel 80286\0"
p80386:	.ascii "Intel 80386+\0"
px86:   .ascii "Unknown x86\0"
//
// Here is the CPU id stored
//
v_id:	.byte 0,0,0,0
v_id2:	.byte 0,0,0,0
v_id3:	.byte 0,0,0,0
	.byte 0
#endif
