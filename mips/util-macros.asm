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
.macro print_int
	li $v0, 1
	syscall
.end_macro
