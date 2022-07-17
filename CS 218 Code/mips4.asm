#  Name: 
#  NSHE ID: 
#  Section:	
#  Assignment: MIPS #4
#  Description: Become familiar with the MIPS Instruction Set, and the MIPS procedure calling convention, and basic recursion.

#  CS 218, MIPS Assignment #4

#  Write a simple assembly language program to
#  compute the Fibonacci and Perrin Sequences.


#####################################################################
#  data segment

.data

# -----
#  Local variables for main.

hdr:		.ascii	"\nMIPS Assignment #4\n"
		.asciiz	"Fibonacci and Perrin Numbers Program"

entNpmt:	.asciiz	"\n\n\nEnter N (3-45, 0 to terminate): "

n:		.word	0
newLine:	.asciiz	"\n"
doneMsg:	.asciiz	"\n\nGame Over, thank you for playing.\n"

# -----
#  Local variables for getNumber() function.

msg0:		.asciiz	"\nThis should be quick.\n"
msg1:		.asciiz	"\nThis is going to take a while (n>20).\n"
msg2:		.asciiz	"\nThis is going to take a long time (n>30).\n"
msg3:		.asciiz	"\nThis going to take a really long time (n>35).\n"
msg4:		.asciiz	"\nThis is going to take a very long time (> 30 minutes).\n"
errMsg:		.asciiz	"\nError, value of range.  Please re-enter.\n"

# -----
#  Local variables for prtNumber() function.

nMsg:		.asciiz	"\nnum = "
fMsg:		.asciiz	"   fibonacci = "
pMsg:		.asciiz	"   perrin = "

# -----
#  Local variables for prtBlanks() routine.

space:		.asciiz	" "


#####################################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Read N (including error checking and display of message).

doAgain:
	jal	getNumber
	sw	$v0, n

	beqz	$v0, allDone

# -----
#  Main loop to generate and display fibonacci and perrin numbers.

	move	$s0, $zero
	lw	$s1, n

loop:
	move	$a0, $s0			# get fibonacci(n)
	jal	fibonacci
	move	$s2, $v0

	move	$a0, $s0			# get perrin(n)
	jal	perrin
	move	$s3, $v0

	move	$a0, $s0			# print output line
	move	$a1, $s2
	move	$a2, $s3
	jal	prtLine

	add	$s0, $s0, 1			# next loop?
	ble	$s0, $s1, loop

	j	doAgain

# -----
#  Done, terminate program.

allDone:
	la	$a0, doneMsg
	li	$v0, 4
	syscall					# print header

	li	$v0, 10
	syscall					# au revoir...

.end main

#####################################################################
#  Get the N value from the user.
#  Peform appropriate error checking and display status message.

# -----
#    Arguments:
#	none

#    Returns:
#	N value ($v0)

.globl 	getNumber
.ent	getNumber
getNumber:
subu	$sp, 	$sp,	4
sw		$s0,	($sp)
requestInput:
# output entNmpt string
la		$a0,	entNpmt
li		$v0,	4
syscall

# request user input
li		$v0,	5
syscall

# preserve user's input into $s0
move	$s0,	$v0

# print new line
la		$a0,	newLine
li		$v0,	4
syscall

# error checking and selecting approriate output message for user's given input
beqz	$s0,	ESCgetNumber
blt		$s0,	3,				errorSize	# if n < 3, skip to errorSize
bgt		$s0,	45,				errorSize	# if n > 45, skip to errorSize
bgt		$s0,	35,				numGt35     # if 35 < n <= 45, skip to numGt35 
bgt		$s0,	30,				numGt30		# if 30 < n <= 35, skip to numGt30
bgt		$s0,	25,				numGt20		# if 25 < n <= 30, skip to numGt20
ble		$s0,	25,				numLtEq20	# if 3 <= n <= 25, skip to numLtEq20

# n < 3 || n > 45
errorSize:
la		$a0,	errMsg
li		$v0,	4
syscall
b		requestInput
numLtEq20:
la		$a0,	msg0
b		gMprintMessage
numGt20:
la		$a0,	msg1
b		gMprintMessage
numGt30:
la		$a0,	msg2
b		gMprintMessage
numGt35:
la		$a0,	msg4
b		gMprintMessage
gMprintMessage:
li		$v0,	4
syscall

ESCgetNumber:
move	$v0,	$s0
lw		$s0,	($sp)
addu	$sp,	$sp,	4
jr	$ra
.end getNumber

#####################################################################
#  Display fibonacci sequence.

# -----
#    Arguments:
#	$a0 - n

#    Returns:
#	fibonacci(n)

.globl	fibonacci
.ent	fibonacci
fibonacci:
subu	$sp,	$sp,	12
sw		$s0,	($sp)
sw		$s1,	4($sp)
sw		$ra,	8($sp)
move	$s0,	$a0
li		$s1,	0						# (n) = 0

ble		$s0,	1,		fibBaseCase		# if n <= 1, skip to fibBaseCase

fibGeneralCase:
sub		$a0,	$s0,	1				# a0 = n-1
jal		fibonacci						# Recursive call fibonacci(n-1)
add		$s1,	$s1,	$v0				# fibonacci(n) += fibonacci(n-1)'s return
sub		$a0,	$s0,	2				# a0 = n-2
jal		fibonacci						# Recursive call fibonacci(n-2)
add		$s1,	$s1,	$v0				# fibonacci(n) += fibonacci(n-2)'s return
move	$v0,	$s1						# function return value = fibonacci(n)
b		ESCfibonacci

fibBaseCase:
move	$v0,	$s0						# function return value = fibonacci(0) or fibonacci(1)

ESCfibonacci:

lw		$s0,	($sp)
lw		$s1,	4($sp)
lw		$ra,	8($sp)
addu	$sp,	$sp,	12
jr		$ra
.end	fibonacci






#####################################################################
#  Display perrin sequence.

# -----
#    Arguments:
#	$a0 - n

#    Returns:
#	perrin(n)


.globl	perrin
.ent	perrin
perrin:
subu	$sp,	$sp,	12
sw		$s0,	($sp)
sw		$s1,	4($sp)
sw		$ra,	8($sp)
move	$s0,	$a0
li		$s1,	0					# perrin(n) = 0

beqz	$s0,	pBaseCase0			# if n == 0, skip to pBaseCase0
beq		$s0,	1,		pBaseCase1	# if n == 1, skip to pBaseCase1
beq		$s0,	2,		pBaseCase2	# if n == 2, skip to pBaseCase2

pGeneralCase:
sub		$a0,	$s0,	2			# a0 = n-2
jal		perrin						# Recursive call perrin(n-2)
add		$s1,	$s1,	$v0			# perrin(n) += perrin(n-2)'s return
sub		$a0,	$s0,	3			# a0 = n-3
jal		perrin						# Recursive call perrin(n-3)
add		$s1,	$s1,	$v0			# perrin(n) += perrin(n-3)'s return
move	$v0,	$s1					# function return value = perrin(n)
b		ESCperrin

pBaseCase0:
li		$v0,	3	# function return value = perrin(0)
b		ESCperrin
pBaseCase1:
li		$v0,	0	# function return value = perrin(1)
b		ESCperrin
pBaseCase2:
li		$v0,	2	# function return value = perrin(2)

ESCperrin:

lw		$s0,	($sp)
lw		$s1,	4($sp)
lw		$ra,	8($sp)
addu	$sp,	$sp,	12
jr		$ra
.end	perrin

#####################################################################
#  Print a line as per asst #4 specificiations.

# -----
# Line should look like:
#	num =  0   fibonacci =          0   perrin = 3

# Format:
#	numB=BnnBBBfibonacciB=BffffffffffBBBperrinB=Bppppppp

#	where	B = blank space
#		f = actual fibonacci number (123...)
#		p = actual perrin number (123...)

# Note,	num will always be 1-2 digits.
#	fibonacci will always b 1-10 digits.
#	perrin will always be 1-7 digits.

# -----
#  Arguments:
#	$a0 - N number (value)
#	$a1 - fibonacci number (value)
#	$a2 - perrin number (value)

.globl	prtLine
.ent	prtLine
prtLine:
subu	$sp,	$sp,	16
sw		$s0,	($sp)
sw		$s1,	4($sp)
sw		$s2,	8($sp)
sw		$ra,	12($sp)
move	$s0,	$a0			# s0 = N number, max 2 digits
move	$s1,	$a1			# s1 = fibonacci number, max 10 digits
move	$s2,	$a2			# s2 = perrin number, max 7 digits

# numB=B nn BBBfibonacciB=B ffffffffff BBBperrinB=B ppppppp
# print "numB=B"
la		$a0,	nMsg
li		$v0,	4
syscall

# print "nn"
move	$a0,	$s0
li		$a1,	2
jal		prtBlnks
move	$a0,	$s0
li		$v0,	1
syscall

# print "BBBfibonacciB=B"
la		$a0,	fMsg
li		$v0,	4
syscall

# print "ffffffffff"
move	$a0,	$s1
li		$a1,	10
jal		prtBlnks
move	$a0,	$s1
li		$v0,	1
syscall

# print "BBBperrinB=B"
la		$a0,	pMsg
li		$v0,	4
syscall

# print "ppppppp"
move	$a0,	$s2
li		$a1,	7
jal		prtBlnks
move	$a0,	$s2
li		$v0,	1
syscall

lw		$s0,	($sp)
lw		$s1,	4($sp)
lw		$s2,	8($sp)
lw		$ra,	12($sp)
addu	$sp,	$sp,	16
jr		$ra
.end	prtLine
#####################################################################
#  Print an appropriate number of blanks based on
#  size of the number.

# -----
#  Arguments:
#	$a0 - number (value)
#	$a1 - max number of digits for number (value)


.globl 	prtBlnks
.ent	prtBlnks
prtBlnks:
subu	$sp,	$sp,	4
sw		$s0,	($sp)


countDigits:
div		$a0,	$a0,	10			# a0 /= 10
subu	$a1,	$a1,	1			# numOfSpacesToPrint--
bnez	$a0,	countDigits			# if a0 != 0, jump to countDigits for next loop iteration
move	$s0,	$a1					# preserve numOfSpacesToPrint int0 $s0

blez	$s0,	ESCprtBlnks			# if numOfSpacesToPrint <= 0, skip to ESCprtBlnks

printBlanksLoop:
la		$a0,	space				# space address
li		$v0,	4					# print string call code
syscall								# print single space
subu	$s0,	$s0,	1			# decrement the number of spaces left 
bnez	$s0,	printBlanksLoop		# if $s0 != 0, jump to printBlanksLoop for next loop iteration

ESCprtBlnks:

lw		$s0,	($sp)
addu	$sp,	$sp,	4
jr		$ra
.end	prtBlnks

#####################################################################

