#studentName: Helen Kulka
#studentID: 260763566

# This MIPS program should count the occurence of a word in a text block using MMIO

.data
#any any data you need be after this line
textSegment: .space 600
keyWord: .space 600
frequency: .space 600
enterText:	.asciiz "Please enter the text segment:\n"
enterKeyWord:	.asciiz "\nPlease enter the key word:\n"
theWord: 	.asciiz "\nThe word '"
occured:	.asciiz "' occured "
occurences:	.asciiz " time(s).\n"
endPrompt:	.asciiz	"press ’e’ to restart program or ’q’ to quit.\n\n"


	.text
	.globl main

main:	# all subroutines you create must come below "main"
	

	la $a1, enterText		# printing user prompt to MMIO
	jal PrintString


	la $a1, textSegment		
	jal readText			
	la $a1, textSegment
	jal PrintString			

	la $a1, enterKeyWord
	jal PrintString
	la $a1, keyWord		
	li $t2, 0			# counter for length of search word
	jal readWord			# read user input into buffer

	add $t2, $t2, $zero		# holds length of search word
	la $a1, keyWord
	jal PrintString			# printing out the user input that is stored in buffer

	la $a0, textSegment
	la $a1, keyWord
	jal calcFreq 		# compute frequency of search word in text segment

	la $a1, theWord
	jal PrintString			# printing out result

	la $a1, keyWord
	jal PrintString			

	la $a1, occured
	jal PrintString			

	lw $t7, 4($sp)			
	addi $sp, $sp, 8		

	la $a1, frequency
	addi $t7, $t7, 48 	#return to ASCII
	sw $t7, 0($a1)
	sb $0, 4($a1)		# add null
	la $a1, frequency
	jal PrintString

	la $a1, occurences
	jal PrintString

	la $a1, endPrompt
	jal PrintString			
	j redoOrExit			#restart or Exit

######################

readText:			# read user text into buffer
	lui $t0, 0xffff 	# ffff0000
Loop1:	lw $t1, 0($t0) 		# control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop1
	lb $v0, 4($t0) 		# load character inputed by user is stored in v0

	beq $v0, 10, readTextEnd
	sb $v0, 0($a1)
	addi $a1, $a1, 1
	j readText

readTextEnd:
	sb $zero, 0($a1)	#end string with null
	jr $ra


readWord:
	lui $t0, 0xffff 	#ffff0000
Loop2:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,Loop2
	lb $v0, 4($t0)		# load character inputed by user

	beq $v0, 10, readWordEnd
	sb $v0, 0($a1)
	addi $t2, $t2, 1
	addi $a1, $a1, 1
	j readWord
readWordEnd:
	sb $zero, 0($a1)	# end string with null
	jr $ra

################################

calcFreq:

	add $t2, $t2, $0	# search word length
	add $t3, $0, $0		# counter for word length

	li $t6, 32		# space
	li $t7, 0		# counter - frequency of word

	addi $sp, $sp, -8	# make space on stack
	sw $t7, 4($sp)		# store search word frequency on stack

loopChar:
	lb $t0, 0($a0) 		# t0= text segment byte
	lb $t1, 0($a1)		# t1 = keyword byte

	beq $t0, $0, done	
	bne $t0, $t1, skipWord 	#not equal, next word
	addi $t3, $t3, 1	#word length counter
	beq $t3, $t2, nextChar	# once we reach the end of search word length we check for next character
	addi $a0, $a0, 1	#increment pointers
	addi $a1, $a1, 1
	j loopChar

nextChar:
	lb $t8, 1($a0)		
	addi $a0, $a0, 1	
	beq $t8, 32, increment	# next char space = increment freq.
	beq $t8, $0, increment	# next char = null, increment freq.
	j skipWord	
	
increment:
	lw $t7, 4($sp)
	addi $t7, $t7, 1	# increment freq. counter
	sw $t7, 4($sp)
	j reset 		# go to reset

skipWord:
	lb $t8, 0($a0)		
	beq $t8, $0, done	
	beq $t8, 32, reset	# space = next word
	addi $a0, $a0, 1
	j skipWord

reset:
	addi $a0, $a0, 1	
	addi $t3, $0, 0		#reset word length counter
	la $a1, keyWord		# reset keyWord pointer
	j loopChar 		# return to looping through characters
done:
	jr $ra 			# return to main



#####################################


Write:  lui $t0, 0xffff 	# ffff0000
Loop3: 	lw $t1, 8($t0) 		# control
	andi $t1,$t1,0x0001
	beq $t1,$zero, Loop3
	sb $a0, 12($t0) 	
	jr $ra

PrintString:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)		

	
Print:  lb $a0, 0($a1)		
	beq $a0, $0, finPrint	
	jal Write		
	addi $a1, $a1, 1	# increment pointer
	j Print

finPrint: lw $ra, 0($sp)	# load return address to main
	  addi $sp, $sp, 4	# reset stack pointer
	  jr $ra		

#####################

redoOrExit:
	lui $t0, 0xffff 	#ffff0000

cont:	lw $t1, 0($t0) 		#control
	andi $t1,$t1,0x0001
	beq $t1,$zero,cont
	lb $v0, 4($t0)


	beq $v0, 101, main 	#101='e'=restart
	beq $v0, 113, over	#113='q'=quit


over:	li $v0, 10 		# ending the program
	syscall
