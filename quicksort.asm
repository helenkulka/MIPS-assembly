
# This MIPS program should sort a set of numbers using the quicksort algorithm
# The program should use MMIO

.data
welcomeStatement: .asciiz "Welcome to QuickSort. Enter an Array and a Command\n"
sortedStatement: .asciiz "The sorted array is: \n"
reInitializedStatement: .asciiz "The Array is re-initialized\n" 


array: .space 600
wordArray: .space 600
	.align 4
storageWordArray: .space 2400
arrayToPrint: .space 600
print: .space 600
intermediate: .space 600


	.text
	.globl main

main:	
	#printing first welcome line, prompting for an array and command
	la $a1, welcomeStatement		
	jal Print

start:	#loading inputed array into array space
	la $a1, array
	jal Read
	
	#print inputed array
	la $a1, array
	jal Print

	
	#command = s, we need to convert, sort, ask for another prompt
start2:	beq $s3, 115, CommandS
	#command = c, we need to clear both and ask for another prompt
	beq $s3, 99, CommandC
	
	
	li $v0, 10 		# ending the program 
	syscall 	

	
	
	


################

Print:
	addi $sp, $sp, -4 	# create space on stack
	sw $ra, 0($sp)		# store return address to main on stack 
	
PrintLoop:  
	lb $a0, 0($a1)		#extract char we want to print and put into a0
	beq $a0, $0, PrintDone	#if at end of string we want to end, otherwise print
	jal Write		# call Write with valid character in a0
	addi $a1, $a1, 1	# increment pointer
	j PrintLoop

Write:  lui $t0, 0xffff 	# ffff0000
WriteLoop: 	
	lw $t1, 8($t0) 		# control
	andi $t1,$t1,0x0001
	beq $t1,$0, WriteLoop
	sb $a0, 12($t0) 	# char to print is in a0	
	jr $ra

	#restore stack and end, returning to main
PrintDone: 
	 lw $ra, 0($sp)	 
	 addi $sp, $sp, 4	
	 jr $ra		

#######################

Read:				# read user text into buffer
	lui $t0, 0xffff 	# ffff0000
ReadLoop:
	lw $t1, 0($t0) 		# control
	andi $t1,$t1,0x0001
	beq $t1,$zero,ReadLoop
	lb $v0, 4($t0) 		# load character inputed by user is stored in v0 	
		
	#3 possibilities for letters
	add $t6, $v0, $zero						
	beq $t6, 99, store 	
	beq $t6, 115, store
	beq $t6, 'q', done
	
	#otherwise store char
	sb $v0, 0($a1)		# store character into buffer
	addi $a1, $a1, 1	# increment buffer pointer
	j ReadLoop		

#storing command in s3	
store: 
	add $s3, $t6, $0
	j ReadFin
	
ReadFin:
	sb $zero, 0($a1)	#end string with null
	jr $ra			
	

####################

Convert:

loop:	
	lb $t0, 0($a1)		#extract first value
	beq $t0, $0, fin
	sub $t0, $t0, 48
	
	add $a1, $a1, 1
	
	blt $t0, 0, loop
	
	lb $t1, 0($a1)
	sub $t1, $t1, 48
	
	blt $t1, 0, storeDigit
	
	li $t7, 10
	mul $t3, $t7, $t0
	
	add $t0, $t3, $t1
	
	sb $t0, 0($a2)
	add $a2, $a2, 1
	add $a1, $a1, 1
	
	j loop

storeDigit:
	sb $t0, 0($a2)
	
	add $a2, $a2, 1
	add $a1, $a1, 1
	
	j loop	
	
	
fin:
	#storing null char at last pos, 1 after the one we're at now WTFFFi guess SO
	sb $0, 0($a2)
	jr $ra
	
#######################################

ConvertToWord:

toWordLoop:

	lb $t0, 0($a1)
	beq $t0, $0, toWordFin
	sb $t0, 0($a2)
	
	add $a1, $a1, 1
	add $a2, $a2, 4
	
	j toWordLoop

toWordFin:
	sb $0, 0($a2)
	jr $ra

#######################################

ArraySize:
	
	li $t6, 0
	
sizeLoop:
	lb $t0, 0($a1)
	beq $t0, $0, arrayFin
	add $t6, $t6, 1
	add $a1, $a1, 1
	
	j sizeLoop
	
arrayFin:

	jr $ra

#############################



####################

	
CommandS: 
	la $a1, array
	la $a2, wordArray
	jal Convert
	
	la $a1, wordArray
	jal ArraySize
	
	la $a1, wordArray
	la $a2, storageWordArray
	jal ConvertToWord
	
	
	la $a0, storageWordArray
	li $a1, 0
	
	move $t0, $t6  #store number of elements
	addi $t0, $t0, -1
	
	move $a2, $t0
	
	jal quicksortMethod
	
	la $a1, sortedStatement
	jal Print
	
	la $a0, storageWordArray
	la $a2, arrayToPrint
	j okMaybeThisWorks
	
	
	
	
	j done
	
	
	
#########################
okMaybeThisWorks:

loopF:

	lb $t2, 0($a0)
	beq $t2, $0, umOK
	
	
	sb $t2, 0($a2)
	addi $a0, $a0, 4
	addi $a2, $a2, 1
	
	j loopF

umOK:
	sb $0, 0($a2)
	
	la $a0, arrayToPrint 
	la $a1, print
	j Print2
	
#####################

Print2:
	lb $t0, 0($a0)
	bgt $t0, 9, doubleDig
	beq $t0, $0, okNOW
		
	add $t0, $t0, 48
	sb $t0, 0($a1)
		
	li $t5, 32
	sb $t5, 1($a1)
		
	add $a0, $a0, 1
	add $a1, $a1, 2
		
	j Print2
		

doubleDig:
	li $t7, 10
	div $t0, $t7
	mflo $t6
	mfhi $t7
	addi $t6, $t6, 48
	addi $t7, $t7, 48
		
	sb $t6, 0($a1)
	sb $t7, 1($a1)
		
	li $t5, 32
	sb $t5, 2($a1)
		
	add $a0, $a0, 1
	add $a1, $a1, 3
		
	j Print2

okNOW:

	la $a1, print
	jal Print
	
	j startNew
	
############
	
CommandC: 
	la $a1, array
	la $a2, wordArray
	la $a3, storageWordArray
	la $a0, intermediate
	la $t7, arrayToPrint
	la $t8, pPrint
	
loopC:
	lb $t9, 0($a1)
	beq $t9, $0, loopC2
	sb $0, 0($a1)
	addi $a1, $a1, 1
	j loopC

loopC2:
	lb $t9, 0($a2)
	beq $t9, $0, loopC3
	sb $0, 0($a2)
	addi $a2, $a2, 1
	j loopC2
	
loopC3:
	lb $t9, 0($a3)
	beq $t9, $0, loopC4
	sb $0, 0($a3)
	addi $a3, $a3, 4
	j loopC3

loopC4:
	lb $t9, 0($a0)
	beq $t9, $0, loopC5
	sb $0, 0($a0)
	addi $a0, $a0, 1
	j loopC4

loopC5:
	lb $t9, 0($t7)
	beq $t9, $0, loopC6
	sb $0, 0($t7)
	addi $t7, $t7, 1
	j loopC5

loopC6:
	lb $t9, 0($t8)
	beq $t9, $0, CStartOver
	sb $0, 0($t8)
	addi $t8, $t8, 1
	j loopC6


CStartOver:
	
	
	la $a1, reInitializedStatement
	jal Print
	
	j  start

########################

startNew: 

	la $a1, intermediate
	jal Read
	
	la $a2, intermediate
	
	
##########

#if $a0 isnt empty we go thru this loop to end at the end of now filled intermediate ($a2) array

	la $a0, array
combineLoop:

	lb $t1, 0($a0)
	beq $t1, $0, combine
	add $a0, $a0, 1
	
	j combineLoop

#then, we combine them by starting at the end of $a0 and beginning of $a2, stopping when $a0 is empty


combine:

	lb $t0, 0($a2)
	beq $t0, $0, thisFin
	sb $t0, 0($a0)
	add $a0, $a0, 1
	add $a2, $a2, 1
	
	j combine
	
thisFin:

	sb $0, 0($a0)
	
	j start2
	
##################
	

quicksortMethod:

	addi	$sp, $sp, -24
	sw	$s0, 0($sp)		
	sw	$s1, 4($sp)		
	sw	$s2, 8($sp)		
	sw	$a1, 12($sp)	
	sw	$a2, 16($sp)	
	sw	$ra, 20($sp)	


	move	$s0, $a1		# s0=l
	move	$s1, $a2		# s1=r
	move	$s2, $a1		# s2=p

# while (l < r)
BigLoop:
	bge		$s0, $s1, BigLoopDone
	
# while (val(l) <= val(p) AND l < r)
Loop1:
	li	$t7, 4			
	mult	$s0, $t7
	mflo	$t0			
	add	$t0, $t0, $a0	# t0 = val(l)
	lw	$t0, 0($t0)
	mult	$s2, $t7
	mflo	$t1				
	add	$t1, $t1, $a0	#t1 = val(p)
	lw	$t1, 0($t1)
	bgt	$t0, $t1, Loop1Done #make sure val(l)<val(p)
	bge	$s0, $a2, Loop1Done # make sure l < right
	addi	$s0, $s0, 1
	j	Loop1
	
Loop1Done:

Loop2:
	li	$t7, 4			
	mult	$s1, $t7
	mflo	$t0				
	add	$t0, $t0, $a0	
	lw	$t0, 0($t0)
	mult	$s2, $t7
	mflo	$t1				
	add	$t1, $t1, $a0	# t1 = val(p)
	lw	$t1, 0($t1)
	blt	$t0, $t1, Loop2Done # make sure val(r) >= val(p)
	ble	$s1, $a1, Loop2Done # make sure r > left
	addi	$s1, $s1, -1 	# r--
	j	Loop2
	
#(l >= r)
Loop2Done:
	blt	$s0, $s1, swap
	li	$t7, 4			
	mult	$s2, $t7
	mflo	$t6				
	add	$t0, $t6, $a0	
	mult	$s1, $t7
	mflo	$t6				
	add	$t1, $t6, $a0	
	
	
	lw	$t2, 0($t0)
	lw	$t3, 0($t1)
	sw	$t3, 0($t0)
	sw	$t2, 0($t1)
	

	move	$a2, $s1
	addi	$a2, $a2, -1	
	jal	quicksortMethod
	

	lw	$a1, 12($sp)	
	lw	$a2, 16($sp)	
	lw	$ra, 20($sp)	
	
# quick(arr, r + 1, right)
	move	$a1, $s1
	addi	$a1, $a1, 1		# a1 = r =  r + 1
	jal	quicksortMethod
	
	
	lw	$a1, 12($sp)	
	lw	$a2, 16($sp)	
	lw	$ra, 20($sp)	
	

	lw	$s0, 0($sp)		
	lw	$s1, 4($sp)		
	lw	$s2, 8($sp)		
	addi	$sp, $sp, 24	
	jr	$ra
	
swap:

	li	$t7, 4			
	mult	$s0, $t7
	mflo	$t6				
	add	$t0, $t6, $a0	
	mult	$s1, $t7
	mflo	$t6				
	add	$t1, $t6, $a0	
	
	lw	$t2, 0($t0)
	lw	$t3, 0($t1)
	sw	$t3, 0($t0)
	sw	$t2, 0($t1)
	
	j	BigLoop
	
BigLoopDone:
	

	lw	$s0, 0($sp)		
	lw	$s1, 4($sp)		
	lw	$s2, 8($sp)		
	addi	$sp, $sp, 24	
	jr	$ra

done:

la $v0, 10
syscall


