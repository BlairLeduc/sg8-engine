* Simple 2 cylinder 1-stroke engine :)
*
* Copyright © 2020 Blair Leduc
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.

	nam	animatesg8

	org	$3000

row	rmb	1
cycle	rmb	1

* pages
* 1 -> $0e00-$15ff
* 2 -> $1600-$1dff
* 3 -> $1e00-$25ff
* 4 -> $2600-$2dff

page1	equ	$0e00
page2	equ	$1600
page3	equ	$1e00
page4	equ	$2600
pgend	equ	$2e00

cyllft	equ	$0203
cylrgt	equ	$0213
pstlft	equ	$0224
pstrgt	equ	$0234

ppostop	equ	$0100
pposmid	equ	$0200
pposbot	equ	$0300

* set up
start	orcc	#$50	turn off interrupts

	lda	$ff22	semigraphics 8
	anda	#$7
	sta	$ff22
	sta	$ffc4
	sta	$ffc3
	sta	$ffc0
			* show page one
	sta	$ffc7	1 -> $0200
	sta	$ffc9	1 -> $0400
	sta	$ffcb	1 -> $0800
	sta	$ffcc	0 -> $1000
	sta	$ffce	0 -> $2000
	sta	$ffd0	0 -> $4000
	sta	$ffd2	0 -> $8000

	lda	$ff01	select sound out
	anda	#$f7	reset mux bit
	sta	$ff01
	lda	$ff03	select sount out
	anda	#$f7	reset mux bit
	sta	$ff03
	lda	$ff23	get PIA
	ora	#8	get 6-bit sound enable
	sta	$ff23

* clear all pages $0600-$2600
	lda	#$80
	ldb	#$80
	ldx	#page1	start of page memory
clrloop	std	,x++	clear graphics area
	cmpx	#pgend	for four pages of memory
	blo	clrloop

* draw cylinder in each page of memory
	ldx	#page1+cyllft
	lbsr	cyl	1st page - left
	ldx	#page1+cylrgt
	lbsr	cyl	1st page - right
	ldx	#page2+cyllft
	lbsr	cyl	2nd page - left
	ldx	#page2+cylrgt
	lbsr	cyl	2nd page - right
	ldx	#page3+cyllft
	lbsr	cyl	3rd page - left
	ldx	#page3+cylrgt
	lbsr	cyl	3rd page - right
	ldx	#page4+cyllft
	lbsr	cyl	4th page - left
	ldx	#page4+cylrgt
	lbsr	cyl	4th page - right

* draw piston in each page of memory
	ldx	#page1+pstlft+pposbot
	lbsr	pst	1st page - left
	ldx	#page1+pstrgt+ppostop
	lbsr	pst	1st page - right
	ldx	#page1+pstrgt
	lbsr	fire	1st page - right
	ldx	#page2+pstlft+pposmid
	lbsr	pst	2nd page - left
	ldx	#page2+pstrgt+pposmid
	lbsr	pst	2nd page - right
	ldx	#page3+pstlft+ppostop
	lbsr	pst	3rd page - left
	ldx	#page3+pstlft
	lbsr	fire	3rd page - left
	ldx	#page3+pstrgt+pposbot
	lbsr	pst	3rd page - right
	ldx	#page4+pstlft+pposmid
	lbsr	pst	4th page - left
	ldx	#page4+pstrgt+pposmid
	lbsr	pst	4th page - right


* change display pages and test for X
again	lbsr	bang	... and bang
	sta	$ffca
	sta	$ffcd	
	lbsr	delay	show 2nd page and wait
	sta	$ffcb
	lbsr	bang	show 3rd page and bang
	sta	$ffcf
	sta	$ffcc
	sta	$ffca
	lbsr	delay	show 4th page and wait
	lda	#$fe	check for X key press
	sta	$ff02
	lda	$ff00
	cmpa	#$f7
	beq	tobasic	if X pressed quit
	sta	$ffce	
	sta	$ffcb	show page 1
	bra	again

* go to basic?
tobasic	clra
	sta	$ff22	return to text mode
	sta	$ffc0
	sta	$ffc6	show text page
	sta	$ffcc
	sta	$ffc9
	andcc	#$af	enable interrupts
	rts

* draw a cylinder
cyl	lda	#35
	sta	row
	ldy	#cyltbl
cdown	ldb	#10
cright	lda	,y+
	sta	,x+
	decb
	bne	cright
	leax	$16,x
	dec	row
	bne	cdown
	rts

* Draw a piston
pst	lda	#23
	sta	row
	ldy	#psttbl
pdown	ldb	#8
pright	lda	,y+
	sta	,x+
	decb
	bne	pright
	leax	$18,x
	dec	row
	bne	pdown
	rts

* draw ignition
fire	lda	#8
	sta	row
	ldy	#firetbl
fdown	ldb	#8
fright	lda	,y+
	sta	,x+
	decb
	bne	fright
	leax	$18,x
	dec	row
	bne	fdown
	rts

* delay
delay	ldx	#$2000
count	nop
	nop
	nop
	leax	-1,x
	bne	count
	rts

bang	ldy	#$2	count (repeat)
bng010	ldx	#$8000	start address for sound data
bng020	lda	,x+	
	anda	#$fc	reset 2 LS bits
	sta	$ff20	output
	bsr	bng030	delay
	cmpx	#$8060
	bne	bng020	loop if not end
	leay	-1,y	dec count
	bne	bng010	repeat if not done
	rts
bng030	lda	#$80	delay
bng040	deca
	bne	bng040
	rts



cyltbl	
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

psttbl	
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

firetbl
	fcb	$ff,$ff,$9f,$9f,$9f,$9f,$ff,$ff	
	fcb	$ff,$ff,$ff,$9f,$9f,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$bf,$ff,$ff,$ff,$ff,$ff,$ff,$bf	
	fcb	$bf,$bf,$ff,$ff,$ff,$ff,$bf,$bf	

	end start