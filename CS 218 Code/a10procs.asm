; *****************************************************************
;  Name: 
;  NSHE ID: 
;  Section: 
;  Assignment: 10
;  Description: Become more familiar with data representation issues, program control instructions, function handling, and operaiting systems interaction.

; -----
;  Function getIterations()
;	Gets, checks, converts, and returns iteration
;	count and rotation speed from the command line.

;  Function drawChaos()
;	Calculates and plots Chaos algorithm

;  Function aBin2int()
;	Convert ASCII/binary to integer

; ---------------------------------------------------------

;	MACROS (if any) GO HERE


; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; successful operation
EXIT_NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program constants.

IT_MIN		equ	255
IT_MAX		equ	65535
RS_MAX		equ	1023

; -----
;  Local variables for getIterations() function.

errUsage	db	"Usage: chaos -it <binaryNumber> -rs <binaryNumber>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line argument."
		db	LF, NULL
errITsp		db	"Error, iterations specifier incorrect."
		db	LF, NULL
errITvalue	db	"Error, invalid iterations value."
		db	LF, NULL
errITrange	db	"Error, iterations value must be between "
		db	"11111111 (2) and 1111111111111111 (2)."
		db	LF, NULL
errRSsp		db	"Error, rotation speed specifier incorrect."
		db	LF, NULL
errRSvalue	db	"Error, invalid rotation speed value."
		db	LF, NULL
errRSrange	db	"Error, rotation speed value must be between "
		db	"0 (2) and 1111111111 (2)."
		db	LF, NULL

; -----
;  Local variables for plotChaos() funcction.

red		dd	0			; 0-255
green		dd	0			; 0-255
blue		dd	0			; 0-255

pi		dq	3.14159265358979	; constant
oneEighty	dq	180.0
tmp		dq	0.0

dStep		dq	120.0			; t step
scale		dq	500.0			; scale factor

rScale		dq	100.0			; rotation speed scale factor
rStep		dq	0.1			; rotation step value
rSpeed		dq	0.0			; scaled rotation speed

initX		dq	0.0, 0.0, 0.0		; array of x values
initY		dq	0.0, 0.0, 0.0		; array of y values

x		dq	0.0
y		dq	0.0

seed		dq	987123
qThree		dq	3
fTwo		dq	2.0

A_VALUE		equ	9421			; must be prime
B_VALUE		equ	1


; ------------------------------------------------------------

section  .text

; -----
; Open GL routines.

extern glutInit, glutInitDisplayMode, glutInitWindowSize
extern glutInitWindowPosition
extern glutCreateWindow, glutMainLoop
extern glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern glutSwapBuffers
extern gluPerspective
extern glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern glClear, glLoadIdentity, glMatrixMode, glViewport
extern glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d
extern glutPostRedisplay

; -----
;  c math library funcitons

extern	cos, sin


; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.
;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:
	push	rbx
	push	rdx

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; RDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	pop rdx
	pop	rbx
	ret

; *******************************************************************************
;  Simple function to convert binary string to integer.
;	Reads string and converts to intger

; -----
;  HLL Call
;	bool = aBin2int(&str, &int);

; -----
;  Arguments passed:
;	1) string, address			rdi
;	2) integer, address			rsi

; -----
;  Returns
;	1) integer value (via passed address)
;	2) bool, TRUE if valid conversion, FALSE for error
global	aBin2int
aBin2int:

push	rbx		;preserve register state in stack
push	rcx		;preserve register state in stack
push	rdx		;preserve register state in stack
push	r12		
push	r13
push	r14


mov		r10,	0		;2^n, n = 0, n cannot exceed 31
mov		r14,	0
mov		rax,	0		;sum = 0 ;r11
jmp		ChrLength
whiteSpace:
	cmp		rax,	0
	jne		conversionFailure
	inc		r10
ChrLength:
	mov		r11, 0
	cmp		r14,	32					;conditional jump, comparing r10 to 32
	je		conversionFailure			;if r10 == 32, skip to conversionFailure
	mov		r12,	FALSE				;0Boolean = False
	mov		r13,	FALSE				;1Boolean = False
	;mov		r14,	FALSE				;whitespaceBoolen
	mov		r11b,	0					;Store the character in r11b
	mov		rdx,	2					;multiplication
	mov		r11b,		byte[rdi+r10]	;
	cmp		r11b,		NULL			;
	je		conversionSuccess		
char2int:
	cmp		r11b,		' '
	je		whiteSpace
	sub		r11b,		'0'
	cmp		r11b,		0
	jne		checkBin
	mov		r12, 	TRUE
	checkBin:
	cmp		r11b,		1
	jne		checkBool
	mov		r13,	TRUE
	checkBool:
	or		r12,	r13
	cmp		r12,	TRUE
	jne		conversionFailure
	mul		rdx
	add		al,		r11b
	inc		r14
	inc		r10
	jmp		ChrLength
conversionSuccess:
mov		dword[rsi],		eax
mov		rax,			TRUE
jmp		conversionEnd

conversionFailure:
mov		rax,			FALSE

conversionEnd:
pop		r14
pop		r13
pop		r12
pop		rdx		;return preserved register state from stack
pop		rcx		;return preserved register state from stack
pop 	rbx		;return preserved register state from stack

ret




; ******************************************************************
;  Function getIterations()
;	Performs error checking, converts ASCII/binary to integer.
;	Command line format (fixed order):
;	  "-it <binaryNumber> -rs <binaryNumber>"

; -----
;  Arguments:
;	1) ARGC, double-word, value						rdi
;	2) ARGV, double-word, address					rsi
;	3) iterations count, double-word, address		rdx
;	4) rotate spped, double-word, address			rcx



global getIterations
getIterations:
push	rbp
mov		rbp,	rsp
sub		rsp,	28		;allocate local variables
;argv[2] = &byte[rbp-17] - store it binary string
;argv[4] = &byte[rbp-28] - store rs binary string

push 	r12				;preserve register state in stack
push	r13				;preserve register state in stack
push	r14				;preserve register state in stack
mov		r12,	rdi		;argc, double-word, value
mov		r13,	0		;argv, dword?, address
mov		r14,	rsi		;iteration count, dword, value
push 	r8
push	r9
push	rdi				;preserve register state in stack
push	rsi				;preserve register state in stack

;errUsage check
cmp		r12,	1				;conditional jump, comparing argc to 1
je		errorUsage				; if r12 == 1, skip to errorUsage


;errBadCL check
cmp		r12,	5				;conditional jump, comparing argc to 5
jne		errorBadCL				; if r12 != 5, skip to errorBadCL


;errITsp check
mov		r13,	qword[r14+8]
;check if argv[1] contains "-it"
cmp		byte[r13], '-'			
jne		errorITsp
cmp		byte[r13+1], 'i'
jne		errorITsp
cmp		byte[r13+2], 't'
jne		errorITsp
cmp		byte[r13+3],	NULL
jne		errorITsp
;argv[1] is acceptably written

;errITvalue check
;errITrange check
mov		rax, 	0
mov		r8,		0					;index counter for r9
lea		r9,		byte[rbp-17]			;local string variable storing argv[2]
mov		r13,	qword[r14+16]			
argv2Loop:
	cmp		r8w,		17	;conditional jump, comparing r9's index counter to r9's length
	je		errorITrange				;if r8w == 17, skip to errorITrange
	cmp		byte[r13+r8], NULL
	je		ESCargv2Loop
	mov		al,		byte[r13+r8]
	mov		byte[r9+r8],	al
	inc		r8
	jmp		argv2Loop	
ESCargv2Loop:
mov		byte[r9+r8],	NULL	;Set last entry to NULL
mov		rdi,	r9				;aBin2int Arg #1: iteration count binary string address
mov		rsi,	rdx				;aBin2int Arg #2: iteration count binary integer address

call	aBin2int				;string to integer

cmp		rax,	FALSE			;conditional jump, comparing aBin2int's return bool to FALSE
je		errorITvalue			;if rax == false, skip to errorITvalue
cmp		dword[rdx],		255		;conditional jump, comparing iteration count integer to 225
jb		errorITrange			;if dword[rdx] < 255, skip to errorITrange
;argv[2] is acceptably written

;errRSsp check
mov		r13,	qword[r14+24]
;check if argv[3] contains "-rs"
cmp		byte[r13], '-'
jne		errorRSsp
cmp		byte[r13+1], 'r'
jne		errorRSsp
cmp		byte[r13+2], 's'
jne		errorRSsp
cmp		byte[r13+3], NULL
jne		errorRSsp
;argv[3] is acceptably written

;errRSvalue check
;errRSrange check
mov		rax,	0
mov		r8,		0
lea		r9,		byte[rbp-28]
mov		r13,	qword[r14+32]
argv4Loop:							;store argv[4] into r9 local string
	cmp		r8w,	11				;count argv[4] length
	je		errorRSrange
	cmp		byte[r13+r8], NULL
	je		ESCargv4Loop
	mov		al,		byte[r13+r8]
	mov		byte[r9+r8], al
	inc		r8
	jmp		argv4Loop
ESCargv4Loop:
mov		byte[r9+r8], NULL	;Set last entry to null
mov		rdi,	r9			;aBin2int arg #1: binary string address
mov		rsi,	rcx			;aBin2Int arg #2: binary integer address

call	aBin2int			;string to integer

cmp		rax,	FALSE		;conditional jump, comparing rax to false
je		errorRSvalue		;if rax == FALSE, skip to errorRSvalue
cmp		dword[rcx],		0	;conditinal jump, comparing argv[4] to 0
jb		errorRSrange		;if dword[rcx] < 0, skip to errorRSrange 
;argv[4] is acceptably written

mov		rax,	TRUE		;program successful
jmp		exitSuccess			;jump to exit

errorUsage:
mov		rdi,	errUsage
jmp		exitError
errorBadCL:
mov		rdi,	errBadCL
jmp		exitError
errorITsp:
mov		rdi,	errITsp
jmp		exitError
errorITvalue:
mov		rdi,	errITvalue
jmp		exitError
errorITrange:
mov		rdi,	errITrange
jmp		exitError
errorRSsp:
mov		rdi,	errRSsp
jmp		exitError
errorRSvalue:
mov		rdi,	errRSvalue
jmp		exitError
errorRSrange:
mov		rdi,	errRSrange
jmp		exitError

exitError:
call 	printString
mov		rax,	FALSE

exitSuccess:
pop 	rsi
pop		rdi
pop 	r9
pop 	r8
pop		r14
pop		r13
pop		r12
pop		rbx
mov		rsp,	rbp
pop		rbp
ret

; ******************************************************************
;  Function to draw chaos algorithm.

;  Chaos point calculation algorithm:
;	seed = random large prime (pre-set)
;	for  i := 1 to iterations do
;		s = rand(seed)
;		n = s mod 3
;		x = x + ( (init_x(n) - x) / 2 )
;		y = y + ( (init_y(n) - y) / 2 )
;		color = n
;		plot (x, y, color)
;		seed = s
;	end_for

; -----
;  Global variables (from main) accessed.

common	drawColor	1:4			; draw color
common	degree		1:4			; initial degrees
common	iterations	1:4			; iteration count
common	rotateSpeed	1:4			; rotation speed

; -----

global drawChaos
drawChaos:

; -----
;  Save registers...
push 	r12
push 	r13
mov		r12,	0
mov		r13,	0
push	rax
push	rdi
push	rsi
push	rdx
push	rbx
mov		rbx, 0
; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);

	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

; -----
;  Set rotation speed step value.
;	rStep = rotationSpeed / scale

cvtsi2sd	xmm0,	dword[rotateSpeed]
divsd		xmm0,	qword[rScale]
movsd		qword[rStep],	xmm0


; -----
;  Plot initial points.

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Calculate and plot initial points.

;xmm3 = pi/180
movsd 	xmm3, 		qword[pi]
divsd 	xmm3, 		qword[oneEighty]
movsd qword[tmp], 	xmm3


; -----
;  set and plot x[0], y[0]
; -----
;  set and plot x[1], y[1]
; -----
;  set and plot x[2], y[2]
firstThree:
	cmp r12, 3			;conditional jump, comparing i to 3
	je ESCfirstThree	;if i == 3, escape loop to ESCfirstThree
	
	;initX[i] = sin((rSpeed+(i*dStep))*(pi/180))*scale
	cvtsi2sd 	xmm0, 	r12
	mulsd 		xmm0, 	qword[dStep] 			;i*dStep
	movsd 		xmm1, 	qword[rSpeed]
	addsd 		xmm0, 	xmm1					;rSpeed+(i*dStep)
	mulsd 		xmm0, 	qword[tmp]					;(rSpeed+(i*dStep))*(pi/180)
	call 		sin								;sin((rSpeed+(i*dStep))*(pi/180))
	mulsd 		xmm0, 	qword[scale]			;sin((rSpeed+(i*dStep))*(pi/180))*scale
	movsd 		qword[initX+r12*8], 	xmm0	;initX[i] = sin((rSpeed+(i*dStep))*(pi/180))*scale

	;initY[i] = cos((rSpeed+(i*dStep))*(pi/180))*scale
	cvtsi2sd 	xmm0, 	r12
	mulsd 		xmm0, 	qword[dStep]			;i*dStep
	movsd 		xmm1, 	qword[rSpeed]
	addsd 		xmm0, 	xmm1					;rSpeed+(i*dStep)
	mulsd 		xmm0, 	qword[tmp]					;(rSpeed+(i*dStep))*(pi/180)
	call 		cos								;cos((rSpeed+(i*dStep))*(pi/180))
	mulsd 		xmm0, 	qword[scale]			;cos((rSpeed+(i*dStep))*(pi/180))*scale
	movsd 		qword[initY+r12*8], 	xmm0	;initY[i] = cos((rSpeed+(i*dStep))*(pi/180))*scale
	
	movsd 		xmm0, 	qword[initX+r12*8]		;glVertex2d arg #1: initX[i]
	movsd 		xmm1, 	qword[initY+r12*8]		;glVertex2d arg #2: initY[i]
	call 		glVertex2d						;plot points
	inc 		r12								;increment r12
	jmp			firstThree						;jump back to firstThree for next loop iteration
ESCfirstThree:

; -----
;  Main plot loop.

mainPlotLoop:
cmp		r13d,	dword[iterations]
je		ESCmainPlotLoop
; -----
;  Generate pseudo random number, via linear congruential generator 
;	s = R(n+1) = (A × seed + B) mod 2^16
;	n = s mod 3
;  Note, A and B are constants.


mov 	rax, 			A_VALUE			;rax = A_VALUE	
mov 	r12, 			qword[seed]		;multiplier = seed
imul 	r12								;rax = A_Value*seed
add 	rax, 			B_VALUE			;rax = A_Value*seed+B_Value
mov 	word[seed], 	ax				;seed = A_Value*seed+B_Value								;
idiv 	dword[qThree]					;rax = (A_Value*seed+B_Value)/3
;										;rdx = (A_Value*seed+B_Value)%3

; -----
;  Generate next (x,y) point.
;	
movsd 	xmm0, 		qword[initX+rdx*8]	;
subsd 	xmm0, 		qword[x]			;(initX[n]-x)
divsd 	xmm0, 		qword[fTwo]			;((initX[n]-x)/2)
addsd 	xmm0, 		qword[x]			;x+((initX[n]-x)/2)
movsd 	qword[x], 	xmm0				;x = x+((initX[n]-x)/2)

;	y = y+((initY[n]-y)/2)
movsd 	xmm0, 		qword[initY+rdx*8]	;
subsd 	xmm0, 		qword[y]			;(initY[n]-y)
divsd 	xmm0, 		qword[fTwo]			;((initY[n]-y)/2)
addsd 	xmm0, 		qword[y]			;y+((initY[n]-y)/2)
movsd 	qword[y], 	xmm0				;y = y+((initY[n]-y)/2)


; -----
;  Set draw color (based on n)
;	0 => read
;	1 => blue
;	2 => green

cmp		rdx,	0
je		redPrint
cmp		rdx,	2
je		greenPrint
cmp		rdx,	1
je		bluePrint
redPrint:
	mov		dword[red], 	255
	mov 	dword[green], 	0
	mov 	dword[blue], 	0
	jmp 	colorSkip
greenPrint:
	mov 	dword[red], 	0
	mov 	dword[green], 	255
	mov 	dword[blue], 	0
	jmp 	colorSkip
bluePrint:
	mov 	dword[red], 	0
	mov 	dword[green], 	0
	mov 	dword[blue], 	255
colorSkip:	
mov 	rdi, 	0
mov 	rsi, 	0
mov 	rdx, 	0
mov 	edi, 	dword[red]		;glColor3ub arg #1: red, 	rdi
mov 	esi, 	dword[green]	;glColor3ub arg #2:	green,	rsi
mov 	edx, 	dword[blue]		;glColor3ub arg #3:	blue,	rdx
call 	glColor3ub				;set draw color


; -----
;  Plot point using selected color
;	
movsd 	xmm0, 	qword[x]	;glVertex2d arg #1: x
movsd 	xmm1, 	qword[y]	;glVertex2d arg #2: y
call 	glVertex2d			;plot point
inc		r13
jmp		mainPlotLoop
ESCmainPlotLoop:

; -----

	call	glEnd
	call	glFlush

; -----
;  Update rotation speed.
;  Then tell OpenGL to re-draw with new rSpeed value.
movsd 	xmm0, 			qword[rSpeed]	
addsd 	xmm0, 			qword[rStep]	
movsd 	qword[rSpeed], 	xmm0			;rSpeed += rStep

	call	glutPostRedisplay
	pop		rbx
	pop		rdx
	pop		rsi
	pop		rdi
	pop		rax
	pop		r13
	pop		r12
	ret

; ******************************************************************

