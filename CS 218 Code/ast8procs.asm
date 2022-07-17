; *****************************************************************
;  Name: 
;  NSHE ID: 
;  Section: 
;  Assignment: 8
;  Description:	Learn assembly language functions. Additionally, become more fabiliar with program control instructions, function handling, and stacks

; --------------------------------------------------------------------
;  Write assembly language functions.

;  The function, bubbleSort(), sorts the numbers into descending
;  order (large to small).  Uses the bubble sort algorithm from
;  assignment #7 (modified to sort in descending order).

;  The function, simpleStats(), finds the minimum, median, and maximum
;  count of even values, and count of values evenly divisible by 5
;  for a list of numbers.

;  The function, iAvergae(), computes the integer average for a
;  list of numbers.

;  The function, lstStats(), to compute the variance and
;	standard deviation for a list of numbers.

;  Note, all data is signed!


; ********************************************************************************

section	.data

; -----
;  Define standard constants

TRUE		equ	1
FALSE		equ	0

EXIT_SUCCESS	equ	0			; Successful operation

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
;  Local variables for bubbleSort() function (if any)

swapped		db	FALSE


; -----
;  Local variables for simpleStats() function (if any)


; -----
;  Local variables for iAverage() function (if any)

chickenNuggets db 15

; -----
;  Local variables for lstStats() function (if any)

tmpVar		dq	0


; ********************************************************************************

section	.text

; ********************************************************************
;  Function to implement bubble sort for an integer array.
;	Note, sorts in desending order (3,2,1)

; -----
;  HLL Call:
;	bubbleSort(list, len)

;  Arguments Passed:
;	1) list, addr
;	2) length, value

;  Returns:
;	sorted list (list passed by reference)

;for(int i = 0; i < len - 1; i++)
;{
;	for(int j = 0; j < len - i - 1; j++)
;	{
;		if(lst[j] < lst[j+1])
;			{
;				temp = lst[j];
;				lst[j] = lst[j+1];
;				lst[j+1] = temp;
;			}
;	}
;}

;rdi = lst array, passed by reference
;rsi = dword [length], passed by value

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
	jge		bsInnerLoopEnd					;if lst[j] >= lst[j+1], skip swap to bsInnerLoopEnd for next iteration
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

mov		dword [swapped],	TRUE

pop		r15		;	<<<return preserved registers to their original states>>>
pop		r14		;
pop		r13		;
pop		r12		;
pop		rbx		;
pop 	rbp		;
ret

; ********************************************************************
;  Find simple statistical information of an integer array:
;	minimum, median, maximum, count of even values, and
;	count of values evenly divisible by 5

;  Note, for an odd number of items, the median value is defined as
;  the middle value.  For an even number of values, it is the integer
;  average of the two middle values.

;  Note, you may assume the list is already sorted.

; -----
;  HLL Call:
;	simpleStats(list, len, min, max, med, evenCnt, fiveCnt)

;  Arguments Passed:
;	1) list, addr		rdi
;	2) length, value	rsi
;	3) minimum, addr	rdx
;	4) maximum, addr	rcx
;	5) median, addr		r8
;	6) evenCnt, addr	r9
;	7) fiveCnt, addr	stack

;  Returns:
;	minimum, median, maximum, evenCnt, fiveCnt
;	via pass-by-reference

global	simpleStats
simpleStats:
mov		dword[r9],	0		;evenCnt = 0;
push	rbp
mov		rbp,	rsp
mov		r10,	qword[rsp+16]		;r10 = fiveCnt;
mov		dword[r10], 0		;fiveCnt = 0;
push	rbx
push 	r12
push	r13

mov		r11,	rdx			;r11 = minimum
mov		rbx,	0			;index counter

mov		r12d,	dword [rdi]		;r12d = lst[0]
mov		dword[r11],		r12d	;minimum = lst[0]
mov		dword[rcx],		r12d	;maximum = lst[0]

mov		r13,	0				;denomator for division

ssLoop:
	mov		r12d,	dword[rdi+rbx*4]	;r12d = lst[i];
	cmp		r12d, 	dword[r11]			;conditional jump, comparing lst[i] with minimum
	jge		ssLoopMax					;if lst[i] >= minimum, skip to ssLoopMax;
	mov		dword[r11], 	r12d		;otherwise, minimum = lst[i];
	ssLoopMax:
	cmp		r12d, 	dword[rcx]			;conditional jump, comparing lst[i] with maximum 
	jle		ssLoopEven					;if lst[i] <= maximum, skip to ssLoopEven
	mov		dword[rcx],		r12d		
	ssLoopEven:
	mov		r13,	2					;denominator = 2;
	mov		eax,	r12d				;eax = lst[i];
	cdq									;signed widening conversion of edx:eax
	idiv	r13d						;lst[i]/2 = edx:eax/r13d = eax, rem: edx
	cmp		edx,	0					;Conditional jump, comparing edx with division remainder
	jne		ssLoopFive					;if edx != 0, skip to ssLoopFive;
	inc		dword[r9]					;otherwise, increment evenCnt
	ssLoopFive:
	mov		r13,	5					;denominator = 5
	mov		eax,	r12d				;eax = lst[i]
	cdq									;signed widening conversion of edx:eax
	idiv	r13d						;lst[i]/5 = edx:eax/r13d = eax, rem: edx
	cmp		edx,	0					;conditional jump, comparing division remainder with 0
	jne		ssLoopEnd					;if edx != 0, skip to ssLoopEnd
	inc		dword[r10d]					;otherwise, increment fiveCnt
	ssLoopEnd:
		inc		rbx						;increment index counter
		cmp		rbx,	rsi				;conditional jump, comparing index counter to loop boundary
		jne		ssLoop					;if rbx != rsi, jump back to ssLoop for another iteration
										;otherwise, escape ssLoop and calculate median of lst

mov		rax,	rsi						;eax = indexCount
cqo										;signed widening conversion of edx:eax
mov		r13,	2						;denominator = 2
idiv	r13							;index/2 = edx:eax/r13d = eax
mov		rbx,	rax						;rbx = indexCount/2
mov		rax, 	0
mov		eax,	dword[rdi+rbx*4]			;eax = lst[indexCount/2]
add		eax,	dword[rdi+(rbx-1)*4]		;eax += lst[indexCount/2-1]
cdq										;signed widening conversion of edx:eax
idiv	r13d							;(lst[indexCount/2] + lst[indexCount/2-1])/2 = edx:eax/r13d = eax
mov		dword[r8],	eax					;median = eax


pop		r13
pop		r12
pop 	rbx
pop		rbp
ret





; ********************************************************************
;  Function to calculate the integer average of an integer array.

; -----
;  Call:
;	ave = iAverage(list, len)

;  Arguments Passed:
;	1) list, addr - 8		rdi
;	2) length, value - 12	rsi

;  Returns:
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

; ********************************************************************
;  Function to calculate the variance and standard deviation
;  of an integer array.
;  Must use iAverage() function to find average.
;  Must use the stdDev() function to find the standard deviation.
;	Note, stdDev() is a real function, which returns values in xmm0.

;  Must use MOVSD to store result from XMM0 to a memory location.
;  For example:
;	movsd	qword [someVar], xmm0

; -----
;  Call:
;	lstStats(list, len, &var, &std)

;  Arguments Passed:
;	1) list, addr					rdi
;	2) length, value				rsi
;	3) variance, addr				rdx
;	4) standard deviation, addr		rcx

;  Returns:
;	variance - value (quad)

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

	; convert integers to floats
	cvtsi2sd	xmm0, rdi
	cvtsi2sd	xmm1, rsi

	divsd		xmm0, xmm1
	sqrtsd		xmm0, xmm0

	ret

; ********************************************************************

