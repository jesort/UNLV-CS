# *****************************************************************
#  Name: 
#  NSHE ID: 
#  Section:	
#  Assignment: MIPS #1
#  Description: Become familiar with RISC Architecture concepts, the MIPS Architecture, and QtSpim (the MIPS simulator)




#  CS 218, MIPS Assignment #1
#  Provided Template

###########################################################
#  data segment

.data

aSides:		.word	   31,    21,    15,    28,    37
		.word	   10,    14,    13,    37,    54
		.word	  -31,   -13,   -20,   -61,   -36
		.word	   14,    53,    44,    19,    42
		.word	  -27,   -41,   -53,   -62,   -10
		.word	   19,    28,    24,    10,    15
		.word	  -15,   -11,   -22,   -33,   -70
		.word	   15,    23,    15,    63,    26
		.word	  -24,   -33,   -10,   -61,   -15
		.word	   14,    34,    13,    71,    81
		.word	  -38,    73,    29,    17,    93

bSides:		.word	  101,   132,   111,   121,   142
		.word	  133,   114,   173,   131,   115
		.word	 -164,  -173,  -174,  -123,  -156
		.word	  144,   152,   131,   142,   156
		.word	 -115,  -124,  -136,  -175,  -146
		.word	  113,   123,   153,   167,   135
		.word	 -114,  -129,  -164,  -167,  -134
		.word	  116,   113,   164,   153,   165
		.word	 -126,  -112,  -157,  -167,  -134
		.word	  117,   114,   117,   125,   153
		.word	 -123,   173,   115,   106,   113

cSides:		.word	 1234,  1111,  1313,  1897,  1321
		.word	 1145,  1135,  1123,  1123,  1123
		.word	-1254, -1454, -1152, -1164, -1542
		.word	 1353,  1457,   182,  1142,  1354
		.word	-1364, -1134, -1154, -1344, -1142
		.word	 1173,  1543,  1151,  1352,  1434
		.word	-1355, -1037,  -123, -1024, -1453
		.word	 1134,  2134,  1156,  1134,  1142
		.word	-1267, -1104, -1134, -1246, -1123
		.word	 1134,  1161,  1176,  1157,  1142
		.word	-1153,  1193,  1184,  1142,  2034

volumes:	.space	220

len:		.word	55

vMin:		.word	0
vMid:		.word	0
vMax:		.word	0
vSum:		.word	0
vAve:		.word	0

# -----

hdr:		.ascii	"MIPS Assignment #1 \n"
		.ascii	"  Program to calculate the volume of each rectangular \n"
		.ascii	"  parallelepiped in a series of rectangular parallelepipeds.\n"
		.ascii	"  Also finds min, mid, max, sum, and average for volumes.\n"
		.asciiz	"\n"

sHdr:		.asciiz	"  Volumes: \n"

newLine:	.asciiz	"\n"
blnks:		.asciiz	"     "

minMsg:		.asciiz	"  Volumes Min = "
midMsg:		.asciiz	"  Volumes Mid = "
maxMsg:		.asciiz	"  Volumes Max = "
sumMsg:		.asciiz	"  Volumes Sum = "
aveMsg:		.asciiz	"  Volumes Ave = "


###########################################################
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


# Calculate Volumes
# temporary registers $t0-$t7
la		$t0,	volumes
lw		$t1,	len
la		$t2,	aSides
la		$t3		bSides
la		$t4		cSides
li		$t7,	0					# loop iteration counter
# use t5 to calculate volumes[i]
# use t6 to multiplication temp register
# use t7 to count loop iteration
calcVolumes:
lw		$t5,	($t2)				# tempVolume = aSide[i]
lw      $t6,	($t3)				# tempSide = bSide[i]
mul		$t5,	$t5,	$t6			# tempVolume = aSide[i] * bSide[i]
lw		$t6,	($t4)				# tempSide = cSide[i]
mul		$t5,	$t5,	$t6			# tempVolume = aSide[i] * bSide[i] * cSide[i]
sw		$t5,	($t0)				# volumes[i] = tempVolume
# increment array iterator for volumes, aSides, bSides, and cSides
add		$t0,	$t0,	4
add		$t2,	$t2,	4
add		$t3,	$t3,	4
add		$t4,	$t4,	4
# increment loop iteration counter
add		$t7,	$t7,	1
bltu	$t7,	$t1,	calcVolumes



# calculate median
la		$t0,	volumes			# t0 = volumes address
lw		$t1,	len				# t1 = length = 55
li		$t2,	0				# t2 = median
div		$t1,	$t1,	2		# t1 = length/2
mul		$t1,	$t1,	4		# t1 = t1*dataSize = (length/2)*4
add		$t0,	$t0,	$t1		# t0 = volumes[55/2] address
lw		$t2,	($t0)			# t2 = volumesp[55/2] value
sw		$t2,	vMid			# move median value to vMid's memory

# calculate min, max, sum, and average
la		$t0,	volumes			# t0 volumes address
lw		$t4,	($t0)
sw		$t4,	vMin			# vMin = volumes[0]
sw		$t4,	vMax			# vMax = volumes[0]
lw		$t1,	len				# t1 = volumes' length
li		$t2,	0				# t2 = loop iteration counter
li		$t3,	0				# t3 = Volumes Sum
li		$t5,	0				# holds value of vMin, vMax
statLoop:
	lw		$t4,	($t0)					# t4 = volumes[i], value
	addu	$t3,	$t3,	$t4				# sum += volumes[i]
	lw		$t5,	vMin					# t5 = vMin, value
	bge		$t4,	$t5,		minSkip		# if volumes[i] >= vMin, skip to minSkip;
	sw		$t4,	vMin					# otherwise, vMin = volumes[i]
	minSkip:
	lw		$t5,	vMax					# t5 = vMax, value
	ble		$t4,	$t5,		maxSkip		# if volumes[i] <= vMax, skip to maxSkip;
	sw		$t4,	vMax					# otherwise, vMax = volumes[i]
	maxSkip:
	add		$t2,	$t2,		1			# increment loop iterator
	add     $t0,	$t0,		4			# increment index iterator
	bltu	$t2,	$t1,		statLoop	# if loop iterator < volumes' length, loop back to statLoop for next loop iteration

	sw		$t3,	vSum					# vSum = t3
	div		$t3,	$t3,	$t1				# t3 = sum/length
	sw		$t3,	vAve					# vAve = t3




# print volumes array
la		$t0,	volumes		# volumes array
lw		$t1,	len			# array length
li		$t2,	0			# loop iteration counter
li		$t4,	0			# remainder register
la		$a0,	sHdr		# print volumes header
li		$v0,	4
syscall
printVolumes:
	la		$a0,	blnks				# print blank spaces
	li		$v0,	4
	syscall
	lw		$a0,	($t0)				# print volumes[i] integer
	li		$v0,	1
	syscall
	add		$t0,	$t0,	4			# increment volumes index 
	add		$t2,	$t2,	1			# increment loop iteration counter
	remu	$t4,	$t2,	6			# t4 = remainder of t2/6
	bne		$t4,	0,		nextIndex	# if the remainder (t4) does not equal 0, skip to nextIndex;
	la		$a0,	newLine				# otherwise, print newLine to terminal
	li		$v0,	4
	syscall
	nextIndex:
		bltu	$t2,	$t1,	printVolumes # if $t2 < $t1, loop back to printVolumes for next loop iteration

##########################################################
#  Display results.

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall
	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Print min message followed by result.

	la	$a0, minMsg
	li	$v0, 4
	syscall					# print "min = "

	lw	$a0, vMin
	li	$v0, 1
	syscall					# print min

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Print med message followed by result.

	la	$a0, midMsg
	li	$v0, 4
	syscall					# print "mid = "

	lw	$a0, vMid
	li	$v0, 1
	syscall					# print mid

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Print max message followed by result.

	la	$a0, maxMsg
	li	$v0, 4
	syscall					# print "max = "

	lw	$a0, vMax
	li	$v0, 1
	syscall					# print max

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Print sum message followed by result.

	la	$a0, sumMsg
	li	$v0, 4
	syscall					# print "sum = "

	lw	$a0, vSum
	li	$v0, 1
	syscall					# print sum

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Print ave message followed by result.

	la	$a0, aveMsg
	li	$v0, 4
	syscall					# print "ave = "

	lw	$a0, vAve
	li	$v0, 1
	syscall					# print ave

	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

# -----
#  Done, terminate program.

endit:
	la	$a0, newLine			# print a newline
	li	$v0, 4
	syscall

	li	$v0, 10
	syscall					# all done!

.end main

