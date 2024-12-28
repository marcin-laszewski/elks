; C86 compiler library - AS86 version
; Calls to these routines may be emitted by the C86 compiler as helpers.
; This file contains support routines for 32-bit on the 8086.
; It is intended for use code generated by the C86 compiler.
;
; 21 Nov 24 Greg Haerr Ported from clib.s for C86 ELKS
; 23 Nov 25 Added alloca (requires -stackopt=minimum)
; 23 Nov 25 Added stackcheck (requires -stackcheck=yes)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        use16    86
        .text
;
; C86 helper functions
;
        .global ___alloca
        .comm   ___stacklow,2   ; lowest protected SP value
___alloca:
        pop     bx              ; ret address
        pop     ax              ; alloca size
        inc     ax
        and     ax,#0xfffe
        mov     dx,ax           ; DX = size
        mov     ax,sp
        sub     ax,[___stacklow] ; AX = remaining
        cmp     ax,#0           ; fail if remaining < 0
        jl      .1
        cmp     ax,dx           ; fail if remaining < size
        jc      .1
        mov     ax,dx           ; OK to extend stack
        sub     sp,ax
        mov     ax,sp           ; AX = mem
        jmp     bx              ; return (compiler won't readjust stack)
.1:     xor     ax,ax
        jmp     bx

        .global stackcheck
stackcheck:
        pop     bx              ; ret address
        pop     ax              ; stack needed (ignored for now)
        jmp     bx              ; return (compiler won't readjust stack)

        .global asldiv
asldiv:                         ; l1 /= l2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of l1     (was push3)
        push    word [bp+8]     ; Push hi l2            (was push1)
        push    word [bp+6]     ; Push lo l2            (was push2)
        push    word [bx+2]     ; Push hi l1
        push    word [bx]       ; Push lo l1
        call    ldiv
        mov     bx,[bp+4]       ; Restore l1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global aslmod
aslmod:                         ; l1 %= l2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of l1     (was push3)
        push    word [bp+8]     ; Push hi l2            (was push1)
        push    word [bp+6]     ; Push lo l2            (was push2)
        push    word [bx+2]     ; Push hi l1
        push    word [bx]       ; Push lo l1
        call    lmod
        mov     bx,[bp+4]       ; Restore l1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global aslmul
aslmul:                         ; l1 *= l2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of l1     (was push3)
        push    word [bp+8]     ; Push hi l2            (was push1)
        push    word [bp+6]     ; Push lo l2            (was push2)
        push    word [bx+2]     ; Push hi l1
        push    word [bx]       ; Push lo l1
        call    lmul
        add     sp,#8
        mov     bx,[bp+4]       ; Restore l1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global aslshl
aslshl:                         ; l1 <<= l2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of l1     (was push3)
        push    word [bp+8]     ; Push hi l2            (was push1)
        push    word [bp+6]     ; Push lo l2            (was push2)
        push    word [bx+2]     ; Push hi l1
        push    word [bx]       ; Push lo l1
        call    lshl
        add     sp,#8
        mov     bx,[bp+4]       ; Restore l1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global aslshr
aslshr:                         ; l1 >>= l2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of l1     (was push3)
        push    word [bp+8]     ; Push hi l2            (was push1)
        push    word [bp+6]     ; Push lo l2            (was push2)
        push    word [bx+2]     ; Push hi l1
        push    word [bx]       ; Push lo l1
        call    lshr
        add     sp,#8
        mov     bx,[bp+4]       ; Restore l1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret


        .global asuldiv
asuldiv:                        ; u1 /= u2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of u1     (was push3)
        push    word [bp+8]     ; Push hi u2            (was push1)
        push    word [bp+6]     ; Push lo u2            (was push2)
        push    word [bx+2]     ; Push hi u1
        push    word [bx]       ; Push lo u1
        call    uldiv
        mov     bx,[bp+4]       ; Restore u1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global asilmod
asilmod:                        ; u1 %= u2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of u1     (was push3)
        push    word [bp+8]     ; Push hi u2            (was push1)
        push    word [bp+6]     ; Push lo u2            (was push2)
        push    word [bx+2]     ; Push hi u1
        push    word [bx]       ; Push lo u1
        call    ilmod
        mov     bx,[bp+4]       ; Restore u1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global asulmul
asulmul:                        ; u1 *= u2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of u1     (was push3)
        push    word [bp+8]     ; Push hi u2            (was push1)
        push    word [bp+6]     ; Push lo u2            (was push2)
        push    word [bx+2]     ; Push hi u1
        push    word [bx]       ; Push lo u1
        call    ulmul
        add     sp,#8
        mov     bx,[bp+4]       ; Restore u1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global asulshl
asulshl:                        ; u1 << u2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of u1     (was push3)
        push    word [bp+8]     ; Push hi u2            (was push1)
        push    word [bp+6]     ; Push lo u2            (was push2)
        push    word [bx+2]     ; Push hi u1
        push    word [bx]       ; Push lo u1
        call    ulshl
        add     sp,#8
        mov     bx,[bp+4]       ; Restore u1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret
        .global asulshr
asulshr:                        ; u1 >> u2
        push    bp
        mov     bp,sp
        push    bx
        mov     bx,[bp+4]       ; Get address of u1     (was push3)
        push    word [bp+8]     ; Push hi u2            (was push1)
        push    word [bp+6]     ; Push lo u2            (was push2)
        push    word [bx+2]     ; Push hi u1
        push    word [bx]       ; Push lo u1
        call    ulshr
        add     sp,#8
        mov     bx,[bp+4]       ; Restore u1 address
        mov     [bx+2],dx       ; Store result
        mov     [bx],ax
        pop     bx
        pop     bp
        ret


; Main 32-bit routines begin here:

        .global ldiv
ldiv:                           ; N_LDIV@
        pop    cx
        push   cs
        push   cx
                                ; LDIV@
        xor    cx,cx
        jmp    .L01
        .global uldiv
uldiv:                          ; N_LUDIV@
        pop    cx
        push   cs
        push   cx
                                ; F_LUDIV@
        mov    cx,#0001
        jmp    .L01
        .global lmod
lmod:                           ; N_LMOD@
        pop    cx
        push   cs
        push   cx
                                ; F_LMOD@
        mov    cx,#0002
        jmp    .L01
        .global ilmod
ilmod:                          ; N_LUMOD@
        pop    cx
        push   cs
        push   cx
                                ; LUMOD@
        mov    cx,#0003
.L01:
        push   bp
        push   si
        push   di
        mov    bp,sp
        mov    di,cx
        mov    ax,[bp+10]
        mov    dx,[bp+12]
        mov    bx,[bp+14]
        mov    cx,[bp+16]
        or     cx,cx
        jne    .L02
        or     dx,dx
        je     .L10
        or     bx,bx
        je     .L10
.L02:
        test   di,#0001
        jne    .L04
        or     dx,dx
        jns    .L03
        neg    dx
        neg    ax
        sbb    dx,#0000
        or     di,#0x000C
.L03:
        or     cx,cx
        jns    .L04
        neg    cx
        neg    bx
        sbb    cx,#0000
        xor    di,#0004
.L04:
        mov    bp,cx
        mov    cx,#0x0020
        push   di
        xor    di,di
        xor    si,si
.L05:
        shl    ax,#1
        rcl    dx,#1
        rcl    si,#1
        rcl    di,#1
        cmp    di,bp
        jb     .L07
        ja     .L06
        cmp    si,bx
        jb     .L07
.L06:
        sub    si,bx
        sbb    di,bp
        inc    ax
.L07:
        loop   .L05
        pop    bx
        test   bx,#0002
        je     .L08
        mov    ax,si
        mov    dx,di
        shr    bx,#1
.L08:
        test   bx,#0004
        je     .L09
        neg    dx
        neg    ax
        sbb    dx,#0000
.L09:
        pop    di
        pop    si
        pop    bp
        retf   8
.L10:
        div    bx
        test   di,#0002
        je     .L11
        xchg   dx,ax
.L11:
        xor    dx,dx
        jmp    .L09
        .global lshl
        .global ulshl
lshl:                           ; N_LXLSH@
ulshl:
                                ; r = a << b
        pop    bx
        push   cs
        push   bx

        push   bp
        mov    bp,sp

        push   cx               ; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]       ; pop loword(a)
        mov    dx, [bp+8]       ; pop hiword(a)
        mov    cx, [bp+10]      ; pop word(b)
        
                                ; LXLSH@
        cmp    cl,#0x10
        jnb    .L12
        mov    bx,ax
        shl    ax,cl
        shl    dx,cl
        neg    cl
        add    cl,#0x10
        shr    bx,cl
        or     dx,bx
        pop    cx
        pop    bp
        retf
.L12:
        sub    cl,#0x10
        xchg   dx,ax
        xor    ax,ax
        shl    dx,cl
        pop    cx
        pop    bp
        retf
        .global lshr
lshr:                           ; N_LXRSH@
                                ; r = a >> b
        pop    bx
        push   cs
        push   bx

        push   bp
        mov    bp,sp

        push   cx               ; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]       ; pop loword(a)
        mov    dx, [bp+8]       ; pop hiword(a)
        mov    cx, [bp+10]      ; pop word(b)
        
                                ; LXRSH@
        cmp    cl,#0x10
        jnb    .L13
        mov    bx,dx
        shr    ax,cl
        sar    dx,cl
        neg    cl
        add    cl,#0x10
        shl    bx,cl
        or     ax,bx
        pop    cx
        pop    bp
        retf
.L13:
        sub    cl,#0x10
        xchg   dx,ax
        cwd
        sar    ax,cl
        pop    cx
        pop    bp
        retf
        .global ulshr
ulshr:                          ; N_LXURSH@
                                ; r = a >> b
        pop    bx
        push   cs
        push   bx

        push   bp
        mov    bp,sp

        push   cx               ; C86 doesn't expect use of cx or bx

        mov    ax, [bp+6]       ; pop loword(a)
        mov    dx, [bp+8]       ; pop hiword(a)
        mov    cx, [bp+10]      ; pop word(b)
        
                                ; LXURSH@
        cmp    cl,#0x10
        jnb    .L14
        mov    bx,dx
        shr    ax,cl
        shr    dx,cl
        neg    cl
        add    cl,#0x10
        shl    bx,cl
        or     ax,bx
        pop    cx
        pop    bp
        retf
.L14:
        sub    cl,#0x10
        xchg   dx,ax
        xor    dx,dx
        shr    ax,cl
        pop    cx
        pop    bp
        retf
        .global lmul
        .global ulmul
lmul:                           ; N_LXMUL@
ulmul:
                                ; r = a * b
        push   bp
        push   si
        mov    bp,sp

        push   cx               ; C86 doesn't expect use of cx or bx
        push   bx

        mov    bx, [bp+6]       ; pop loword(a)
        mov    cx, [bp+8]       ; pop hiword(a)
        mov    ax, [bp+10]      ; pop loword(b)
        mov    dx, [bp+12]      ; pop hiword(b)
        
        xchg   si,ax
        xchg   dx,ax
        test   ax,ax
        je     .L15
        mul    bx
.L15:
        jcxz   .L16
        xchg   cx,ax
        mul    si
        add    ax,cx
.L16:
        xchg   si,ax
        mul    bx
        add    dx,si
        pop    bx
        pop    cx
        pop    si
        pop    bp
        ret
