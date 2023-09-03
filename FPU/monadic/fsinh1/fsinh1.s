    include "../../fpureg.i"
	include "../../arith1.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    fsinh
    rte

info: 
    dc.b    'FSINH1', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 2
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $0C,$00,$00,$00  ; 4
    dc.b    $3F,$FF,$00,$00,  $96,$6C,$FE,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $BF,$FF,$00,$00,  $96,$6C,$FE,$00  ; 7
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 8
    dc.b    $40,$00,$00,$00,  $E8,$1E,$7B,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $C0,$00,$00,$00,  $E8,$1E,$7B,$00  ; 11
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 12
    dc.b    $3F,$FE,$00,$00,  $85,$66,$80,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $BF,$FE,$00,$00,  $85,$66,$80,$00  ; 15
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 16
    dc.b    $3F,$FB,$00,$00,  $CD,$24,$3A,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 18
    dc.b    $BF,$FB,$00,$00,  $CD,$24,$3A,$00  ; 19
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 20
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 22
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $0A,$00,$12,$48  ; 24
