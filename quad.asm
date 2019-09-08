	.data
	inputA: .asciiz "Enter A: \n"
	inputB: .asciiz "Enter B: \n"
	inputC: .asciiz "Enter C: \n"

	solution: .asciiz "Solutions: \n"
	noSolution: .asciiz "There are no solutions! \n"

.text
	main:
	#prompting for inputs A, B, and C, and then parsing them into variables.

	#for A
	li $v0, 4
	la $a0, inputA
	syscall

	li $v0, 5		#getting input value
	syscall

	add $t0, $zero, $v0		#parse A into $t0

	#for B
	li $v0, 4
	la $a0, inputB
	syscall

	li $v0, 5
	syscall

	add $t1, $zero, $v0		#parse B into $t1

	#for C
	li $v0, 4
	la $a0, inputC
	syscall

	li $v0, 5
	syscall

	add $t2, $zero, $v0		#parse C into $t2

	la $a0, solution
	li $v0, 4
	syscall



	rem $t3, $t0, $t1	# $t3 = a mod b

	addi $t4, $zero, 0	#initializing iterators to 0
	addi $t5, $zero, 0

	loop:
	bgt  $t4, $t2, fin	#if i > c we're done
	mult $t4, $t4		#calculating i^2
	mflo $t6		# $t6 = i^2

	rem $t7, $t6, $t1	# $t7 = i^2 mod b
	beq $t7, $t3, printAndIterate	# if R = R, print new x
	addi $t4, $t4, 1 	# continue, otherwise
	j loop

	printAndIterate:
	#print i
	move $a0, $t4
	li $v0, 1
	syscall

	#print space
	la $a0, 32
	li $v0, 11
	syscall

	addi $t5, $t5, 1	#iterate checker

	addi $t4, $t4, 1 	# i++
	j loop                  #return to start of process


	#Print if no solutions
	noSolPrint:
	li $v0, 4
	la $a0, noSolution
	syscall

	addi $t5, $t5, 1	#iterate the checker to ensure done


	fin:
	beq $t5, 0, noSolPrint	#check if no solution



	li $v0, 10
	syscall
