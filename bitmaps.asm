*****************************************************
* BITMAPS

* Cylinder walls
cylinderBitmap	
	fcb	$c5,$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca
	fcb	$c5,$80,$80,$80,$80,$80,$80,$80,$80,$ca

* Piston
pistonBitmap	
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$cf,$cf,$cf,$cf,$cf,$cf
	fcb	$cf,$cf,$80,$c5,$ca,$80,$cf,$cf
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80
	fcb	$80,$80,$80,$c5,$ca,$80,$80,$80

* Ignition in piston
fireBitmap
	fcb	$ff,$ff,$9f,$9f,$9f,$9f,$ff,$ff	
	fcb	$ff,$ff,$ff,$9f,$9f,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$bf,$ff,$ff,$ff,$ff,$ff,$ff,$bf	
	fcb	$bf,$bf,$ff,$ff,$ff,$ff,$bf,$bf	

* Light bitmap
lightBitmap
	fcb	$a5,$aa
	fcb	$af,$af
	fcb	$af,$af
	fcb	$a5,$aa

* Number bitmaps
digitLookup
	fdb	digit0,digit1,digit2,digit3,digit4
	fdb	digit5,digit6,digit7,digit8,digit9

digit0	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$8a XX..XX..
	fcb	$8a,$8a XX..XX..
	fcb	$8a,$8a XX..XX..
	fcb	$8f,$8a XXXXXX..

digit1	fcb	$85,$80 ..XX....
	fcb	$85,$80 ..XX....
	fcb	$85,$80 ..XX....
	fcb	$85,$80 ..XX....
	fcb	$85,$80 ..XX....

digit2	fcb	$8f,$8a XXXXXX..
	fcb	$80,$8a ....XX..
	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$80 XX......
	fcb	$8f,$8a XXXXXX..

digit3	fcb	$8f,$8a XXXXXX..
	fcb	$80,$8a ....XX..
	fcb	$85,$8a ..XXXX..
	fcb	$80,$8a ....XX..
	fcb	$8f,$8a XXXXXX..

digit4	fcb	$8a,$8a XX..XX..
	fcb	$8a,$8a XX..XX..
	fcb	$8f,$8a XXXXXX..
	fcb	$80,$8a ....XX..
	fcb	$80,$8a ....XX..

digit5	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$80 XX....
	fcb	$8f,$8a XXXXXX..
	fcb	$80,$8a ....XX..
	fcb	$8f,$8a XXXXXX..

digit6	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$80 XX......
	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$8a XX..XX..
	fcb	$8f,$8a XXXXXX..

digit7	fcb	$8f,$8a XXXXXX..
	fcb	$80,$8a ....XX..
	fcb	$80,$8a ....XX..
	fcb	$80,$8a ....XX..
	fcb	$80,$8a ....XX..

digit8	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$8a XX..XX..
	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$8a XX..XX..
	fcb	$8f,$8a XXXXXX..

digit9	fcb	$8f,$8a XXXXXX..
	fcb	$8a,$8a XX..XX..
	fcb	$8f,$8a XXXXXX..
	fcb	$80,$8a ....XX..
	fcb	$80,$8a ....XX..

* Character Bitmaps
charLookup
		fdb	char_cpy,char_A,char_B,char_C
		fdb	char_D,char_E,char_F,char_G
		fdb	char_H,char_I,char_J,char_K
		fdb	char_L,char_M,char_N,char_O
		fdb	char_P,char_Q,char_R,char_S
		fdb	char_T,char_U,char_V,char_W
		fdb	char_X,char_Y,char_Z,char_mns
		fdb	char_exc,char_qst,char_asp,char_spc

char_cpy	fcb	$85,$8f,$8a	..XXXXXXXX..
		fcb	$8a,$80,$85	XX........XX
		fcb	$8a,$8f,$85	XX..XXXX..XX
		fcb	$8a,$8a,$85	XX..XX....XX
		fcb	$8a,$8f,$85	XX..XXXX..XX
		fcb	$8a,$80,$85	XX........XX
		fcb	$85,$8f,$8a	..XXXXXXXX..

char_A		fcb	$80,$8a,$80	....XX......
		fcb	$85,$85,$80	..XX..XX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..

char_B		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$80	XXXXXXXX....

char_C		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$8f,$80	..XXXXXX....

char_D		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$80	XXXXXXXX....

char_E		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8f,$8a,$80	XXXXXX......
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8f,$8f,$8a	XXXXXXXXXX..

char_F		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8f,$8a,$80	XXXXXX......
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........

char_G		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$85,$8a	XX....XXXX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$8f,$80	..XXXXXX....

char_H		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..

char_I		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$85,$8f,$80	..XXXXXX....

char_J		fcb	$80,$80,$8a	........XX..
		fcb	$80,$80,$8a	........XX..
		fcb	$80,$80,$8a	........XX..
		fcb	$80,$80,$8a	........XX..
		fcb	$80,$80,$8a	........XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$8f,$80	..XXXXXX....

char_K		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$85,$80	XX....XX....
		fcb	$8a,$8a,$80	XX..XX......
		fcb	$8f,$80,$80	XXXX........
		fcb	$8a,$8a,$80	XX..XX......
		fcb	$8a,$85,$80	XX....XX....
		fcb	$8a,$80,$8a	XX......XX..

char_L		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8f,$8f,$80	XXXXXXXXXX..

char_M		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$85,$8a	XXXX..XXXX..
		fcb	$8a,$8a,$8a	XX..XX..XX..
		fcb	$8a,$8a,$8a	XX..XX..XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..

char_N		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$80,$8a	XXXX....XX..
		fcb	$8a,$8a,$8a	XX..XX..XX..
		fcb	$8a,$85,$8a	XX....XXXX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..

char_O		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$8f,$80	..XXXXXX....

char_P		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........

char_Q		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$8a,$8a	XX..XX..XX..
		fcb	$8a,$85,$80	XX....XX....
		fcb	$85,$8a,$8a	..XXXX..XX..

char_R		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8f,$8f,$80	XXXXXXXX....
		fcb	$8a,$8a,$80	XX..XX......
		fcb	$8a,$85,$80	XX....XX....
		fcb	$8a,$80,$8a	XX......XX..

char_S		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$80	xx..........
		fcb	$85,$8f,$80	..XXXXXX....
		fcb	$80,$80,$8a	........XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$8f,$80	..XXXXXX....

char_T		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......

char_U		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$8f,$80	..XXXXXX....

char_V		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$85,$80	..XX..XX....
		fcb	$85,$85,$80	..XX..XX....
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......

char_W		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$8a,$8a	XX..XX..XX..
		fcb	$8f,$85,$8a	XXXX..XXXX..
		fcb	$8a,$80,$8a	XX......XX..

char_X		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$85,$80	..XX..XX....
		fcb	$80,$8a,$80	....XX......
		fcb	$85,$85,$80	..XX..XX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..

char_Y		fcb	$8a,$80,$8a	XX......XX..
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$85,$85,$80	..XX..XX....
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......

char_Z		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$80,$80,$8a	........XX..
		fcb	$80,$85,$80	......XX....
		fcb	$80,$8a,$80	....XX......
		fcb	$85,$80,$80	..XX........
		fcb	$8a,$80,$80	XX..........
		fcb	$8f,$8f,$8a	XXXXXXXXXX..

char_mns	fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$8f,$8f,$8a	XXXXXXXXXX..
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............

char_exc	fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$8a,$80,$80	XX..........
		fcb	$80,$80,$80	............
		fcb	$8a,$80,$80	XX..........


char_qst	fcb	$85,$8f,$80	..XXXXXX....
		fcb	$8a,$80,$8a	XX......XX..
		fcb	$80,$80,$8a	........XX..
		fcb	$80,$85,$80	......XX....
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$80,$80	............
		fcb	$80,$8a,$80	....XX......

char_asp	fcb	$80,$8a,$80	....XX......
		fcb	$80,$8a,$80	....XX......
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............

char_spc	fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
		fcb	$80,$80,$80	............
	