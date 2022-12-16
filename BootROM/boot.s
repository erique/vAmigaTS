	NOLIST
		include	"hardware/custom.i"
		include	"hardware/cia.i"

ROM_START	equ $F80000
ROM_SIZE	equ $080000

_custom	equ $dff000
_ciaa	equ $bfe001

ENABLE_TRACE

TRACE	MACRO
	NOLIST
	IFD ENABLE_TRACE
		lea	.string\@(pc),a0
		lea	.next\@(pc),a5
		jmp	OutputDebugString
.string\@	dc.b	\1,$d,$a,0
		even
.next\@
	ELSE
		nop
	ENDC
	LIST
	ENDM

	LIST

	ORG	ROM_START
ROM:
		dc.w	$B007
RESET:		dc.w	$4EF9	; jmp
		dc.l	BOOT
		dc.b	"FPGAArcade Replay",0

	cnop	0,32

BOOT:
	TRACE	$1b
	TRACE	"[2JBOOT"
	
	TRACE	"Disable ROM overlay / Enable CHIP"
		clr.b	_ciaa+ciapra
		move.b	#(CIAF_OVERLAY|CIAF_LED),_ciaa+ciaddra

	TRACE	"Disable INT/DMA"
		lea.l	_custom,a4
		move.w	#$7fff,d0
		move.w	d0,intena(a4)
		move.w	d0,intreq(a4)
		move.w	d0,dmacon(a4)

	TRACE	"Enable BPL/COLOR"
		move.w	#$0200,bplcon0(a4)
		move.w	#$0000,bpldat(a4)
		move.w	#$000f,color(a4)

	TRACE	"Check RESET SSP/PC"

		move.l	$0.w,sp
	TRACE	"  SP LOW"
		cmp.l	#256*4,sp
		bls.b	.error
	TRACE	"  SP HI"
		cmp.l	#$80000,sp
		bhi.b	.error

		move.l	$4.w,a6
	TRACE	"  PC LOW"
		cmp.l	#256*4,a6
		bls.b	.error
	TRACE	"  PC HIGH"
		cmp.l	#$80000,a6
		bls.b	.start

.error
	TRACE	"ERROR!"

.loop		move.w	vhposr(a4),d0
		and.w	#$f37,d0
		move.w	d0,color(a4)
		moveq.l	#10,d1
.loop2		btst	#0,_ciaa
		dbf	d1,.loop2
		bra.b	.loop

.start
	TRACE	"JUMP to CHIP, RESET in a5"
		lea	Reset(pc),a5
		jmp	(a6)

		cnop	0,16

Reset:	TRACE	"RST/JMP"
		bra	.go
		cnop	0,16
.go		lea	ROM_START,a0	; 6
		addq.l	#2,a0		; 8
.rst		reset			; 2
		jmp	(a0)		; 2
.end

	ifne (.rst&$3)
	fail	"RESET instruction must be longword aligned"
	endc

OutputDebugString:
		move.w	#(3546895/115200),_custom+serper; 115200bps

.wait_tbe:	tst.w	_ciaa				; 1us delay
		move.w	_custom+serdatr,d0		; get serial status
		btst	#13,d0				; bit 13 = TBE (transmit buffer empty)
		beq.s	.wait_tbe

		move.w	#$100,d0			; set STOP bit
		or.b	(a0)+,d0			; get TX byte
		beq.s	.done				; zero-terminated

		move.w	d0,_custom+serdat		; word out
		bra.s	.wait_tbe			; wait for transmit done

.done:		jmp	(a5)				; "RTS"

EndOfBoot

Padding
	ds.b	ROM_SIZE-(EndOfBoot-ROM_START)-(ROM_END-AutoVectors),0

AutoVectors:
		dc.w	$18	; Vector 24 - Spurious (/VPA)
		dc.w	$19	; Vector 25 - Level 1  (/VPA)
		dc.w	$1a	; Vector 26 - Level 2  (/VPA)
		dc.w	$1b	; Vector 27 - Level 3  (/VPA)
		dc.w	$1c	; Vector 28 - Level 4  (/VPA)
		dc.w	$1d	; Vector 29 - Level 5  (/VPA)
		dc.w	$1e	; Vector 30 - Level 6  (/VPA)
		dc.w	$1f	; Vector 31 - Level 7  (/VPA)

ROM_END
