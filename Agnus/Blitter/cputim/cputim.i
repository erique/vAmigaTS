	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

	IFND BLTSIZE1
BLTSIZE1 = $0102
BLTSIZE2 = $00c3
BLTSIZE3 = $0142
BLTSIZE4 = $02c1
BLTSIZE5 = $0182
BLTSIZE6 = $0341
	ENDC

MAIN:
	; Load OCS base address
	lea     CUSTOM,a1
	lea     CUSTOM,a6

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Set up playfield
	move.w  #$2C81,DIWSTRT(a1)
	move.w	#$572C,DIWSTOP(a1)
	move.w	#$0,BPL1MOD(a1)
	move.w	#$0,BPL2MOD(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3 
 	move.l	a3,LVL4_INT_VECTOR
	lea	    irq5(pc),a3 
 	move.l	a3,LVL5_INT_VECTOR
	lea	    irq6(pc),a3 
 	move.l	a3,LVL6_INT_VECTOR

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

	; Enable interrupts
	move.w	#$E89C,INTENA(a1)

.mainLoop:

	jsr     synccpu
	jsr     prepareblit
	bra.s	.mainLoop

prepareblit:	
	movem.l d0-a6,-(sp)
	bsr     blitWait
	move.w  #BLIT_BLTCON1,d0
	btst    #0,d0
	bne     .prepareline

	; Prepare the copy Bliter
	move.w  #$44B,COLOR00(a1)
	; BLTCON0 is written by the Copper
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)   
	move.w  #0,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #0,BLTCMOD(a1)
	move.w  #0,BLTDMOD(a1)
	move.l  #spare,BLTAPTH(a1)	 
	move.l  #spare,BLTBPTH(a1)	
	move.l  #spare,BLTCPTH(a1)
	move.l  #spare,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

.prepareline:
	; Prepare the line Blitter
	move.w  #$4B4,COLOR00(a1)
	; BLTCON0 is written by the Copper
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #$ABCA,BLTCON0(a1)
	move.w  #$8000,BLTADAT(a1)
	move.l  #spare,BLTBPTH(a1)	
	move.l  #spare,BLTCPTH(a1)
	move.l  #spare,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

irq1:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #BLTSIZE1,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #BLTSIZE2,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq3:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #BLTSIZE3,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #BLTSIZE4,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #BLTSIZE5,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #BLTSIZE6,BLTSIZE(a1)
	move.w  #$FF0,COLOR00(a1)
	rte

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached a certain scanline
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$2000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq   #10,d2
.adjust:
    dbra    d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)
	rts

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

copper:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$D0
	dc.w    BPLCON0, (0<<12)|$200

    ;
    ; Section 1
	;

  	dc.w    $4039, $FFFE
	include "../copperline.i"
	dc.w    BLTCON0,ABCD1<<8           

	dc.w	$4219,$FFFE
	dc.w    INTREQ, $8004                ; Level 1 interrupt
	dc.w    $4200|COLUMN1, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $4200|COLUMN1, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$4419, $FFFE  
	dc.w    INTREQ, $8008                ; Level 2 interrupt
	dc.w    $4400|COLUMN1, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $4400|COLUMN1, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$4619, $FFFE  
	dc.w    INTREQ, $8010                ; Level 3 interrupt
	dc.w    $4600|COLUMN1, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $4600|COLUMN1, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$4819, $FFFE  
	dc.w    INTREQ, $8080                ; Level 4 interrupt
	dc.w    $4800|COLUMN1, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $4800|COLUMN1, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$4A19, $FFFE  
	dc.w    INTREQ, $8800                ; Level 5 interrupt
	dc.w    $4A00|COLUMN1, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $4A00|COLUMN1, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$4C19, $FFFE  
	dc.w    INTREQ, $A000                ; Level 6 interrupt
	dc.w    $4C00|COLUMN1, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $4C00|COLUMN1, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

    ;
    ; Section 2
	;

  	dc.w    $5039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD2<<8           

	dc.w	$5219,$FFFE
	dc.w    INTREQ, $8004                ; Level 1 interrupt
	dc.w    $5200|COLUMN2, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $5200|COLUMN2, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$5419, $FFFE  
	dc.w    INTREQ, $8008                ; Level 2 interrupt
	dc.w    $5400|COLUMN2, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $5400|COLUMN2, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$5619, $FFFE  
	dc.w    INTREQ, $8010                ; Level 3 interrupt
	dc.w    $5600|COLUMN2, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $5600|COLUMN2, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$5819, $FFFE  
	dc.w    INTREQ, $8080                ; Level 4 interrupt
	dc.w    $5800|COLUMN2, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $5800|COLUMN2, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$5A19, $FFFE  
	dc.w    INTREQ, $8800                ; Level 5 interrupt
	dc.w    $5A00|COLUMN2, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $5A00|COLUMN2, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$5C19, $FFFE  
	dc.w    INTREQ, $A000                ; Level 6 interrupt
	dc.w    $5C00|COLUMN2, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $5C00|COLUMN2, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

  	;
    ; Section 3
	;

  	dc.w    $6039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD3<<8           

	dc.w	$6219,$FFFE
	dc.w    INTREQ, $8004        ; Level 1 interrupt
	dc.w    $6200|COLUMN3, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $6200|COLUMN3, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$6419, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt
	dc.w    $6400|COLUMN3, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $6400|COLUMN3, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$6619, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt
	dc.w    $6600|COLUMN3, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $6600|COLUMN3, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$6819, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt
	dc.w    $6800|COLUMN3, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $6800|COLUMN3, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$6A19, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt
	dc.w    $6A00|COLUMN3, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $6A00|COLUMN3, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$6C19, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt
	dc.w    $6C00|COLUMN3, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $6C00|COLUMN3, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

 	;
    ; Section 4
	;

  	dc.w    $7039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD4<<8           

	dc.w	$7219,$FFFE
	dc.w    INTREQ, $8004        ; Level 1 interrupt
	dc.w    $7200|COLUMN4, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $7200|COLUMN4, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$7419, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt
	dc.w    $7400|COLUMN4, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $7400|COLUMN4, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$7619, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt
	dc.w    $7600|COLUMN4, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $7600|COLUMN4, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$7819, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt
	dc.w    $7800|COLUMN4, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $7800|COLUMN4, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$7A19, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt
	dc.w    $7A00|COLUMN4, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $7A00|COLUMN4, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$7C19, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt
	dc.w    $7C00|COLUMN4, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $7C00|COLUMN4, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	;
    ; Section 5
	;

  	dc.w    $8039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD5<<8           

	dc.w	$8219,$FFFE
	dc.w    INTREQ, $8004        ; Level 1 interrupt
	dc.w    $8200|COLUMN5, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $8200|COLUMN5, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$8419, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt
	dc.w    $8400|COLUMN5, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $8400|COLUMN5, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$8619, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt
	dc.w    $8600|COLUMN5, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $8600|COLUMN5, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$8819, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt
	dc.w    $8800|COLUMN5, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $8800|COLUMN5, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$8A19, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt
	dc.w    $8A00|COLUMN5, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $8A00|COLUMN5, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$8C19, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt
	dc.w    $8C00|COLUMN5, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $8C00|COLUMN5, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	;
    ; Section 6
	;

  	dc.w    $9039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD6<<8           

	dc.w	$9219,$FFFE
	dc.w    INTREQ, $8004           ; Level 1 interrupt
	dc.w    $9200|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $9200|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$9419, $FFFE  
	dc.w    INTREQ, $8008           ; Level 2 interrupt
	dc.w    $9400|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $9400|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$9619, $FFFE  
	dc.w    INTREQ, $8010           ; Level 3 interrupt
	dc.w    $9600|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $9600|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$9819, $FFFE  
	dc.w    INTREQ, $8080           ; Level 4 interrupt
	dc.w    $9800|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $9800|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$9A19, $FFFE  
	dc.w    INTREQ, $8800           ; Level 5 interrupt
	dc.w    $9A00|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $9A00|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$9C19, $FFFE  
	dc.w    INTREQ, $A000           ; Level 6 interrupt
	dc.w    $9C00|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $9C00|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

  	;
    ; Section 7
    ;

  	dc.w    $A039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD7<<8           

	dc.w	$A219,$FFFE
	dc.w    INTREQ, $8004        ; Level 1 interrupt
	dc.w    $A200|COLUMN7, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $A200|COLUMN7, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$A419, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt
	dc.w    $A400|COLUMN7, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $A400|COLUMN7, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$A619, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt
	dc.w    $A600|COLUMN7, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $A600|COLUMN7, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$A819, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt
	dc.w    $A800|COLUMN7, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $A800|COLUMN7, $7FFE         ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$AA19, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt
	dc.w    $AA00|COLUMN7, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $AA00|COLUMN7, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$AC19, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt
	dc.w    $AC00|COLUMN7, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $AC00|COLUMN7, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	;
    ; Section 8
	;

  	dc.w    $B039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BLTCON0,ABCD8<<8           

	dc.w	$B219,$FFFE
	dc.w    INTREQ, $8004           ; Level 1 interrupt
	dc.w    $B200|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $B200|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$B419, $FFFE  
	dc.w    INTREQ, $8008           ; Level 2 interrupt
	dc.w    $B400|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $B400|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$B619, $FFFE  
	dc.w    INTREQ, $8010           ; Level 3 interrupt
	dc.w    $B600|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $B600|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$B819, $FFFE  
	dc.w    INTREQ, $8080           ; Level 4 interrupt
	dc.w    $B800|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $B800|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$BA19, $FFFE  
	dc.w    INTREQ, $8800           ; Level 5 interrupt
	dc.w    $BA00|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $BA00|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	dc.w	$BC19, $FFFE  
	dc.w    INTREQ, $A000           ; Level 6 interrupt
	dc.w    $BC00|COLUMN6, $FFFE 
	dc.w	COLOR00, $F00
	dc.w    $BC00|COLUMN6, $7FFE     ; Wait for Blitter
	dc.w	COLOR00, $000

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe
spare:
	ds.w    1024,$00
bitplanes:
	ds.b    32768,$00
