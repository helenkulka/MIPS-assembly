.data
	inputstring: .space 127
	original: .asciiz "Type in a string: " #assuming the max length is 127 characters and asking for input strings
	newstring: .asciiz "The new string is: "

.text
	main:
	
	#Printing original string
	la $a0, original
	li $v0, 4
	syscall 
	
	#Getting input
	li $v0, 8
	la $a0, inputstring
	li $a1, 127
	syscall 
	
	#Printing a new line
	li $a0, 10
	li $v0, 11
	syscall 
	
	
	#Printing input
	li $v0, 4
	la $a0, inputstring
	syscall 
	
	#Printing a new line
	li $a0, 10
	li $v0, 11
	syscall 
	
	
	
    	li $t0, 0			#initializing $t0 counter to 0
	
	loop:
   	lb $t1, inputstring($t0)	#extract first byte
    	beq $t1, 0, fin			#check if at NULL char, if so exit
    	blt $t1, 'a', capsNonChar	#check if character isn't a lowercase char
    	sub $t1, $t1, 32		#Changing to uppercase
    	sb $t1, inputstring($t0)	#Storing new byte

	capsNonChar: 
    	addi $t0, $t0, 1		#increase iterator and return to loop
    	j loop			
	

	
	fin:
	
	#printing the new string
	li $v0, 4
	la $a0, newstring
	syscall 
	
	
	li $v0, 4
	la $a0, inputstring
	syscall 
	

	li $v0, 10
	syscall
	
	