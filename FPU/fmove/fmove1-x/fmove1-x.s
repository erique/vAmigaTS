	include "../../fpureg.i"

trap0:

    movem.l d0/d1,-(a7) 

    lea     values,a2 
    moveq   #20,d1      ; Loop counter
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR
    add     #$10,d0

    ; Load value into floating-point register and read it back
    fmovecr #$00,FP0
    fmove.x FP0,(a2)

    add     #16,a2

    dbra    d1,.loop

    movem.l (a7)+,d0/d1
    rte

info: 
    dc.b    'FMOVE1-X', 0
    even 

expected:
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 1
    dc.b    $21,$68,$C2,$35,  $00,$00,$00,$00  ; 2
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 3
    dc.b    $21,$68,$C2,$34,  $00,$00,$00,$00  ; 4
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 5
    dc.b    $21,$68,$C2,$34,  $00,$00,$00,$00  ; 6
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 7
    dc.b    $21,$68,$C2,$35,  $00,$00,$00,$00  ; 8
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DB,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DB,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 17
    dc.b    $21,$68,$C0,$00,  $00,$00,$00,$00  ; 18
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 19
    dc.b    $21,$68,$C0,$00,  $00,$00,$00,$00  ; 20
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 21
    dc.b    $21,$68,$C0,$00,  $00,$00,$00,$00  ; 22
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 23
    dc.b    $21,$68,$C8,$00,  $00,$00,$00,$00  ; 24
