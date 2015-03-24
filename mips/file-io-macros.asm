# File syscall values
.eqv	FILE_OPEN	13
.eqv	FILE_WRITE	14
.eqv	FILE_READ	15
.eqv	FILE_CLOSE	16

# File Macros
.macro file_open(%filename, %flags, %mode)
	li $v0, FILE_OPEN
	la $a0, %filename
	li $a1, %flags
	li $a2, %mode
	syscall
.end_macro
.macro file_write(%filedesc, %buffer_address, %max_write_length)
	li $v0, FILE_WRITE
	move $a0, %filedesc
	la $a1, %buffer_address
	li $a2, %max_write_length
	syscall
.end_macro
.macro file_read(%filedesc, %buffer_address, %max_read_length)
	li $v0, FILE_READ
	move $a0, %filedesc
	la $a1, %buffer_address
	li $a2, %max_read_length
	syscall
.end_macro
.macro file_close(%filedesc)
	li $v0, FILE_CLOSE
	move $a0, %filedesc
	syscall
.end_macro
