# File syscall values
.eqv	FILE_OPEN	13
.eqv	FILE_WRITE	14
.eqv	FILE_READ	15
.eqv	FILE_CLOSE	16

# File Macros
.macro file_open(%filename, %flags, %mode)
	la $a0, %filename
	move $a1, %flags
	move $a2, %mode
	li $v0, FILE_OPEN
	syscall
.end_macro
.macro file_write(%filedesc, %buffer_address, %max_write_length)
	la $a0, %filedesc
	move $a1, %flags
	move $a2, %mode
	li $v0, FILE_WRITE
	syscall
.end_macro
.macro file_read(%filedesc, %buffer_address, %max_read_length)
	la $a0, %filedesc
	move $a1, %flags
	move $a2, %mode
	li $v0, FILE_READ
	syscall
.end_macro
.macro file_close(%filedesc)
	move $a0, %filedesc
	li $v0, FILE_CLOSE
	syscall
.end_macro
