# File syscall values
.eqv	FILE_OPEN	13
.eqv	FILE_READ	14
.eqv	FILE_WRITE	15
.eqv	FILE_CLOSE	16

# File opening flags
.eqv	FILE_OPEN_READ	0
.eqv	FILE_OPEN_WRITE	1
.eqv	FILE_OPEN_WRITE_APPEND	9

# Since the file-open syscall ignores mode
.eqv	FILE_NULL_MODE	0

# File Macros
.macro file_open(%filename, %flags, %mode, %result_reg)
	li $v0, FILE_OPEN
	move $a0, %filename
	li $a1, %flags
	li $a2, %mode
	syscall
	move %result_reg, $v0
.end_macro

.macro file_read(%filedesc, %buffer_address, %max_read_length, %result_reg)
	li $v0, FILE_READ
	move $a0, %filedesc
	la $a1, %buffer_address
	la $a2, %max_read_length
	syscall
	move %result_reg, $v0
.end_macro

.macro file_write(%filedesc, %buffer_address, %max_write_length, %result_reg)
	li $v0, FILE_WRITE
	move $a0, %filedesc
	move $a1, %buffer_address
	move $a2, %max_write_length
	syscall
	move %result_reg, $v0
.end_macro

.macro file_close(%filedesc)
	li $v0, FILE_CLOSE
	move $a0, %filedesc
	syscall
.end_macro
