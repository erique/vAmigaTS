    include "../../fpureg.i"
	include "../../arith1.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    fcosh
    rte

info: 
    dc.b    'FCOSH1', 0
    even 

expected:
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $3F,$FF,$00,$00,  $C5,$83,$AB,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $3F,$FF,$00,$00,  $C5,$83,$AB,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 8
    dc.b    $40,$00,$00,$00,  $F0,$C7,$D0,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $40,$00,$00,$00,  $F0,$C7,$D0,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 12
    dc.b    $3F,$FF,$00,$00,  $90,$56,$0C,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $3F,$FF,$00,$00,  $90,$56,$0C,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 16
    dc.b    $3F,$FF,$00,$00,  $80,$A3,$FA,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 18
    dc.b    $3F,$FF,$00,$00,  $80,$A3,$FA,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 20
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 22
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 24
