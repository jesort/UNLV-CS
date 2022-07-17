; *****************************************************************
;  Name: 
;  NSHE ID: 
;  Section: 
;  Assignment: 11
;  Description: Become More familair with operating system interactions, infile input/output operations, and file I/O buffering.

; -----
;  Function - getArguments()
;	Read, parse, and check command line arguments.

;  Function - countDigits()
;	Check the leading digit for each number and count 
;	each 0, 1, 2, etc...
;	All file buffering handled within this procedure.

;  Function - int2aBin()
;	Convert an integer to a ASCII/binary string, NULL terminated.

;  Function - writeString()
;	Create graph as per required format and ouput.


; ****************************************************************************

section	.data

; -----
;  Define standard constants.

LF		equ	10			; line feed
NULL		equ	0			; end of string
SPACE		equ	0x20			; space

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; Successful operation
NOSUCCESS	equ	1			; Unsuccessful operation

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

O_CREAT		equ	0x40
O_TRUNC		equ	0x200
O_APPEND	equ	0x400

O_RDONLY	equ	000000q			; file permission - read only
O_WRONLY	equ	000001q			; file permission - write only
O_RDWR		equ	000002q			; file permission - read and write

S_IRUSR		equ	00400q
S_IWUSR		equ	00200q
S_IXUSR		equ	00100q
S_IRWXU		equ	00700q

; -----
;  Variables for getArguments()

usageMsg	db	"Usage: ./benford -i <inputFileName> "
		db	"-o <outputFileName> [-d]", LF, NULL

errMany		db	"Error, too many characters on the "
		db	"command line.", LF, NULL

errFew		db	"Error, too few characters on the "
		db	"command line.", LF, NULL

errDSpec	db	"Error, invalid output display specifier."
		db	LF, NULL

errISpec	db	"Error, invalid input file specifier."
		db	LF, NULL

errOSpec	db	"Error, invalid output file specifier."
		db	LF, NULL

errOpenIn	db	"Error, can not open input file."
		db	LF, NULL

errOpenOut	db	"Error, can not open output file."
		db	LF, NULL

; -----
;  Variables for countDigits()

BUFFSIZE	equ	500000

SKIP_LINES	equ	5				; skip first 5 lines
SKIP_CHARS	equ	6

nextCharIsFirst	db	TRUE
skipLineCount	dd	0				; count of lines to skip
skipCharCount	dd	0				; count of chars to skip
gotDigit	db	FALSE

bfMax		dq	BUFFSIZE
curr		dq	BUFFSIZE
headerSkipBool  db	FALSE
wasEOF		db	FALSE

errFileRead	db	"Error reading input file."
		db	"Program terminated."
		db	LF, NULL

; -----
;  Variables for writeString()

errFileWrite	db	"Error writting output file."
		db	LF, NULL

; -------------------------------------------------------

section	.bss

buff		resb	BUFFSIZE+1

; ****************************************************************************

section	.text

; ======================================================================
; Read, parse, and check command line paraemetrs.

; -----
;  Assignment #11 requires options for:
;	input file name
;	output file name

;  Assignment #11 allows an optional argument for:
;	display results to screen (T/F)

;  For Example:
;	./benford -i <inputFileName> -o <outputFileName> [-d]

; -----
;  Example high-level language call:
;	status = getArguments(ARGC, ARGV, &rdFileDesc, &wrFileDesc, &displayToScreen)

; -----
;  Arguments passed:
;	argc											rdi
;	argv											rsi
;	address of file descriptor, input file			&rdx
;	address of file descriptor, output file			&rcx
;	address of boolean for display to screen		&r8

global getArguments
getArguments:
push 	r12		;preserve regsiter state in stack

mov		byte[r8],	FALSE	;initalize boolean variable to false

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;usagemsg, when argc = 1
cmp		rdi,	1			;conditional jump, comparing argc value to 1
je		errorUsageMessage	;if rdi == 1, skip to errorUsageMessage

;errMany, argc: [5,6]
cmp		rdi,	6			;conditional jump, comparing argc value to 6
ja		errorMany			;if rdi > 6, skip to errorMany

;errFew, argc: [5,6]
cmp		rdi,	5			;conditional jump, coparing argc value to 5
jb		errorFew			;if rdi < 5, skip to errorFew

;ARGC WITHIN ACCEPTABLE RANGE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;errDSpec
cmp		rdi,			6				;conditional jump, comparing argc to 6
jne		SKIPerrDSpec					;if rdi != 6, jump SKIPerrDSpec
mov		r12,			qword[rsi+40]	;mov &argv[5] into r12
;error checking, if argv[5] != "-o",NULL, skip to errorOSpec
cmp		byte[r12],		'-'				
jne		errorDSpec
cmp		byte[r12+1],	'd'
jne		errorDSpec
cmp		byte[r12+2],	NULL
jne		errorDSpec
mov		byte[r8],		TRUE
SKIPerrDSpec:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;errISpec, argv[1] == "-i",NULL
mov		r12,	qword[rsi+8]	;mov &argv[1] into r12
;error checking, if argv[1] != "-i",NULL, skip to errorISpec
cmp		byte[r12], 		'-'				
jne		errorISpec
cmp		byte[r12+1],	'i'
jne		errorISpec
cmp		byte[r12+2],	NULL
jne		errorISpec

;ARGV[1] WRITTEN ACCEPTABLY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;errOpenIN, argv[2] = "<inputFileName>.txt",NULL
push 	rdi						;preserve regsiter state in stack
push	rsi						;preserve regsiter state in stack
mov		rax,	SYS_open		;SYS_open call code
mov		rdi,	qword[rsi+16]	;SYS_open arg #1, rdi = &argv[2], file name
mov		rsi,	O_RDONLY		;SYS_open arg #2, rsi = read file only
push	rcx
push	rdx
syscall							;syscall to attempt to open file using argv[2]
pop		rdx
pop		rcx
pop 	rsi						;return preserved regsiter state from stack
pop		rdi						;return preserved regsiter state from stack
cmp		rax,	0				;conditional jump, comparing syscall return value to 0
jl		errorOpenIn				;if rax < 0, skip to errorOpenIn
mov		byte[rdx],	al				;return input file's file descriptor to main by reference using rdx

;ARGV[2] SUCCESSFULLY OPENS INPUT FILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;errOSpec, argv[3] = "-o",NULL
mov		r12,			qword[rsi+24]	;mov &argv[3] into r12
;error checking, if argv[1] != "-o",NULL, skip to errorOSpec
cmp		byte[r12],		'-'
jne		errorOSpec
cmp		byte[r12+1],	'o'
jne		errorOSpec
cmp		byte[r12+2],	NULL
jne		errorOSpec

;ARGV[3] WRITTEN ACCEPTABLY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;errOpenOut, argv[4] = "<outputFileName>.txt",NULL
;CONFIRM OUTPUT FILE CONTAINS ACCEPTABLE FILE EXTENSION (.txt)
mov		r12,	qword[rsi+32]		;mov &argv[4] into r12
mov		r10,	0					;character array iterator, i
mov		r11,	FALSE				;periodBoolean, if '.' appears in argv[4]'s string, boolean set to TRUE
jmp		checkFileExtension			;skip to start of checkFileExtension loop for first iteration
periodFound:
mov		r11,	TRUE				;if '.' appears in string, set boolean to true
incrementIterator:
inc		r10							;increment the character array iterator, i
checkFileExtension:
cmp		byte[r12+r10],		NULL	;conditional jump, comparing argv[4][i] to NULL
je		errorOpenOut				;if byte[r12+10] PREMATURELY == NULL, skip to errorOpenOut
cmp		r11,				TRUE	;conditional jump, comparing periodBoolean to TRUE
je		checkForTXT					;if r11 == TRUE, skip to checkForTXT;
cmp		byte[r12+r10],		'.'		;otherwise, conditional jump, comparing argv[4][i] to '.' 
jne		incrementIterator			;if byte[r12+10] != '.', jump back to checkFileExtension for next loop iteration until '.' is found in the string
checkForTXT:
inc		r10							;increment character array iterator to the next index
;error checking, if argv[4]'s file extension != "txt",NULL, skip to errorOpenOut
cmp		byte[r12+r10], 		't'
jne		errorOpenOut	
cmp		byte[r12+r10+1], 	'x'
jne		errorOpenOut
cmp		byte[r12+r10+2],	't'
jne		errorOpenOut
cmp		byte[r12+r10+3], 	NULL
jne		errorOpenOut
add		r10,	3
ESCcheckFileExtension:
cmp		r10,	5					;conditinal jump, comparing character array iterator to 5
jb		errorOpenOut				;if r10 < 5, skip to errorOpenOut
;"a.txt",NULL
; 12345  6		minimum string count
; 01234  5		iterator minimum				

;ARGV[4] HAS ACCEPTABLE FILE NAME AND FILE EXTENSION (argv[4] = "<fileName>.txt",NULL)

push	rdi						;preserve regsiter state in stack
push	rsi						;preserve regsiter state in stack
mov		rax,	SYS_creat		;SYS_creat call code, 85
mov		rdi,	qword[rsi+32]	;SYS_creat arg #1, rdi = &argv[4], file name
mov		rsi,	S_IRWXU			;SYS_creat arg #2, rsi = read and write to created file
push 	rcx
push	rdx
syscall							;syscall to attempt to open file using argv[4]
pop		rdx
pop		rcx
pop		rsi						;return preserved regsiter state from stack
pop		rdi						;return preserved regsiter state from stack
cmp		rax,	0				;conditional jump, comparing rax to 0
jl		errorOpenOut			;if rax < 0, skip to errorOpenOut
mov		byte[rcx],	al				;return output file's file descriptor to main by reference using rcx

;ARGV[4] SUCCESSFULLY OPENED OUTPUT FILE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Input and output files successfully opened
mov		rax,	TRUE
jmp		ESCgetArguments

errorUsageMessage:
	mov		rdi,	usageMsg
	jmp		ESCerror
errorMany:
	mov		rdi,	errMany
	jmp		ESCerror
errorFew:
	mov		rdi,	errFew
	jmp		ESCerror
errorDSpec:
	mov		rdi,	errDSpec
	jmp		ESCerror
errorISpec:
	mov		rdi,	errISpec
	jmp		ESCerror
errorOSpec:
	mov		rax,	SYS_close
	mov		rdi,	rdx
	syscall
	mov		rdi,	errOSpec
	jmp		ESCerror
errorOpenIn:
	mov		rdi,	errOpenIn
	jmp		ESCerror
errorOpenOut:
	mov		rax,	SYS_close
	mov		rdi,	rdx
	syscall
	mov		rdi,	errOpenOut
	jmp		ESCerror
ESCerror:
call 	printString	;printString arg #1: rdi = &errorString
mov		rax, 	FALSE

ESCgetArguments:
pop 	r12		;return preserved regsiter state from stack
ret

; ======================================================================
;  Simple function to convert an integer to a NULL terminated
;	ASCII/binary string.  Expects a 33 character string
;	(32 characters and NULL) to be returned.

; -----
;  HLL Call
;	int2aBin(int, &str);

; -----
;  Arguments passed:
;	1) integer value			rdi
;	2) string, address			rsi

; -----
;  Returns
;	1) string (via passed address)



global int2aBin
int2aBin:
push 	rax		;preserve regsiter state in stack
push 	rdx		;preserve regsiter state in stack
push	r12		;preserve regsiter state in stack
push 	r13		;preserve regsiter state in stack

mov		rax,	rdi				;Moving integer into rax for division operation
mov		r10,	2				;Divisor = 2
mov		r11,	0				;loop iteration count
mov		r12,	0				;register to store and push characters onto the stack
mov		r13,	32				;max binary integer length

;CONVERT DECIMAL INTEGER INTO UNSIGNED BINARY INTEGER
convertDecimal2Binary:
mov		rdx,	0				;unsigned widen edx:eax
;cmp		r11,	32
;je		errorStringLength
div		r10						;unsigned division, edx:eax/r10 = eax; remainder = edx
checkRemainder:
mov		r12b, 	'0'				;for loop iteration, re-initialize r12b to '0'
cmp		rdx,	1				;conditional jump, comparing division remainder to 1
jne		pushBinaryDigitChar		;if rdx != 1, skip to pushBinaryDigitChar
mov		r12b,	'1'				;otherwise, assign r12b '1'
pushBinaryDigitChar:
inc		r11						;increment the loop iteration counter, i++
push	r12						;push the character within r12b onto the stack
checkQuotient:
cmp		rax,	0				;conditional jump, comparing division's quotient to 0
jne		convertDecimal2Binary	;if rax != 0, loop back to convertDecimal2Binary for next loop iteration until rax == 0

;DECIMAL INTEGER SUCCESSFULLY CONVERTED INTO UNSIGNED BINARY INTEGER IN STACK

;WRITE LEADING ZEROS TO STRING
sub		r13,	r11				;r13 = 32 - r11
mov		r10,	0				;char array iterator, j
insertLeadingZeros:
cmp		r10,	r13				;conditional jump, comparing i to r13
je		ESCinsertLeadingZeros	;if r10 == r13, escape loop to ESCinsertLeadingZeros
mov		byte[rsi+r10], '0'		;binaryStr[j] = '0'
inc		r10						;increment char array iterator, j++
jmp		insertLeadingZeros		;loop back to insertLeadingZeros for next loop iteration
ESCinsertLeadingZeros:

;LEADING ZEROS HAVE BEEN WRITTEN TO STRING

;POP CHARACTERS FROM STACK AND INSERT THEM INTO THE STRING
insertCharFromStack:
cmp		r10,	32				;Conditional jump, comparing char array iterator to 32
je		ESCinsertCharFromStack	;if	r10 == 32, escape loop to ESCinsertCharFromStack
pop		r12						;pop char from stack into r12
mov		byte[rsi+r10],	r12b	;binaryStr[j] = char
inc		r10						;increment char array iterator, j
jmp		insertCharFromStack		;loop back to insertCharFromStack for next iteration
ESCinsertCharFromStack:

mov		byte[rsi+r10],	NULL	;append NULL to binaryStr

pop		r13		;return preserved regsiter state from stack
pop 	r12		;return preserved regsiter state from stack
pop		rdx		;return preserved regsiter state from stack
pop		rax		;return preserved regsiter state from stack
ret

; ======================================================================
;  Count leading digits....
;	Check the leading digit for each number and count 
;	each 0, 1, 2, etc...
;	The counts (0-9) are stored in an array.

;  This function reads the file (only place where file is read).
;  For efficiency, this function must perform buffered I/O

; -----
;  High level language call:
;	countDigits (rdFileDesc, &digitCounts)

; -----
;  Arguments passed:
;	value for input file descriptor		rdi
;	address for digits array			rsi
;	void function, no return

;Algorithm, General Idea
;check buffer status
;if empty
;read buffer (buffer size)
;if error - handle read error, display error message, exit
;reset pointers
;if characters actually read < characters request to read
;set EOF_reached = TRUE
;get character from buffe

global countDigits
countDigits:
push	rdi
push	rsi
push	r12				;preserve register state in stack
push	r13				;preserve register state in stack
push	r14				;preserve register state in stack
mov		r12,	rdi		;store input file descriptor value in r12
mov		r13,	rsi		;store array digitCounts' addresss in r13
push	rbx
push	rcx
push	rdx




checkBuffer:
mov		r11,		qword[bfMax]
cmp		qword[curr], r11					;Conditional jump, comparing current iterator value to BUFFSIZE
jb		readBuffer								;if qword[curr] < BUFFSIZE, skip to readBuffer
readNewBufferLoad:
mov		rax,	SYS_read						;SYS_read call code, 0
mov		rdi,	r12								;SYS_read arg #1, rdi = input file descriptor value
mov		rsi,	buff							;SYS_read arg #2, rsi = buff array's address to store input
mov		rdx,	BUFFSIZE						;SYS_read arg #3, rdx = count of characters to read
syscall
checkErrorOrEOF:
mov		qword[curr],	0						;assign 0 to current iterator
cmp		rax,	0								;Conditional jump, comparing SYS_write return value to 0
jl		errorFileRead							;if rax < 0, skip to errorFileRead
mov		qword[bfMax],		rax
cmp		rax,				BUFFSIZE			;Conditional jump, comparing SYS_write read count value to BUFFSIZE
je		bufferHasNotReachedEOF					;if rax == BUFFSIZE, skip to bufferHasNotReachedEOF
mov		byte[wasEOF],		TRUE				;otherwise, assign wasEOF TRUE
bufferHasNotReachedEOF:

cmp		byte[headerSkipBool],	TRUE
je		readBuffer
mov		byte[headerSkipBool],	TRUE
mov		r10,				0					;LF count
headerSkip:
mov		r11,				qword[curr]			;current iterator value into r11
cmp		r10,				SKIP_LINES
je		ESCheaderSkip
cmp		byte[buff+r11],		LF
jne		LFskip
inc		r10
LFskip:
inc		qword[curr]
jmp		headerSkip
ESCheaderSkip:
inc		qword[curr]


readBuffer:
mov		r11,				qword[bfMax]
cmp		qword[curr],		r11
jae		EOFboolCheck
;iterate through line in buffer (until a LF is found)chekcn
skip6Char:
add		qword[curr], 6
jmp		skipSpaces
incSpaces:
inc		qword[curr]
skipSpaces:
mov		r10,				0
mov		r11,				qword[curr]
cmp		byte[buff+r11], 	SPACE
je		incSpaces
mov		r10b,				byte[buff+r11]
sub		r10b,				'0'
inc		dword[r13+r10*4]
skipToNextLine:
inc		qword[curr]
mov		r11,				qword[curr]
cmp		byte[buff+r11],		LF
jne		skipToNextLine
inc		qword[curr]
jmp		readBuffer



EOFboolCheck:
cmp		byte[wasEOF],		TRUE
jne		checkBuffer
jmp		ESCcountDigits


errorFileRead:
mov		rdi,			errFileRead
push 	rax
push	rdx
call 	printString
pop		rdx
pop		rax

ESCcountDigits:

mov		rax,	SYS_close
mov		rdi,	r12
syscall



pop		rdx
pop		rcx
pop		rbx
pop		r14		;return preserved register state from stack
pop		r13		;return preserved register state from stack
pop		r12		;return preserved register state from stack
pop		rsi
pop		rdi
ret





; ======================================================================
;  Generic function to write a string to an already opened file.
;  Similar to printString(), but must handle possible file write error.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters to file

;  Arguments:
;	file descriptor, value		rdi
;	address, string				rsi
;  Returns:
;	nothing


global writeString
writeString:
push	rdx		;preserve regsiter state in stack

mov		rdx,	0				;char array iterator, i
countCharInStr:
cmp		byte[rsi+rdx],	NULL	;Conditional jump, comparing str[i] to NULL
je		ESCcountCharInStr		;if byte[rsi+r10] == NULL, escape from loop
inc		rdx						;increment char array iterator, i++
jmp		countCharInStr			;loop back to countCharInStr for next loop iteration
ESCcountCharInStr:

cmp		rdx,	0
je		writeDone

inc 	rdx						;increment loop iterator one last time (count = max_index + 1)
mov		rax,	SYS_write		;SYS_write call code
;rdi = file descriptor value	;SYS_write arg #1: the output file's file descriptor
;rsi = string address			;SYS_write arg #2: address of characters to write
;rdx = string length value		;SYS_write arg #3: count of characters to write
syscall							;Call SYS_write system service

writeDone:
pop		rdx		;return preserved regsiter state from stack
ret

; ======================================================================
;  Generic function to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

; -----
;  HLL Call:
;	printString(stringAddr);

;  Arguments:
;	1) address, string rdi
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

