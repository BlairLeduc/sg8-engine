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

		nam	engine

***************************************************************************************
* Memory map
*
* $0000-$03ff System Memory
* $0400-$05FF Text Memory
* $0600-$0dff Disk System Memory
* $0e00-$1dff Video Memory (pages)
*             1 -> $0e00-$15ff (2K)
*             2 -> $1600-$1dff (2K)
* $1e00-$2000 Stack (512 bytes)
* $2000-$20FF Direct Page
* $2100-$7fff Program
* $8000-$ffff ROMs and I/O area

stack		equ	$2000
psize		equ	$0800		Size of a page (2K for SG8)
page1		equ	$0e00		Start of graphics memory
page2		equ	page1+psize

directPage	equ	$20


***************************************************************************************
* System equates
irqVector	equ	$010c

***************************************************************************************
* BSS area
		org	$2000

		* Interrup handler variables
ticks		rmb	2
secondKeeping	rmb	1
pageRequest	rmb	1		Page switch request
frameCount	rmb	1
isInTime	rmb	1
currentFps	rmb	1
fpsLimitCount	rmb	1

		* Draw/Blit variables
blitRows	rmb	1
blitCols	rmb	1
blitRowInc	rmb	2
drawLocation	rmb	2
drawColour	rmb	1

		* Other variables
randomState	rmb	1		Pseudo-random number state

		* Game variables
cycle		rmb	1
page		rmb	2
sound		rmb	1
clock		rmb	2


***************************************************************************************
* Initialised area
one		fcb	0,1		Value of one, for incrementing BCD values
taps		fcb	$b4		Pseudo-random number coefficients for LFSR

***************************************************************************************
* FPS constants
fpsTarget	equ	15		Valid FPS limits: 60, 30, 20, 15, 12, 10, ...
fpsLimit	equ	(60/fpsTarget)


***************************************************************************************
* Semigraphics constants
green		equ	$00
yellow		equ	$10
blue		equ	$20
red		equ	$30
buff		equ	$40
cyan		equ	$50
magenta		equ	$60
orange		equ	$70


***************************************************************************************
* Object screen positon constants
cylinderLeftPos	equ	$0203		Left cylinder
cylinderRightPos equ	$0213		Right cylnder
pistonLeftPos	equ	$0224		Left piston
pistonRightPos	equ	$0234		Right piston
pistonTopOff	equ	$0100		Offset for the piston at top
pistonMidOff	equ	$0200		Offset for the piston at middle
pistonBotOff	equ	$0300		Offset for the piston at bottom

clockPos	equ	$18		Clock
fpsPos		equ	psize-(5*32)-18	FPS counter
lightPos	equ	psize-(5*32)	Light


***************************************************************************************
* Game constants

* Sound flags
bang		equ	$01


***************************************************************************************
* Start of game
		org	$2100
start	
		* Set up
		orcc	#$50		Turn off IRQ and FIRQ
		lds	#stack		Set stack to our org
		lda	#directPage
		tfr	a,dp
		setdp	directPage
		* Load interrupt vector table to jump to our routine on IRQ
		lda	#$7e		jmp op code
		sta	irqVector
		ldy	#interrupt 	Set the IRQ vector
		sty	irqVector+1
		* Enable IRQ from VDG circuit (every 16.7ms)
		lda	$ff03		Read CRB of PA1
		ora	#$05		Enable interrupt to CPU
		sta	$ff03
		lda	$ff02		Clear interrupt flag
		* Set up semigraphics 8
		lda	$ff22	
		anda	#$7
		sta	$ff22
		sta	$ffc4
		sta	$ffc3
		sta	$ffc0
		* Show page 1 ($0e00) 
		sta	$ffc7		1 -> $0200
		sta	$ffc9		1 -> $0400
		sta	$ffcb		1 -> $0800 (page2 = 0)
		sta	$ffcc		0 -> $1000 (page2 = 1)
		sta	$ffce		0 -> $2000
		sta	$ffd0		0 -> $4000
		sta	$ffd2		0 -> $8000
		* Enable sound
		lda	$ff01		Select sound out
		anda	#$f7		Reset mux bit
		sta	$ff01
		lda	$ff03		Select sount out
		anda	#$f7		Reset mux bit
		sta	$ff03
		lda	$ff23		Get PIA
		ora	#8		6-bit sound enable
		sta	$ff23
		* Initialise page request to None
		clr	pageRequest
		* Initialise clock
		clr	secondKeeping
		* Initialise FPS counter
		clr	frameCount
		clr	currentFps
		lda	#fpsLimit
		sta	fpsLimitCount
		lda	$0113		Basic timer (should be random the number we get)
		sta	randomState	for initial seed for pseudo-random number generator
		clra
		clrb
		std	ticks
		* Enable IRQ (FIRQ disabled)
		andcc	#$ef
		* Clear all pages to black
		ldd	#$8080		Black in sg8
		ldx	#page1		Start of graphics memory
loop@		std	,x++
		cmpx	#page1+2*psize
		blo	loop@
		* Initialise game variables
		clra
		clrb
		sta	cycle
		sta	sound
		std	clock
		ldx	#page1
		stx	page


***************************************************************************************
* Main loop
mainLoop
		* Detect when we take too long and do not meet the FPS setting 
		lda	#1
		sta	isInTime

soundEffects
		* Run sound for page that is shown
		lda	sound
		beq	draw
		lbsr	soundBang	...and bang for shown page

draw
		* Draw page content on hidden page
		clr	sound		Initialise sound
drawClock
		* Draw clock
		lda	#magenta
		ldb	#2		Two pairs of digits
		ldx	page
		leax	clockPos,x
		ldy	#clock
		lbsr	printBcd

drawRandomLight
		lbsr	getRand
		cmpa	#$80
		bls	drawCycle
		ldx	page
		leax	lightPos,x
		lbsr	blitLight
drawCycle
		* Draw left cylinder
		ldx	page
		leax	cylinderLeftPos,x
		lbsr	blitCylinder
		* Draw right cylinder
		ldx	page
		leax	cylinderRightPos,x
		lbsr	blitCylinder
drawCycle@0
		* Draw cycle 0: left piston at bottom, 
		* right piston at top with ignition
		lda	cycle
		cmpa	#0
		bne	drawCycle@2
		* Draw left piston
		ldx	page
		leax	pistonLeftPos+pistonBotOff,x
		lbsr	blitPiston
		* Draw right pistion
		ldx	page
		leax	pistonRightPos+pistonTopOff,x
		lbsr	blitPiston
		* Draw ignition on right piston
		ldx	page
		leax	pistonRightPos,x
		lbsr	blitFire
		* Need a bang for the ignition
		lda	#bang
		sta	sound
		bra	drawCycle@SetNext
drawCycle@2
		* Draw cycle 2: left piston at top with ignition, 
		* right piston at bottom
		lda	cycle
		cmpa	#2
		bne	drawCycle@Others
		* Draw left piston
		ldx	page
		leax	pistonLeftPos+pistonTopOff,x
		lbsr	blitPiston
		* Draw right pistion
		ldx	page
		leax	pistonRightPos+pistonBotOff,x
		lbsr	blitPiston
		* Draw ignition on left piston
		ldx	page
		leax	pistonLeftPos,x
		lbsr	blitFire
		* Need a bang for the ignition
		lda	#bang
		sta	sound
		bra	drawCycle@SetNext
drawCycle@Others
		* Draw cycle 1 and 3: both pistons in the middle
		* Draw left piston 
		ldx	page
		leax	pistonLeftPos+pistonMidOff,x
		lbsr	blitPiston
		* Draw right piston
		ldx	page
		leax	pistonRightPos+pistonMidOff,x
		lbsr	blitPiston
		* No bang needed
drawCycle@SetNext	
		lda	cycle
		inca
		sta	cycle
		cmpa	#4
		blo	mainEnd
		clr	cycle

mainEnd
		* Drawing done, prepare for next screen

drawFps
		* Draw the FPS counter
		lda	isInTime
		bne	drawFps@Under
drawFps@Over
		lda	#red
		bne	drawFps@Counter
drawFps@Under	
		lda	#green
drawFps@Counter
		ldb	#1		One pair of digits
		ldx	page
		leax	fpsPos,x
		ldy	#currentFps
		lbsr	printBcd

doubleBuffer
		* Switch to other page for double buffering
		ldd	#page1
		cmpd	page
		beq	showPage@1
showPage@2
		* Show page 2 and clear page 1 and set for drawing
		lda	#2
		lbsr	showPage
		ldx	#page1
		stx	page		Start drawing on page 1
		lda	#$80
		ldb	#$80
loop@2		std	,x++		Clear page 1
		cmpx	#page1+psize
		blo	loop@2	
		lbra	mainLoop
showPage@1
		* Show page 1 and clear page 2 and set for drawing
		lda	#1
		lbsr	showPage
		ldx	#page2		Start drawing on page 2
		stx	page
		lda	#$80
		ldb	#$80
loop@1		std	,x++		Clear page 2
		cmpx	#page2+psize
		blo	loop@1
		lbra	mainLoop


*******************************************************************************
* Drawing routines

blitCylinder	* Draw a cylinder
		* x - location to draw
		lda	#35		Height
		ldb	#10		Width
		ldy	#cylinderBitmap
		bsr	blit
		rts

blitPiston	* Draw a piston
		* x - location to draw
		lda	#23		Height
		ldb	#8		Width
		ldy	#pistonBitmap
		bsr	blit
		rts

blitFire	* Draw ignition
		* x - location to draw
		lda	#8		Height
		ldb	#8		Width
		ldy	#fireBitmap
		bsr	blit
		rts

blitLight	* Draw ignition
		* x - location to draw
		lda	#4		Height
		ldb	#2		Width
		ldy	#lightBitmap
		bsr	blit
		rts

*******************************************************************************
* Helper routines

blit		* Copy bitmap onto page
		* a - height
		* b - width
		* x - location in screen memory
		* y - bitmap
		sta	blitRows	Height of bitmap (rows)
		stb	blitCols	Width of bitmap (cols)
		clra
		ldb	#$20		Width of screen line
		subb	blitCols	Width of bitmap
		stb	blitRowInc	Number of bytes to move to next row
loop@1		ldb	blitCols	Get width of bitmap
		lsrb			We copy two bytes at a time so / 2
loop@2		ldu	,y++		Copy row
		stu	,x++
		decb
		bne	loop@2
		lda	blitRowInc
		leax	a,x		Move to next row
		dec	blitRows	Decrement number of rows remaining
		bne	loop@1
		rts

showPage	* switch to page and wait for page to be visible
		* a - page to show
		sta	pageRequest	For irq handler
loop@		lda	pageRequest	Wait until page switch is complete
		bne	loop@		Request is serviced when pageReq reset to 0
		rts

soundBang	* Creates a bang sound for ignition
		* No parameters
		ldx	#$8000		Start address for sound data
loop@1		lda	,x+	
		anda	#$fc		Reset 2 least-significant bits
		sta	$ff20		Output
		bsr	soundBang@Delay	
		cmpx	#$8010
		bne	loop@1		Loop if not end
		rts
soundBang@Delay
		lda	#$80		Frequency delay
loop@2		deca
		bne	loop@2
		rts

addBcd		* Add two BCD numbers, result to address in y
		* b - size of bcd number
		* x - points to value to add (BCD)
		* y - points to value (BCD) LSB
		tfr	y,u		Store result in value
		andcc	#$fe		Reset carry
loop@		lda	,-x
		adca	,-u		Add to value
		daa		
		sta	,-y		Store result
		decb			Decrement interation count
		bne	loop@		Loop if not done
		rts

printBcd	* Prints a BCD number to the screen
		* a - colour (0-7) in high nibble
		* b - number of digit pairs
		* x - position to print
		* y - points to value (BCD)
		stb	blitCols
		stx	drawLocation
		sta	drawColour
		tfr	y,u		
loop@
		* Draw most-significant nibble
		ldy	#digitLookup
		lda	,u		Get number to draw
		anda	#$f0		Draw most-significant nibble first
		lsra			And shift it down
		lsra
		lsra			But leave as * 2 to index into 16-bit table
		leay	a,y		Index to lookup digit bitmap
		ldy	,y		Get location of digit
		lda	#5		Height of a digit
		sta	blitRows
		lbsr	blitDigit
		* Move to next location to draw
		ldx	drawLocation
		leax	2,x
		stx	drawLocation
		* Draw least-significant nibble
		ldy	#digitLookup
		lda	,u+		Get number to draw
		anda	#$0f		Now draw least-significat nibble
		lsla			Multiply by 2 to index into 16-bit table
		leay	a,y		Index to lookup digit bitmap
		ldy	,y		Get location of digit
		lda	#5
		sta	blitRows
		lbsr	blitDigit
		* Move to next location to draw
		ldx	drawLocation
		leax	2,x
		stx	drawLocation
		* Are we done drawing numbers?
		dec	blitCols
		bne	loop@
		rts

blitDigit	* Blit a single digit
		* x - points to location in screen memory 
		* y - points to digit bitmap
		ldd	,y++		Get digit
		ora	drawColour	Colour it
		orb	drawColour
		std	,x
		leax	$20,x		Move to next row
		dec	blitRows
		bne	blitDigit
		rts

seedRand	* Seed random number
		* No parameters
		lda	ticks+1
		sta	randomState
		rts
getRand		* Get random number (a - random bit on return)
		* No parameters
		* Uses the Galois form to express the LFSR
		lda	randomState
		tfr	a,b
		lsrb
		bita	#$01
		beq	getRand@1
		eorb	taps
getRand@1	stb	randomState
		rts	


*******************************************************************************
* IRQ interrupt handler
interrupt	* IRQ interrupt handler
		ldd	ticks
		addd	#1
		std	ticks

		* Check if we are on a second boundary
		inc	secondKeeping		60 IRQs per sec (every 16.7ms)
		lda	#60
		cmpa	secondKeeping
		bhi	everyInterrupt
everySecond
		* Incrememt clock
		ldb	#2		Two byte BCD
		ldx	#one+2		Add a second to the clock
		ldy	#clock+2
		lbsr	addBcd
		
		* Store FPS for display and reset FPS counter
		lda	frameCount
		sta	currentFps	Store to draw
		clr	frameCount	Clear counter for next measurement

		* Reset counter to count to next second
		clr	secondKeeping

everyInterrupt
		* Limit FPS to requested value
		* If drawing a page is late, show it immediately
		lda	fpsLimitCount
		deca
		sta	fpsLimitCount
		cmpa	#0
		bgt	interruptRti	Limit if early, show if late

		* Show page logic
		clr	isInTime	Mark if we took too long to draw

		lda	pageRequest
		beq	interruptRti	No page requested, bail

		ldb	#fpsLimit	Reset FPS limiter
		stb	fpsLimitCount
showPage@1
		* Show page 1
		cmpa	#1	
		bne	showPage@2	Base offset $0600
		sta	$ffcc		-
		sta	$ffcb		+$0800 = $0e00
		bra	showPage@Done
showPage@2
		* Show page 2
		cmpa	#2
		bne	showPage@Done	Base offset $0600
		sta	$ffca		-
		sta	$ffcd		+$1000 = $1600
showPage@Done
		lda	frameCount	Track fps
		inca			Increment each page switch
		daa
		sta	frameCount
		clr	pageRequest	Mark switch was made

interruptRti
		lda	$ff02		Reset irq trigger
		rti


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

	end start
	