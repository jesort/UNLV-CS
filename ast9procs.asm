; *****************************************************************
;  Name: 
;  NSHE ID:	
;  Section:	
;  Assignment: 9
;  Description: Learn assembly language functions and startd calling conventions. Additionally, become more familiar with
;				program control instructions, functions handling, and stacks.

;100000000000000000000000000
; --------------------------------------------------------------------
;  Write the following assembly language functions.

;  Value returning function readBinaryNumber(), reads a binary number
;  in ASCII format from the user and convert to an integer.
;  Returns a status code.

;  The function, bubbleSort(), sorts the numbers into ascending
;  order (small to large).  Uses the bubble sort algorithm from
;  assignment #7 (modified to sort in ascending order).

;  The function, simpleStats(), finds the minimum, median, and maximum
;  for a list of numbers.

;  The function, iAvergae(), computes the integer average for a
;  list of numbers.

;  The function, lstStats(), to compute the variance and
;	standard deviation for a list of numbers.


; ************************************************************************************
; -----
;  Define standard constants

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; system call code for read
SYS_write	equ	1			; system call code for write
SYS_open	equ	2			; system call code for file open
SYS_close	equ	3			; system call code for file close
SYS_fork	equ	57			; system call code for fork
SYS_exit	equ	60			; system call code for terminate
SYS_creat	equ	85			; system call code for file open/create
SYS_time	equ	201			; system call code for get time

LF		equ	10
NULL		equ	0
ESC		equ	27

; -----
;  Program specific constants.

MAXNUM		equ	10000000
BUFFSIZE	equ	50			; 49 chars plus NULL

; -----
;  NO STATIC LOCAL VARIABLES
;  LOCALS MUST BE DEFINED ON THE STACK!!


; ********************************************************************************

section	.text

; --------------------------------------------------------------------------------
;  Simple function to read a ternary number in ASCII format
;  from the user and call rotuine to convert to an integer.
;  Returns a status code (SUCCESS or NOSUCCESS).

; -----
;  HLL Call
;	status = readBinaryNumber(&number);

; -----
;  Arguments passed:
;	1) integer, address - 8		rdi

; -----
;  Returns
;	1) integer - value (via passed address)
;	2) status code - value (via EAX)

global	readBinaryNumber
readBinaryNumber:
;jmp		getlineFailure
push 	rbp
mov		rbp,	rsp
sub		rsp,	46

push 	rsi				;used for syscall, 2nd argument of aBin2int, and
						;used in syscall in printString
push 	rdx				;used in syscall in readBinaryNumbers and printString
push 	r12				;used as an index counter in readBinaryNumbers
push	r13				;temporary store the byte of the character 

push 	r14
push 	r15
push	rdi				;ARGUMENT #1, INTEGER ADDRESS
push	rbx
;mov		r10,	rbp		;Stores inputted string
;sub		r10,	25		;25-byte, local string array = rbp-25
;mov		r11,	rbp		;Stores inputted character
;sub		r11,	26		;1-byte, local, character variable = rbp-26
lea			r14, byte[rbp-25]
lea			r15, byte[rbp-26]
mov		byte[rbp-45], FALSE
mov		byte[rbp-46], 0
mov		rbx,	FALSE
mov		r12,	0		;array index coutner
mov		r13,	0		;temporarily store character byte for moving
getlineLoop:
	cmp		r12,		24		;conditional jump, comparing index counter to 25
	jg		getlineFailure	;if r12 > 25, skip to getlineFailure
	getCharLoop:
		mov		rax,	SYS_read	;call code
		mov		rdi,	STDIN		;Where reading from
		mov		rsi,	r15			;Address where the read character will be stored
		mov		rdx,	1
		syscall
	cmp		byte[r15],	LF
	je		escapeLoop
	cmp		byte[r15], ' '
	je		getCharLoop
	cmp		rbx,	FALSE
	jne		continueCharLoop
	cmp		byte[r15], '0'
	jne		continueCharLoop
	mov 	byte[rbp-45],	TRUE
	inc		byte[rbp-46]
	jmp		getCharLoop
	continueCharLoop:
	mov		rbx,	TRUE


	mov		r13b,	byte[r15]		;r13b = character
	;mov		byte[r15], r13b
	mov		byte[r14+r12],	r13b	;append character to string
	inc		r12						;increment index counter
;	cmp		byte[r15],	LF			;conditional jump, comparing the inputted character to LF
;	je		escapeLoop				;if	byte[r11] == LF, then escape loop successfully
	jmp		getlineLoop				;loop back to getLineLoop for next iteration
	
escapeLoop:
	;pop		rbx
	mov		byte[r14+r12], NULL
	;cmp		rbx,	FALSE
	;jne		skipthezeroCheck
	;jmp
	;skipthezeroCheck:
	mov	byte[rbp-44],	bl


	pop		rbx
	pop		rdi				;pop pass-by-reference integer address
	cmp		r12,	0
	je		emptyString
	mov		rsi,	rdi		;aBin2int argument #2 = pass-by-reference integer address
	mov		rdi,	r14		;aBin2int argument #1 = pass-by-reference string address
	call	aBin2int		;call function, return rax, and rsi
	mov		rdi,	rsi		;return integer address from rsi to rdi
	cmp		rax,	FALSE	;conditional jump, comparing returnBool to False
	je		escapeLoopFailure	;if rax == false, skip to getlineFailure
	cmp		dword[rdi],		MAXNUM
	jg		escapeLoopFailure
	cmp		byte[rbp-46], 26
	jge		escapeLoopFailure

	zeroslabel:
	mov		rax,	SUCCESS
	mov		r10,	0
	jmp		exitreadBinaryNumber

getlineFailure:
	pop rbx
	getCharLoopFailure:
		mov		rax,	SYS_read	;call code
		mov		rdi,	STDIN		;Where reading from
		mov		rsi,	r15			;Address where the read character will be stored
		mov		rdx,	1
		syscall
	cmp		byte[r15],	LF
	je		escapeCharLoopFailure
	jmp		getCharLoopFailure
	escapeCharLoopFailure:
		pop rdi
	escapeLoopFailure:
	;;this is the bug

	;cmp		byte[rbp-44],	FALSE
	;jne		continueFailureHERE
	;mov		dword[rdi],		0
	;jmp		zeroslabel
	;continueFailureHERE:
	push	rdi				;store integer address
	mov		rdi,	rbp		;printString Argument #1, output string
	sub		rdi,	43		;rdi = rbp-43
; -----
;  Set error message -> "Error, re-enter: ", LF, NULL
;  Note, can use printString() function to display.

	mov	dword [rdi], "Erro"
	mov	dword [rdi+4], "r, r"
	mov	dword [rdi+8], "e-en"
	mov	dword [rdi+12], "ter:"
	mov	byte [rdi+16], " "
	mov	byte [rdi+17], NULL

; -----

call	printString			;Arg#1: rdi, output string
mov		r10,	123
pop		rdi
jmp		exitreadBinaryNumber
emptyString:
cmp		byte[rbp-44], FALSE
jne		skipthecheckhere
cmp		byte[rbp-45], TRUE
jne		skipthecheckhere
cmp		byte[rbp-46], 24
jge		escapeLoopFailure
mov		dword[rdi], 0
jmp		zeroslabel
skipthecheckhere:
mov		rax,	NOSUCCESS	;readBinaryNumber's return arg = NOSUCCESS
;pop		rdi					;return readBinaryNumber integer address to rdi



exitreadBinaryNumber:		;end of readBinaryNumber


pop 	r15
pop		r14
pop		r13
pop	   	r12
pop    	rdx
pop	  	rsi
mov		rsp, rbp
pop		rbp
cmp		r10,	123
je		readBinaryNumber
ret

; *******************************************************************************
;  Simple function to convert binary string to integer.
;	Reads string and converts to intger

; -----
;  HLL Call
;	bool = aBin2int(&str, &int);

; -----
;  Arguments passed:
;	1) string, address		rdi
;	2) integer, address		rsi

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

; *******************************************************************************
;  Function to perform bubble sort.
;	Note, sorts in asending order

; -----
;  HLL Call:
;	bubbleSort(list, len);

;  Arguments Passed:
;	1) list, addr
;	2) length, value

;  Returns:
;	sorted list (list passed by reference)


global bubbleSort
bubbleSort:
push 	rbp			;
mov 	rbp, 	rsp	;
push	rbx			;
push	r12			;<<< Store preserved register states into stack
push	r13			;
push	r14			;
push	r15			;

mov		rbx,	0	;storing lst[j] and for swapping index value
mov		r11,	0	;register for storing swapped index value
mov		r12,	0	;bsInnerLoop iteration variable, i
mov		r13,	rsi	;r13 = lstLen;
dec		r13			;r13 = lstLen - 1;, bsInnerLoop iteration boundary	
mov		r14,	0	;bsOuterLoop iteration variable, j
mov		r15,	0	;bsOuterLoop iteration boundary

bsOuterLoop:
	mov		r14,	0		;j = 0;
	mov 	r15, 	rsi		;r15 = lstLen;
	sub		r15, 	r12		;r15 = lstLen - i;
	dec		r15				;r15 = lstLen - i - 1;
	bsInnerLoop:
	mov		ebx,	dword [rdi+r14*4]		;ebx = lst[j];
	cmp		ebx,	dword [rdi+(r14+1)*4]	;Conditional jump, comparing lst[j] to lst[j+1]
	jle		bsInnerLoopEnd					;if lst[j] >= lst[j+1], skip swap to bsInnerLoopEnd for next iteration
	mov		r11d,	dword [rdi+(r14+1)*4]	;r11d = lst[j+1]
	mov		dword [rdi+(r14+1)*4],	ebx		;lst[j+1] = lst[j]
	mov		dword [rdi+(r14)*4],	r11d	;lst[j] = lst[j+1]
	bsInnerLoopEnd:
	inc		r14								;increment j for next bsInnerLoop iteration
	cmp		r14,	r15						;conditional jump, comparing j to j bsInnerLoop boundary
	jne		bsInnerLoop						;if r14 != r15, jump to bsInnerLoop for next loop iteration
	inc		r12								;increment i for next bsOuterLoop iteration
	cmp		r12,	r13						;conditional jump, comparing i to bsOuterLoop boundary
	jne		bsOuterLoop						; if r12 != r13, jumpt to bsOuterLoop for next loop iteration

pop		r15		;	<<<return preserved registers to their original states>>>
pop		r14		;
pop		r13		;
pop		r12		;
pop		rbx		;
pop 	rbp		;
ret

; *******************************************************************************
;  Function to compute and return simple stats for list:
;	minimum, maximum, median

;   Note, assumes the list is ALREADY sorted.

;   Note, for an odd number of items, the median value is defined as
;   the middle value.  For an even number of values, it is the integer
;   average of the two middle values.
;   The median must be determined after the list is sorted.

; -----
;  HLL Call:
;	simpleStats(&list, len, &min, &max, &med);

; -----
;  Arguments Passed:
;	1) list, addr       rdi
;	2) length, value	rsi
;	3) minimum, addr	rdx
;	5) median, addr		r8
;	4) maximum, addr	rcx

;  Returns
;	results via passed addresses

;lst is sorted from least to greatest
global simpleStats
simpleStats:
push	rax		;preserve register state in stack
push 	rdx		;preserve register state in stack

;calculate lst's minimum
mov		r10d,			dword[rdi]				;r10d = lst[0];
mov 	dword[rdx],		r10d					;minimum = lst[0];
;calculate lst's maximum
mov		r10d,			dword[rdi+(rsi-1)*4]	;r10d = lst[len-1];
mov		dword[rcx],		r10d					;maximum = r10d

;calculate lst's median (works on even and odd lst lengths)
mov		rax,			rsi						;rsi = length
cqo												;signed widen rdx:rax
mov		r10,			2						;denominator = 2
idiv	r10										;edx:rax/r10 = rax = length/2
cmp		rdx,			0						;conditional jump, comparing division remainder to 0
je		medianEven								;if rdx == 0, skip to medianEven
medianOdd:
	mov		r10d,	dword[rdi+rax*4]			;r10d = lst[length/2]
	mov		dword[r8], r10d						;median = lst[length/2]
	jmp		skipEven							;skip medianEven to end
medianEven:
	mov		r10,		rax						;r10 = length/2
	mov		eax,		dword[rdi+r10*4]		;eax = lst[length/2]
	add		eax,		dword[rdi+(r10-1)*4]	;eax = lst[length/2] + lst[length/2-1]
	cdq											;signed widen rdx:rax
	mov 	r11d,		2						;denominator = 2
	idiv	r11d								;edx:eax/r11d = eax = (lst[length/2] + lst[length/2-1])/2
	mov		dword[r8],	eax						;median = (lst[length/2] + lst[length/2-1])/2
skipEven:

pop 	rdx		;return register state from stack
pop		rax		;return register state from stack
ret

; *******************************************************************************
;  Function to compute and return integer average for a list of numbers.

; -----
;  HLL Call:
;	ave = iAverage(list, len);

; -----
;  Arguments Passed:
;	1) list, addr - 8
;	2) length, value - 12

;  Returns
;	integer average - value (in eax)


global iAverage
iAverage:
push 	rbp			;
mov 	rbp, 	rsp	;Store preserved registers in stack
push	rdx			;
mov		r10,	0	;sumCalcLoop iteration counter
mov		rax,	0	;function's return value
sumCalcLoop:
add		eax,	dword[rdi+r10*4]	;eax += lst[i]
inc		r10							;i++
cmp		r10,	rsi					;conditional jump, comparing i to indexCount
jne		sumCalcLoop					;if r10 != rsi, jump back to sumCalcLoop for next loop iteration
cdq					;signed widening conversion of edx:eax				
idiv	rsi			;sum/indexCount = edx:eax/rsi = eax
pop rdx				;restore states of preserved registers
pop rbp
ret					;return rax to main, rax = lst's average value

; *******************************************************************************
;  Function to compute and return the variance of a list.
;	Note, uses iaverage to find the average for the calculations.

; -----
;  HLL Call:
;	var = lstStats(list, len, &var, &std)

; ----
;  Arguments Passed:
;	1) list, addr
;	2) length, value
;	3) variance, addr
;	4) standard deviation, addr

;  Returns:
;	n/a


global lstStats
lstStats:
push 	rbp			;
mov 	rbp, 	rsp	;
push	rbx			;
push 	r12
push	r13
push 	rdx

call iAverage

mov		rbx,	rax		;rbx = average
mov		r12,	0		;r12 = index counter
mov		r13,	0		;r13 = summation
lsLoop:
	movsxd		rax,	dword[rdi+r12*4]	;rax = lst[i]
	sub		rax,	rbx						;rax -= lstAverage
	imul	rax								;rax^2
	add		r13,	rax						;summation += rax
	sub		r13,	rax
	adc		r13,	rax						;summation += carry
	inc		r12								;increment index counter
	cmp		r12,	rsi						;conditional jump, comparing index counter to indexCount
	jne		lsLoop							;if r12 != rsi, exit lsLoop
pop		rdx
mov		qword [rdx], r13					;rdx = variance
push 	rdi

mov		rdi,	r13

call	stdDeviation		;call the function stdDeviation to calculate the standard deviation of the lst, returned in rax

movsd	qword [rcx], xmm0	;rcx = Standard Deviation

pop 	rdi	
pop		r13
pop 	r12
pop		rbx
pop		rbp
ret

; ********************************************************************
;  Function to compute standard deviation as a real value.
;  Uses floating point instructions.
;  Returns result in xmm0

;  Algorithm:
;	std = sqrt(var/n)

; -----
;  HLL Call:
;	stdDev(var, len)

;  Arguments:
;	1) variance, value
;	2) length, value

;  Returns:
;	standard deviation in xmm0

global	stdDeviation
stdDeviation:

	cvtsi2sd	xmm0, rdi
	cvtsi2sd	xmm1, rsi
	divsd		xmm0, xmm1
	sqrtsd		xmm0, xmm0

	ret

; ********************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters to write.

	mov	rdx, 0
strCountLoop:
	cmp	byte [rdi+rdx], NULL
	je	strCountLoopDone
	inc	rdx
	jmp	strCountLoop
strCountLoopDone:
	cmp	rdx, 0
	je	printStringDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of char to write
	mov	rdi, STDOUT			; file descriptor for std in
						; rdx=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

printStringDone:
	ret

; ******************************************************************

