.include "file-io-macros.asm"
.include "util-macros.asm"

.eqv 	fd		$s0
.eqv 	bytes_to_read	$s1
.eqv 	bytes_read	$s2
.data
filename:	.asciiz	".."
cur_char:	.asciiz "_"
ln:		.asciiz "\n"
.text
.globl main
main:
	la $t1, filename
	file_open($t1, FILE_OPEN_READ, fd)
	move $s6, $v0
	print_int($s6)
	exit(0)
	li bytes_to_read, 128
	li $s7, 1
_main_loop:
	file_read(fd, cur_char, $s7, bytes_read)
	print(cur_char)
	addi bytes_to_read, bytes_to_read, -1
	bgtz bytes_read, _main_loop
	file_close(fd)
	
