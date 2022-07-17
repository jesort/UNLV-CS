###########################################################################
#  Name: 
#  NSHE ID: 
#  Section:	
#  Assignment: MIPS #3
#  Description: Become familiar iwth the MIPS Instruction Set, and the MIPS functin calling convention, and indexing for multiple dimension arrays.

#  MIPS assembly language program to check for
#  a magic square.


###########################################################
#  data segment

.data

hdr:		.asciiz	"\nProgram to check a Magic Square. \n\n"

# -----
#  Possible Magic Square #1

msq1:		.word	2, 7, 6
		.word	9, 5, 1
		.word	4, 3, 8
ord1:		.word	3

# -----
#  Possible Magic Square #2

msq2:		.word	16,  3,  2, 13
		.word	 5, 10, 11,  8
		.word	 9,  6,  7, 12
		.word	 4, 15, 14,  1
ord2:		.word	4

# -----
#  Possible Magic Square #3

msq3:		.word	16,  3,  2, 13
		.word	 5, 10, 11,  8
		.word	 9,  5,  7, 12
		.word	 4, 15, 14,  1
ord3:		.word	4

# -----
#  Possible Magic Square #4

msq4:		.word	21,  2,  8, 14, 15
		.word	13, 19, 20,  1,  7
		.word	 0,  6, 12, 18, 24
		.word	17, 23,  4,  5, 11
		.word	 9, 10, 16, 22,  3
ord4:		.word	5

# -----
#  Possible Magic Square #5

msq5:		.word	64, 12, 23, 61, 60, 35, 17, 57
		.word	19, 55, 54, 12, 13, 51, 55, 16
		.word	17, 47, 46, 21, 20, 43, 42, 24
		.word	41, 26, 27, 37, 36, 31, 30, 33
		.word	32, 34, 35, 29, 28, 38, 39, 25
		.word	40, 23, 22, 44, 45, 19, 18, 48
		.word	49, 15, 14, 52, 53, 11, 10, 56
		.word	18, 58, 59, 46, 24, 62, 63, 11
ord5:		.word	8

# -----
#  Possible Magic Square #6

msq6:		.word	 9,  6,  3, 16
		.word	 4, 15, 10,  5
		.word	14, 1,  8, 11
		.word	 7, 12, 13, 1
ord6:		.word	4

# -----
#  Possible Magic Square #7

msq7:		.word	64,  2,  3, 61, 60,  6,  7, 57
		.word	 9, 55, 54, 12, 13, 51, 50, 16
		.word	17, 47, 46, 20, 21, 43, 42, 24
		.word	40, 26, 27, 37, 36, 30, 31, 33
		.word	32, 34, 35, 29, 28, 38, 39, 25
		.word	41, 23, 22, 44, 45, 19, 18, 48
		.word	49, 15, 14, 52, 53, 11, 10, 56
		.word	 8, 58, 59,  5,  4, 62, 63,  1
ord7:		.word	8


# -----
#  Local variables for print header routine.

ds_hdr:		.ascii	"\n-----------------------------------------------------"
		.asciiz	"\nPossible Magic Square #"

nlines:		.asciiz	"\n\n"


# -----
#  Local variables for check magic square.

TRUE = 1
FALSE = 0

rw_msg:		.asciiz	"    Row  #"
cl_msg:		.asciiz	"    Col  #"
d_msg:		.asciiz	"    Diag #"

no_msg:		.asciiz	"\nNOT a Magic Square.\n"
is_msg:		.asciiz	"\nIS a Magic Square.\n"


# -----
#  Local variables for prt_sum routine.

sm_msg:		.asciiz	"   Sum: "


# -----
#  Local variables for prt_matrix function.

newLine:	.asciiz	"\n"

blnks1:		.asciiz	" "
blnks2:		.asciiz	"  "
blnks3:		.asciiz	"   "
blnks4:		.asciiz	"    "
blnks5:		.asciiz	"     "
blnks6:		.asciiz	"      "


###########################################################
#  text/code segment

.text

.globl main
.ent main
main:

# -----
#  Display main program header.

	la	$a0, hdr
	li	$v0, 4
	syscall					# print header

# -----
#  Set data set counter.

	li	$s0, 0

# -----
#  Check Magic Square #1

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq1
	lw	$a1, ord1
	jal	prtSquare

	la	$a0, msq1
	lw	$a1, ord1
	jal	chkMagicSqr

# -----
#  Check Magic Square #2

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq2
	lw	$a1, ord2
	jal	prtSquare

	la	$a0, msq2
	lw	$a1, ord2
	jal	chkMagicSqr

# -----
#  Check Magic Square #3

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq3
	lw	$a1, ord3
	jal	prtSquare

	la	$a0, msq3
	lw	$a1, ord3
	jal	chkMagicSqr

# -----
#  Check Magic Square #4

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq4
	lw	$a1, ord4
	jal	prtSquare

	la	$a0, msq4
	lw	$a1, ord4
	jal	chkMagicSqr

# -----
#  Check Magic Square #5

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq5
	lw	$a1, ord5
	jal	prtSquare

	la	$a0, msq5
	lw	$a1, ord5
	jal	chkMagicSqr

# -----
#  Check Magic Square #6

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq6
	lw	$a1, ord6
	jal	prtSquare

	la	$a0, msq6
	lw	$a1, ord6
	jal	chkMagicSqr

# -----
#  Check Magic Square #7

	addu	$s0, $s0, 1
	move	$a0, $s0
	jal	prtHeader

	la	$a0, msq7
	lw	$a1, ord7
	jal	prtSquare

	la	$a0, msq7
	lw	$a1, ord7
	jal	chkMagicSqr

# -----
#  Done, terminate program.

	li	$v0, 10
	syscall

.end main


# -------------------------------------------------------
#  Function to check if a two-dimensional array
#  is a magic square.

#  Algorithm:
#	Find sum for first row

#	Check sum of each row (n row's)
#	  if any sum not equal initial sum, set NOT magic square.
#	Check sum of each column (n col's)
#	  if any sum not equal initial sum, set NOT magic square.
#	Check sum of main diagonal 1
#	  if sum not equal initial sum, set NOT magic square.
#	Check sum of main diagonal 2
#	  if sum not equal initial sum, set NOT magic square.

# -----
#  Formula for multiple dimension array indexing:
#	addr(row,col) = base_address + (rowindex * col_size
#					+ colindex) * element_size

# -----
#  Arguments
#	$a0 - address of two-dimension two-dimension array
#	$a1 - order/size of two-dimension array

.globl 	chkMagicSqr
.ent	chkMagicSqr
chkMagicSqr:
# rw_msg:		.asciiz	"    Row  #"
# cl_msg:		.asciiz	"    Col  #"
# d_msg:		.asciiz	"    Diag #"
# no_msg:		.asciiz	"\nNOT a Magic Square.\n"
# is_msg:		.asciiz	"\nIS a Magic Square.\n"
#	$a0 - message (address)
#	$a1 - row/col/diag number (value)
#	$a2 - sum
subu	$sp,	$sp,	32
sw		$s0,	($sp)
sw		$s1,	4($sp)
sw		$s2,	8($sp)
sw		$s3,	12($sp)
sw		$s4,	16($sp)
sw		$s5,	20($sp)
sw		$s6,	24($sp)
sw		$ra,	28($sp)
move	$s0,	$a0			# 2Darray start address
move	$s1,	$a1			# order
li		$s2,	1		# (T/F) isMagicSquareBool
li		$s3,	0			# row
li		$s4,	0			# column
li		$s5,	0			# magicSum
li		$s6,	0		# (F/T) intialSumBool set? 
li		$t2,	0			# tempSum
calcRow:
mulou	$t0,	$s3,	$s1			# t0 = row*order
add		$t0,	$t0,	$s4 		# t0 = (row*order)+column
mulou	$t0,	$t0,	4			# t0 = ((row*order)+column)*4
add		$t1,	$s0,	$t0 		# t1 = base_address + ((row*order)+column)*4
lw		$t3,	($t1)				# t3 = (base_address + ((row*order)+column)*4)
add		$t2,	$t2,	$t3			# t2 += (2Darray[r][c])
add		$s4,	$s4,	1			# increment column
bltu	$s4,	$s1,	calcRow		# conditional jump, if col < order, jump to calcRow for next loop iteration
beq		$s6,	1,	crBoolSkip	# conditional jump, intialSumBool == TRUE, skip to crBoolSkip
move	$s5,	$t2					# otherwise, magicSum = tempSum
li		$s6,	1				# and initialSumBool = TRUE
crBoolSkip:							
beq		$t2,	$s5,	sumBoolSkip	# conditional jump, if tempSum == magicSum, skip to sumBoolSkip
li		$s2,	0				# otherwise, isMagicSquareBool = FALSE
sumBoolSkip:
la		$a0,	rw_msg				# prtMsg, arg #1: rw_msg string address
add		$a1,	$s3,	0			# prtMsg, arg #2: row value
move	$a2,	$t2					# prtMsg, arg #3: tempSum value
jal		prtMsg						# call prtMsg
li		$t2,	0					# reset tempSum
add		$s3,	$s3,	1			# increment row iterator
li		$s4,	0					# reset column
bltu	$s3,	$s1,	calcRow		# conditional jump, if row < order, jump to calcRow for next loop iteration

# ##################################################

li		$t2,	0			# tempSum
li		$s3,	0			# row = 0
li		$s4,	0			# col = 0
calcCol:
mulou	$t0,	$s3,	$s1			# t0 = row*order
add		$t0,	$t0,	$s4 		# t0 = (row*order)+column
mulou	$t0,	$t0,	4			# t0 = ((row*order)+column)*4
add		$t1,	$s0,	$t0 		# t1 = base_address + ((row*order)+column)*4
lw		$t3,	($t1)				# t3 = (base_address + ((row*order)+column)*4)
add		$t2,	$t2,	$t3			# t2 += (2Darray[r][c])
add		$s3,	$s3,	1			# increment row
bltu	$s3,	$s1,	calcCol		# conditional jump, if row < order, jump to calcCol for next loop iteration					
beq		$t2,	$s5,	sumBoolSkip2	# conditional jump, if tempSum == magicSum, skip to sumBoolSkip
li		$s2,	0					# otherwise, isMagicSquareBool = FALSE
sumBoolSkip2:
la		$a0,	cl_msg				# prtMsg, arg #1: cl_msg string address
add		$a1,	$s4,	0			# prtMsg, arg #2: col+1 value
move	$a2,	$t2					# prtMsg, arg #3: tempSum value
jal		prtMsg						# call prtMsg
li		$t2,	0					# reset tempSum
add		$s4,	$s4,	1			# increment col iterator
li		$s3,	0					# reset row
bltu	$s4,	$s1,	calcCol		# conditional jump, if rowcol < order, jump to calcCol for next loop iteration

# ##################################################

li		$t2,	0			# tempSum
li		$s3,	0			# row = 0
li		$s4,	0			# col = 0
calcRDiagonal:
mulou	$t0,	$s3,	$s1				# t0 = row*order
add		$t0,	$t0,	$s4 			# t0 = (row*order)+column
mulou	$t0,	$t0,	4				# t0 = ((row*order)+column)*4
add		$t1,	$s0,	$t0 			# t1 = base_address + ((row*order)+column)*4
lw		$t3,	($t1)					# t3 = (base_address + ((row*order)+column)*4)
add		$t2,	$t2,	$t3				# t2 += (2Darray[r][c])
add		$s3,	$s3,	1				# increment row
add		$s4,	$s4,	1				# increment col
bltu	$s3,	$s1,	calcRDiagonal	# conditional jump, if row < order, jump to calcRDiagonal for next loop iteration					
beq		$t2,	$s5,	sumBoolSkip3	# conditional jump, if tempSum == magicSum, skip to sumBoolSkip
li		$s2,	0						# otherwise, isMagicSquareBool = FALSE
sumBoolSkip3:
la		$a0,	d_msg					# prtMsg, arg #1: d_msg string address
li		$a1,	1				# prtMsg, arg #2: diagonal 1 value
move	$a2,	$t2						# prtMsg, arg #3: tempSum value
jal		prtMsg							# call prtMsg
li		$t2,	0						# reset tempSum

# ##################################################

li		$t2,	0			# tempSum
li		$s3,	0			# row = 0
sub		$s4,	$s1,	1	# col = order-1
calcLDiagonal:
mulou	$t0,	$s3,	$s1				# t0 = row*order
add		$t0,	$t0,	$s4 			# t0 = (row*order)+column
mulou	$t0,	$t0,	4				# t0 = ((row*order)+column)*4
add		$t1,	$s0,	$t0 			# t1 = base_address + ((row*order)+column)*4
lw		$t3,	($t1)					# t3 = (base_address + ((row*order)+column)*4)
add		$t2,	$t2,	$t3				# t2 += (2Darray[r][c])
add		$s3,	$s3,	1				# increment row
sub		$s4,	$s4,	1				# increment col
bltu	$s3,	$s1,	calcLDiagonal	# conditional jump, if row < order, jump to calcRDiagonal for next loop iteration					
beq		$t2,	$s5,	sumBoolSkip4	# conditional jump, if tempSum == magicSum, skip to sumBoolSkip
li		$s2,	0						# otherwise, isMagicSquareBool = FALSE
sumBoolSkip4:
la		$a0,	d_msg					# prtMsg, arg #1: d_msg string address
li		$a1,	2					# prtMsg, arg #2: diagonal 2 value
move	$a2,	$t2						# prtMsg, arg #3: tempSum value
jal		prtMsg							# call prtMsg
li		$t2,	0						# reset tempSum

# ##################################################

printBoolResult:
beq		$s2,	1,	printBoolSkip
la		$a0,	no_msg
b		printBoolSkip2
printBoolSkip:
la 		$a0,	is_msg
printBoolSkip2:
li		$v0,	4
syscall

lw		$s0,	($sp)
lw		$s1,	4($sp)
lw		$s2,	8($sp)
lw		$s3,	12($sp)
lw		$s4,	16($sp)
lw		$s5,	20($sp)
lw		$s6,	24($sp)
lw		$ra,	28($sp)
addu	$sp,	$sp,	32
jr	$ra
.end	chkMagicSqr
# -------------------------------------------------------
#  Function to display sum message.

# -----
#  Arguments:
#	$a0 - message (address)
#	$a1 - row/col/diag number (value)
#	$a2 - sum

.globl	prtMsg
.ent	prtMsg
prtMsg:
subu	$sp,	$sp,	12
sw		$s0,	($sp)
sw		$s1,	4($sp)
sw		$s2,	8($sp)

move	$s0,	$a0
move	$s1,	$a1
move	$s2,	$a2

# print message
move	$a0,	$s0
li		$v0,	4
syscall

# print row/col/diag number (value)
move	$a0,	$s1
li		$v0,	1
syscall

# print sum message
la		$a0,	sm_msg
li		$v0,	4
syscall

# print sum (value)
move	$a0,	$s2
li		$v0,	1
syscall

# print new line
la		$a0,	newLine
li		$v0,	4
syscall

lw		$s0,	($sp)
lw		$s1,	4($sp)
lw		$s2,	8($sp)
addu	$sp,	$sp,	12
jr	$ra
.end	prtMsg

# ---------------------------------------------------------
#  Display simple header for data set (as per asst spec's).

.globl	prtHeader
.ent	prtHeader
prtHeader:
	subu	$sp, $sp, 4
	sw	$s0, ($sp)

	move	$s0, $a0

	la	$a0, ds_hdr
	li	$v0, 4
	syscall

	move	$a0, $s0
	li	$v0, 1
	syscall

	la	$a0, nlines
	li	$v0, 4
	syscall

	lw	$s0, ($sp)
	addu	$sp, $sp, 4

	jr	$ra
.end	prtHeader

# ---------------------------------------------------------
#  Print magic square.
#  Note, a magic square is an N x N array.

#  Arguments:
#	$a0 - starting address of square to ptint
#	$a1 - order (size) of the square
.globl 	prtSquare
.ent	prtSquare
prtSquare:
subu	$sp,	$sp,	20
sw		$s0,	($sp)
sw		$s1,	4($sp)
sw		$s2,	8($sp)
sw		$s3,	12($sp)
sw		$s4,	16($sp)

move	$s0,	$a0				# 2Darray starting address
move	$s1,	$a1				# order
li		$s2,	0				# row
li		$s3,	0				# column
prtSquareLoop:
move	$s4,	$s0				# 2Darray[][]
move	$t0,	$s2				# t0 = row		
mulou	$t0,	$t0,	$s1		# t0 = row*order
add		$t0,	$t0,	$s3		# t0 = row*order+col
mulou	$t0,	$t0,	4		# t0 = (row*order+col)*4
add		$s4,	$s4,	$t0		# 2Darray[r][c] = baseAddress + (row*order+col)*4
lw		$t1,	($s4)			# t1 = (2Darray[r][c])
li		$t2,	6				# digit count
countDigits:
div		$t1,	$t1,	10		# divide (2Darray[r][c]) by 10 until quotient equals 0
sub		$t2,	$t2,	1		# decrement the amount of spaces to print
bnez	$t1,	countDigits

# "switch" block to determine spaces string to print to console
fiveSpaces:
bltu	$t2,	5,		fourSpaces
la		$a0,	blnks5
b		ESCnumSpaces
fourSpaces:
bltu	$t2,	4,		threeSpaces
la		$a0,	blnks4
b		ESCnumSpaces
threeSpaces:
bltu	$t2,	3,		twoSpaces
la		$a0,	blnks3
b		ESCnumSpaces
twoSpaces:
bltu	$t2,	2,		oneSpace
la		$a0,	blnks2
b		ESCnumSpaces
oneSpace:
la		$a0,	blnks1
ESCnumSpaces:
li		$v0,	4
syscall

# print integer
lw		$a0,	($s4)
li		$v0,	1
syscall

add		$s3,	$s3,	1				# increment col
bltu	$s3,	$s1,	prtSquareLoop	# conditional jump, if col < order, jump to prtSquareLoop for next loop iteration
add		$s2,	$s2,	1				# increment row
li		$s3,	0						# reset col to 0

# print new line
la		$a0,	newLine
li		$v0,	4
syscall

bltu	$s2,	$s1,	prtSquareLoop	# conditional jump, if row < order, jump to prtSquareLoop for next loop iteration

la		$a0,	newLine
li		$v0,	4
syscall

lw		$s0,	($sp)
lw		$s1,	4($sp)
lw		$s2,	8($sp)
lw		$s3,	12($sp)
lw		$s4,	16($sp)
addu	$sp,	$sp,	20
jr		$ra
.end	prtSquare
