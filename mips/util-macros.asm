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

# pushes all callee-saved registers (i.e. $s0-s7, $ra)
# useful for functions that use most of these registers (e.g. get_request)
.macro push_all()
	push($s0)
	push($s1)
	push($s2)
	push($s3)
	push($s4)
	push($s5)
	push($s6)
	push($s7)
	push($ra)
.end_macro

# un-does push_all by popping in reverse order
.macro pop_all()
	pop($ra)
	pop($s7)
	pop($s6)
	pop($s5)
	pop($s4)
	pop($s3)
	pop($s2)
	pop($s1)
	pop($s0)
.end_macro
