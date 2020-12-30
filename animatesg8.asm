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
orig	equ	$2000

	org	orig

irqvec	equ	$010c

stack	rmb	2	store stack location for basic (must be first here)
pgreq	rmb	1	page switch request
irqfps	rmb	1
irqovr	rmb	1
fps	rmb	1
fpscnt	rmb	1

* Memory map
* <-$0dff     System Memory
* $0e00-$1dff Video Memory (pages)
*             1 -> $0e00-$15ff (2K)
*             2 -> $1600-$1dff (2K)
* $1e00-$2000 Stack (512 bytes)
* $2000->     Program and Data

* Valid FPS limits: 60, 30, 20, 15, 12, 10, 8, 7, 6, ...
fpslmt	equ	20
fpsrst	equ	(60/fpslmt)

psize	equ	$0800	size of a page (2K for SG8)
page1	equ	$0e00	start of graphics memory
page2	equ	page1+psize	


cyllft	equ	$0203	position of the left cylinder from start of page
cylrgt	equ	$0213	position of the right cylnder
pstlft	equ	$0224	postiion of the left piston
pstrgt	equ	$0234	position of the right piston

ppostop	equ	$0100	offset for the piston in top position
pposmid	equ	$0200	offset for the piston in middle position
pposbot	equ	$0300	offset for the piston in bottom position

* set up
start	orcc	#$50	turn off IRQ and FIRQ
	sts	stack	save stack for basic
	lds	orig	set stack to our org
	lda	#$7e	jmp op code
	sta	irqvec	set the IRQ vector
	ldy	#scrint
	sty	irqvec+1
	lda	$ff03	read CRB
	ora	#$05	
	sta	$ff03
	lda	$ff02	clear flag

	lda	$ff22	set up semigraphics 8
	anda	#$7
	sta	$ff22
	sta	$ffc4
	sta	$ffc3
	sta	$ffc0
			* show page one
	sta	$ffc7	1 -> $0200
	sta	$ffc9	1 -> $0400
	sta	$ffcb	1 -> $0800 (page2 = 0)
	sta	$ffcc	0 -> $1000 (page2 = 1)
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

	lda	#1
	sta	pgreq

	clr	irqclk	show time since start
	clr	irqfps	show fps
	clr	fps
	lda	#fpsrst
	sta	fpscnt

	andcc	#$ef	enable IRQ (FIRQ disabled)

* clear all pages
	ldd	#$8080
	ldx	#page1	start of page memory
clrloop	std	,x++	clear graphics area
	cmpx	#page1+2*psize
	blo	clrloop

	clra
	clrb
	sta	cycle
	sta	sound
	std	clock
	std	clock+2
	ldx	#page1
	stx	page
* main loop
main
	lda	#1
	sta	irqovr

	* run sound for shown page
sndeffects
	lda	sound
	beq	draw
	lbsr	bang	... and bang for shown page

	* draw page content on hidden page
draw
drwclk
	lda	#$60	purple
	ldb	#2	two pairs of digits
	ldx	page
	leax	24,x	top right
	ldu	#clock
	lbsr	prtbcd

drwcyl
	ldx	page
	leax	cyllft,x
	lbsr	cyl	draw left cylinder
	ldx	page
	leax	cylrgt,x
	lbsr	cyl	draw right cylinder
cycrgt
	lda	cycle
	cmpa	#0
	bne	cyclft
	ldx	page
	leax	pstlft+pposbot,x
	lbsr	pst	draw left piston
	ldx	page
	leax	pstrgt+ppostop,x
	lbsr	pst	draw right piston
	ldx	page
	leax	pstrgt,x
	lbsr	fire	draw right ignition
	lda	#1	bang
	sta	sound
	bra	cycnxt
cyclft
	lda	cycle
	cmpa	#2
	bne	cycmid
	ldx	page
	leax	pstlft+ppostop,x
	lbsr	pst	draw left piston
	ldx	page
	leax	pstrgt+pposbot,x
	lbsr	pst	draw right piston
	ldx	page
	leax	pstlft,x
	lbsr	fire	draw left ignition
	lda	#1	bang
	sta	sound
	bra	cycnxt
cycmid
	ldx	page
	leax	pstlft+pposmid,x
	lbsr	pst	draw left piston
	ldx	page
	leax	pstrgt+pposmid,x
	lbsr	pst	draw right piston
	clr	sound	no bang
cycnxt	lda	cycle
	inca
	sta	cycle
	cmpa	#4
	blo	mainend
	clr	cycle
mainend
	lbsr	isdone	check if we are to quit

drwfps	lda	irqovr
	bne	fps010
	lda	#$30	red
	bne	fps020
fps010	lda	#$00	green
fps020	ldb	#1	two pairs of digits
	ldx	page
	leax	psize-(5*32)-18,x	bottom middle
	ldu	#fps
	lbsr	prtbcd


	* switch to other page for double buffering
dblbuf
	ldd	#page1
	cmpd	page
	beq	mainp2
mainp1	lda	#2
	lbsr	switch	show page 2
	ldx	#page1
	stx	page	start drawing on page 1
	lda	#$80
	ldb	#$80
clrp1	std	,x++	clear page 1
	cmpx	#page1+psize
	blo	clrp1	
	lbra	main
mainp2	lda	#1	show page one
	lbsr	switch
	ldx	#page2	start drawing on page 2
	stx	page
	lda	#$80
	ldb	#$80
clrp2	std	,x++	clear page 2
	cmpx	#page2+psize
	blo	clrp2
	lbra	main

fpsskp	rmb	1
cycle	rmb	1
page	rmb	2
sound	rmb	1
clock	rmb	2

* check to quit
isdone	
	lda	#$fe	check for X key press
	sta	$ff02
	lda	$ff00
	cmpa	#$f7
	beq	tobasic	if X pressed quit
	rts

* go to basic
tobasic	clra
	sta	$ff22	return to text mode
	sta	$ffc0
	sta	$ffc6	show text page
	sta	$ffcc
	sta	$ffc9
	lds	stack
	andcc	#$af	enable interrupts
	rts

* blit - copy bitmap onto page
* a - height
* b - width
* x - location in screen memory
* u - bitmap
blit	
	sta	bltrows	height of bitmap (rows)
	stb	bltcols	width of bitmap (cols)
	clra
	ldb	#$20	width of screen line
	subb	bltcols	width of bitmap
	stb	bltinc	number of bytes to move to next row
blit010	ldb	bltcols	get width of bitmap
	lsrb
blit020	ldy	,u++	copy row
	sty	,x++
	decb
	bne	blit020
	lda	bltinc
	leax	a,x	move to next row
	dec	bltrows	decrement number of rows remaining
	bne	blit010
	rts
bltrows	rmb	1
bltcols	rmb	1
bltinc	rmb	2

* draw a cylinder
cyl	lda	#35	height
	ldb	#10	width
	ldu	#cyltbl
	bsr	blit
	rts

* Draw a piston
pst	lda	#23	height
	ldb	#8	width
	ldu	#psttbl
	bsr	blit
	rts

* draw ignition
fire	lda	#8	height
	ldb	#8	width
	ldu	#firetbl
	bsr	blit
	rts

* delay
delay	ldu	#$2000
count	nop
	nop
	nop
	leau	-1,u
	bne	count
	rts

* switch - switch to page and wait
* a - page to show
switch	
	sta	pgreq	for irq handler
wait
	lda	pgreq	wait until page switch is complete
	bne	wait
	rts

bang	ldx	#$8000	start address for sound data
bng020	lda	,x+	
	anda	#$fc	reset 2 LS bits
	sta	$ff20	output
	bsr	bng030	delay
	cmpx	#$8010
	bne	bng020	loop if not end
	rts
bng030	lda	#$80	delay
bng040	deca
	bne	bng040
	rts

* bcdadd - add a single byte value to a bcd number
* b - size of bcd number
* x - points to value to add (BCD)
* u - points to value (BCD) LSB
bcdadd
	tfr	u,y	store result in value
	andcc	#$fe	reset carry
bcd010	
	lda	,-x
	adca	,-y	add to value
	daa		
	sta	,-u	store result
	decb		dec interation count
	bne	bcd010	go if not done
	rts


* prtbcd - prints a BCD number to the screen
* a - colour (0-7) in high nibble
* b - number of digit pairs
* x - position to print
* u - points to value (BCD)
prtbcd
	stb	prtcols
	stx	prtloc
	anda	#$70	here in case I mess up the colour
	sta	prtclr
	lda	#2	pairs of digits to write
	lda	#5	height of a digit
	sta	prtrows
	
prt010	ldy	#digits	lookup table
	lda	,u	get number to draw
	anda	#$f0
	lsra
	lsra
	lsra
	leay	a,y	
	ldy	,y	get location of digit
	bsr	prtnum
	ldx	prtloc
	leax	2,x	move to next location to draw
	stx	prtloc
	lda	#5	reset number of rows to draw
	sta	prtrows
	ldy	#digits	lookup table
	lda	,u+	get number to draw
	anda	#$0f
	lsla
	leay	a,y	
	ldy	,y	get location of digit
	bsr	prtnum
	ldx	prtloc
	leax	2,x	move to next location to draw
	stx	prtloc
	lda	#5	reset number of rows to draw
	sta	prtrows
	dec	prtcols	are we done drawing numbers?
	bne	prt010
	rts
prtnum	ldd	,y++	get digit
	ora	prtclr	color it
	orb	prtclr
	std	,x
	leax	$20,x	move to next row
	dec	prtrows
	bne	prtnum
	rts
prtloc	rmb	2
prtclr	rmb	1
prtrows	rmb	1
prtcols rmb	1


* Start of screen interrupt handler
* (update this if you change start of video memory)
irqclk	rmb	1
one	fcb	0,1
scrint
scrclk	
	inc	irqclk	60 irqs per sec
	lda	#60
	cmpa	irqclk
	bhi	scrnxt
onceasec
	* incrememt clock
	ldb	#2	two byte BCD
	ldx	#one+2	add a second to the clock
	ldu	#clock+2
	lbsr	bcdadd
	
	* reset fps counter
	lda	irqfps
	sta	fps	store to draw
	clr	irqfps	clear once a sec

	* reset counter to count to next second
	clr	irqclk

scrnxt
	lda	fpscnt
	deca
	sta	fpscnt
	cmpa	#0
	bgt	scrrti
scrpg0	
	clr	irqovr	mark if we took too long to draw
	lda	pgreq
	beq	scrrti
	ldb	#fpsrst
	stb	fpscnt
scrpg1
	cmpa	#1	
	bne	scrpg2	base offset $0600
	sta	$ffcc	-
	sta	$ffcb	+$0800 = $0e00
	bra	scrpgr
scrpg2
	cmpa	#2
	bne	scrpgr	base offset $0600
	sta	$ffca	-
	sta	$ffcd	+$1000 = $1600
scrpgr
	lda	irqfps	track fps
	inca
	daa
	sta	irqfps
	clr	pgreq	mark switch was made
scrrti
	lda	$ff02	reset irq
	rti

* BITMAPS

* cylinder walls
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

* piston
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

* ignition in piston
firetbl
	fcb	$ff,$ff,$9f,$9f,$9f,$9f,$ff,$ff	
	fcb	$ff,$ff,$ff,$9f,$9f,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff	
	fcb	$bf,$ff,$ff,$ff,$ff,$ff,$ff,$bf	
	fcb	$bf,$bf,$ff,$ff,$ff,$ff,$bf,$bf	

digits	* number bitmaps
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

	end start

	