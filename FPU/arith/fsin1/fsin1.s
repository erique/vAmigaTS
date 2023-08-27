    include "../../fpureg.i"
	include "../../arith1.i"

trap0:
    fmove   #$00,FPCR
    TEST    fsin
    rte

info: 
    dc.b    'FSIN1', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 2
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $0C,$00,$00,$00  ; 4
    dc.b    $3F,$FE,$00,$00,  $D7,$6A,$A4,$78  ; 5
    dc.b    $48,$67,$70,$0F,  $00,$00,$02,$08  ; 6
    dc.b    $BF,$FE,$00,$00,  $D7,$6A,$A4,$78  ; 7
    dc.b    $48,$67,$70,$0F,  $08,$00,$02,$08  ; 8
    dc.b    $3F,$F9,$00,$00,  $AB,$4E,$40,$46  ; 9
    dc.b    $4D,$A8,$35,$9B,  $00,$00,$02,$08  ; 10
    dc.b    $BF,$F9,$00,$00,  $AB,$4E,$40,$46  ; 11
    dc.b    $4D,$A8,$35,$9B,  $08,$00,$02,$08  ; 12
    dc.b    $BF,$BF,$00,$00,  $80,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 14
    dc.b    $3F,$BF,$00,$00,  $80,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 16
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 17
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 18
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 19
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 20
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$88  ; 22
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 24
