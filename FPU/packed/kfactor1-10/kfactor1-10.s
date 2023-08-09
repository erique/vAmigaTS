	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    moveq   #0,d0       ; k-factor
    fmove.l #$10,FPCR   ; Precision and rounding mode

    lea     values,a2   ; Result storage
    moveq   #11,d1      ; Loop counter (12 iterations)
    fmovecr #$00,FP1    ; Pi

.loop:

    fmove.p FP1,(a2)+{d0}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'KFACTOR1-10', 0
    even 

expected:
    dc.b    $00,$00,$00,$03,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 2
    dc.b    $00,$00,$00,$03,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 4
    dc.b    $00,$00,$00,$03,  $10,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $00,$00,$00,$03,  $14,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 8
    dc.b    $00,$00,$00,$03,  $14,$10,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $00,$00,$00,$03,  $14,$15,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 12
    dc.b    $00,$00,$00,$03,  $14,$15,$90,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 16
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$60  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 18
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$65  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 20
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$65  ; 21
    dc.b    $30,$00,$00,$00,  $00,$00,$02,$08  ; 22
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$65  ; 23
    dc.b    $35,$00,$00,$00,  $00,$00,$02,$08  ; 24
