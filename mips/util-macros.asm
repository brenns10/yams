# Some simple utility macros
.macro exit(%exit_val)
	la $a0, %exit_val
	li $v0, 17
	syscall
.end_macro

.macro print(%str_addr)
	la $a0, %str_addr
	li $v0, 4
	syscall
.end_macro

.macro print_reg(%reg_addr)
	move $a0, %reg_addr
	li $v0, 4
	syscall
.end_macro

.macro print_int(%src_reg)
	move $a0, %src_reg
	li $v0, 1
	syscall
.end_macro

.macro push(%src_reg)
	sw	%src_reg, 0($sp)
	addi	$sp, $sp, 4
.end_macro

.macro pop(%dst_reg)
	addi	$sp, $sp, -4
	lw	%dst_reg, 0($sp)
.end_macro
