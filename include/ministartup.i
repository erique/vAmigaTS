; HUNK
; * AllocAbs() payload ORG address, using HUNK size
; * Copy payload
; * Tear down the system; all of it.
; * Move VBR to $0
; * INT7 break-out
; 
; RAM
; * Provide RESET PC
; * Setup super stack
; * Setup exception vectors
; * Jump to payload

; ROM
; * JMP $F80010
; * Disable OVR
; * Verify RAM payload
; * JMP RESET PC

	IFND	ROM

TRACE	MACRO
	ENDM

ENABLE_KPRINTF

MINISTARTUP
	include "kprintf.i"

	move.l	MINISTARTUP-8(pc),d0	; allocated size
	kprintf	"allocated %ld",d0
	subq.l	#4+4,d0		; minus size field + next hunk field
	kprintf	"code size %ld",d0
	lea	MINISTARTUP_END(pc),a0
	add.l	a0,d0
	lea	MINISTARTUP(pc),a1
	kprintf	"S %lx",a1
	sub.l	a1,d0


	move.l	$4.w,a6
	move.l	d0,d7
	move.l	#MAIN,a1
	kprintf	"trying %ld bytes at %lx",d0,a1
	jsr	-204(a6)
	kprintf	"returned %lx",d0
	tst.l	d0
	beq	.fail
	move.l	d0,a1
	move.l	d7,d1

	lea	MINISTARTUP_END(pc),a0
	move.l	#MAIN,a2

	kprintf	"SRC = %lx",a0
	kprintf	"DST = %lx",a2
	kprintf	"SIZE = %lx / %ld",d7,d7

	lsr	#1,d7
	bra.b	.copy
.loop	move.w	(a0)+,(a2)+
.copy	dbf	d7,.loop

	bsr	START
	move.l	d1,d0
	kprintf	"dealloc %ld bytes at %lx",d0,a1
	jmp	-210(a6)
.fail	kprintf	"failed to alloc"
	rts

	IF 1

INTENASET	= %1100000000100000
;		   ab-------cdefg--
;	a: SET/CLR Bit
;	b: Master Bit
;	c: Blitter Int
;	d: Vert Blank Int
;	e: Copper Int
;	f: IO Ports/Timers
;	g: Software Int

DMASET		= %1000001111100000
;		   a----bcdefghi--j
;	a: SET/CLR Bit
;	b: Blitter Priority
;	c: Enable DMA
;	d: Bit Plane DMA
;	e: Copper DMA
;	f: Blitter DMA
;	g: Sprite DMA
;	h: Disk DMA
;	i..j: Audio Channel 0-3

;	PRINTT
;	PRINTT	"MINI STARTUP BY STINGRAY/[S]CARAB^SCOOPEX"
;	PRINTT	"             .oO LAST CHANGE: THU, 2o-AUG-2oo5 Oo."
;	PRINTT


***************************************************
*** MACRO DEFINITION				***
***************************************************

WAITBLIT	MACRO
		tst.b	$02(a6)
.\@		btst	#6,$02(a6)
		bne.b	.\@
		ENDM
		

***************************************************
*** CLOSE DOWN SYSTEM - INIT PROGRAM		***
***************************************************

START	movem.l	d0-a6,-(a7)

	move.l	$4.w,a6
	jsr	-120(a6)
	lea	.VARS_HW(pc),a5
	lea	.GFXname(pc),a1
	moveq	#0,d0
	jsr	-552(a6)			; OpenLibrary()
	move.l	d0,.GFXbase-.VARS_HW(a5)
	beq	.END
	move.l	d0,a6
	move.l	34(a6),.OldView-.VARS_HW(a5)
	sub.l	a1,a1
	bsr.w	.DoView
	move.l	$26(a6),.OldCop1-.VARS_HW(a5)	; Store old CL 1
	move.l	$32(a6),.OldCop2-.VARS_HW(a5)	; Store old CL 2
	bsr	.GetVBR
	move.l	d0,.VBRptr-.VARS_HW(a5)
	move.l	d0,a0

	***	Store Custom Regs	***

	lea	$dff000,a6			; base address
	move.w	$10(a6),.ADK-.VARS_HW(a5)	; Store old ADKCON
	move.w	$1C(a6),.INTENA-.VARS_HW(a5)	; Store old INTENA
	move.w	$02(a6),.DMA-.VARS_HW(a5)	; Store old DMA
	move.w	#$7FFF,d0
	bsr	WaitRaster
	move.w	d0,$9A(a6)			; Disable Interrupts
	move.w	d0,$96(a6)			; Clear all DMA channels
	move.w	d0,$9C(a6)			; Clear all INT requests

	move.l	$6c(a0),.OldVBI-.VARS_HW(a5)
	lea	.NewVBI(pc),a1
	move.l	a1,$6c(a0)

	move.w	#INTENASET!$C000,$9A(a6)	; set Interrupts+ BIT 14/15
	move.w	#DMASET!$8200,$96(a6)		; set DMA	+ BIT 09/15

	move.w	#0,$106(a6)
	jsr	MAIN

	
***************************************************
*** Restore Sytem Parameter etc.		***
***************************************************

.END	lea	.VARS_HW(pc),a5
	lea	$dff000,a6
	clr.l	VBIptr-.VARS_HW(a5)

	move.w	#$8000,d0
	or.w	d0,.INTENA-.VARS_HW(a5)		; SET/CLR-Bit to 1
	or.w	d0,.DMA-.VARS_HW(a5)		; SET/CLR-Bit to 1
	or.w	d0,.ADK-.VARS_HW(a5)		; SET/CLR-Bit to 1
	subq.w	#1,d0
	bsr	WaitRaster
	move.w	d0,$9A(a6)			; Clear all INT bits
	move.w	d0,$96(a6)			; Clear all DMA channels
	move.w	d0,$9C(a6)			; Clear all INT requests

	move.l	.VBRptr(pc),a0
	move.l	.OldVBI(pc),$6c(a0)

	move.l	.OldCop1(pc),$80(a6)		; Restore old CL 1
	move.l	.OldCop2(pc),$84(a6)		; Restore old CL 2
	move.w	d0,$88(a6)			; start copper1
	move.w	.INTENA(pc),$9A(a6)		; Restore INTENA
	move.w	.DMA(pc),$96(a6)		; Restore DMAcon
	move.w	.ADK(pc),$9E(a6)		; Restore ADKcon

	move.l	.GFXbase(pc),a6
	move.l	.OldView(pc),a1			; restore old viewport
	bsr.b	.DoView

	move.l	a6,a1
	move.l	$4.w,a6
	jsr	-414(a6)			; Closelibrary()
	jsr	-126(a6)
	movem.l	(a7)+,d0-a6
	moveq	#0,d0
	rts


.DoView	jsr	-222(a6)			; LoadView()
	jsr	-270(a6)			; WaitTOF()
	jmp	-270(a6)


*******************************************
*** Get Address of the VBR		***
*******************************************

.GetVBR	move.l	a5,-(a7)
	moveq	#0,d0			; default at $0
	move.l	$4.w,a6
	btst	#0,296+1(a6)		; 68010+?
	beq.b	.is68k			; nope.
	lea	.getit(pc),a5
	jsr	-30(a6)			; SuperVisor()
.is68k	move.l	(a7)+,a5
	rts

.getit	movec   vbr,d0
	rte				; back to user state code
	

*******************************************
*** VERTICAL BLANK (VBI)		***
*******************************************

.NewVBI	movem.l	d0-a6,-(a7)
	move.l	VBIptr(pc),d0
	beq.b	.noVBI
	move.l	d0,a0
	jsr	(a0)
.noVBI	lea	$dff09c,a6
	moveq	#$20,d0
	move.w	d0,(a6)
	move.w	d0,(a6)			; twice to avoid a4k hw bug
	movem.l	(a7)+,d0-a6
	rte

*******************************************
*** DATA AREA		FAST		***
*******************************************

.VARS_HW
.GFXname	dc.b	'graphics.library',0,0
.GFXbase	dc.l	0
.OldView	dc.l	0
.OldCop1	dc.l	0
.OldCop2	dc.l	0
.VBRptr		dc.l	0
.OldVBI		dc.l	0
.ADK		dc.w	0
.INTENA		dc.w	0
.DMA		dc.w	0

VBIptr		dc.l	0

WaitRaster
	move.l	d0,-(a7)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	bne.b	.loop
	move.l	(a7)+,d0
	rts

WaitRasterEnd
	move.l	d0,-(a7)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	beq.b	.loop
	move.l	(a7)+,d0
	rts

	ENDC

MINISTARTUP_END
	ORG	$50000

	ELSE

	NOLIST
		include	"hardware/custom.i"
		include	"hardware/cia.i"

_custom	equ $dff000
_ciaa	equ $bfe001

ENABLE_TRACE

TRACE	MACRO
	NOLIST
	IFD ENABLE_TRACE
		lea	.string\@(pc),a0
		pea	.next\@(pc)
		bra	OutputDebugString
.string\@	dc.b	\1,$d,$a,0
		even
.next\@
	ELSE
		nop
	ENDC
	LIST
	ENDM

EXCEPTION	MACRO
		TRACE	\1
		bra	BlinkColor
		ENDM

	LIST

	ORG	$0

	dc.l	InitialSSP		; Vector 0
	dc.l	InitialPC		; Vector 1
	dc.l	BusError		; Vector 2
	dc.l	AddressError		; Vector 3
	dc.l	IllegalInstr		; Vector 4
	dc.l	ZeroDivide		; Vector 5
	dc.l	ChkInstr		; Vector 6
	dc.l	TrapVInstr		; Vector 7
	dc.l	PrivViol		; Vector 8
	dc.l	Trace			; Vector 9
	dc.l	LineA			; Vector 10
	dc.l	LineF			; Vector 11
	ds.l	24-12,$0		; Vector 12-23
	dc.l	Spurious		; Vector 24
	dc.l	Level1			; Vector 25
	dc.l	Level2			; Vector 26
	dc.l	Level3			; Vector 27
	dc.l	Level4			; Vector 28
	dc.l	Level5			; Vector 29
	dc.l	Level6			; Vector 30
	dc.l	Level7			; Vector 31
	dc.l	Trap0			; Vector 32
	dc.l	Trap1			; Vector 33
	dc.l	Trap2			; Vector 34
	dc.l	Trap3			; Vector 35
	dc.l	Trap4			; Vector 36
	dc.l	Trap5			; Vector 37
	dc.l	Trap6			; Vector 38
	dc.l	Trap7			; Vector 39
	dc.l	Trap8			; Vector 40
	dc.l	Trap9			; Vector 41
	dc.l	TrapA			; Vector 42
	dc.l	TrapB			; Vector 43
	dc.l	TrapC			; Vector 44
	dc.l	TrapD			; Vector 45
	dc.l	TrapE			; Vector 46
	dc.l	TrapF			; Vector 47
	ds.l	64-48,$0		; Vector 48-63
	ds.l	256-64,UserInterrupt	; Vector 255-64

	ifne *-256*4
	fail	"Exception Vector Table ERROR"
	endc

BusError	EXCEPTION	"BusError"
AddressError	EXCEPTION	"AddressError"
IllegalInstr	EXCEPTION	"IllegalInstr"
ZeroDivide	EXCEPTION	"ZeroDivide"
ChkInstr	EXCEPTION	"ChkInstr"
TrapVInstr	EXCEPTION	"TrapVInstr"
PrivViol	EXCEPTION	"PrivViol"
Trace		EXCEPTION	"Trace"
LineA		EXCEPTION	"LineA"
LineF		EXCEPTION	"LineF"
Spurious	EXCEPTION	"Spurious"
Level1		EXCEPTION	"Level1"
Level2		EXCEPTION	"Level2"
Level3		EXCEPTION	"Level3"
Level4		EXCEPTION	"Level4"
Level5		EXCEPTION	"Level5"
Level6		EXCEPTION	"Level6"
Level7		EXCEPTION	"Level7"
Trap0		EXCEPTION	"Trap0"
Trap1		EXCEPTION	"Trap1"
Trap2		EXCEPTION	"Trap2"
Trap3		EXCEPTION	"Trap3"
Trap4		EXCEPTION	"Trap4"
Trap5		EXCEPTION	"Trap5"
Trap6		EXCEPTION	"Trap6"
Trap7		EXCEPTION	"Trap7"
Trap8		EXCEPTION	"Trap8"
Trap9		EXCEPTION	"Trap9"
TrapA		EXCEPTION	"TrapA"
TrapB		EXCEPTION	"TrapB"
TrapC		EXCEPTION	"TrapC"
TrapD		EXCEPTION	"TrapD"
TrapE		EXCEPTION	"TrapE"
TrapF		EXCEPTION	"TrapF"
UserInterrupt	EXCEPTION	"UserInterrupt"


BlinkColor
	TRACE	"Disable INT/DMA"
		lea.l	_custom,a4
		move.w	#$7fff,d0
		move.w	d0,intena(a4)
		move.w	d0,intreq(a4)
		move.w	d0,dmacon(a4)

	TRACE	"Enable BPL/COLOR"
		move.w	#$0200,bplcon0(a4)
		move.w	#$0000,bpldat(a4)

		move.w	#$0f0f,d0
		move.w	#$f0ff,d1
.loop		eor.w	d1,d0
		rol.w	#4,d1
		move.w	d0,color(a4)
		moveq	#-1,d7
.wait		tst.w	_ciaa
		dbf	d7,.wait

		bra	.loop


OutputDebugString:
		move.w	#(3546895/115200),_custom+serper

.wait_tbe:	tst.w	_ciaa
		move.w	_custom+serdatr,d0
		btst	#13,d0
		beq.s	.wait_tbe

		move.w	#$100,d0
		or.b	(a0)+,d0
		beq.s	.done

		move.w	d0,_custom+serdat
		bra.s	.wait_tbe

.done:		rts


	ORG	$1000
InitialSSP

	ORG	$1800
InitialUSP

	ORG	$2000
InitialPC:
	TRACE	"INIT"
		move.l	a5,-(sp)

	TRACE	"Setup USP"

		lea.l	InitialUSP(pc),a0
		move.l	a0,usp

	TRACE	"About to drop SUPER"
		move.w	#0,sr	; going usermode

	TRACE	"JUMP to MAIN"
		jsr	MAIN

	TRACE	"RESET"
		move.l	InitialSSP-4(pc),$80.w
		trap	#0

		cnop	0,256

	ENDC