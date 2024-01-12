OFFSET              equ $02

WRITE MACRO
	dc.w 	\1,$FFFE
	dc.w    \2,\3
	dc.w	COLOR00, $F00
	dc.w 	\1+$0090,$FFFE
	dc.w	COLOR00, $000
	ENDM 

PAYLOAD	MACRO
	; Write old VSTSTRT trigger values into SPRxPOS (HSTRT differs)
	WRITE	$4721+OFFSET,SPR0POS,$3048
	WRITE	$5721+OFFSET,SPR1POS,$4058
	WRITE	$6721+OFFSET,SPR2POS,$5068
	WRITE	$7721+OFFSET,SPR3POS,$6078
	WRITE	$8721+OFFSET,SPR4POS,$7088
	WRITE	$9721+OFFSET,SPR5POS,$8098
	WRITE	$A721+OFFSET,SPR6POS,$90A8
	WRITE	$B721+OFFSET,SPR7POS,$A0B8
	ENDM

	include "../interfere.i"