.include "file-io-macros.asm"
.include "util-macros.asm"

.eqv MAX_LEN 16384

	.data
# Output filename
write_out_name: .asciiz "macro_output.txt~"

write_out_data: .asciiz "HTTP/1.1 200 OK\r\nContent-Type: text/html;\n"
write_out_data_end:

read_in_name:	.asciiz	"Makefile"

buff: .byte 0:MAX_LEN

newline:	.asciiz	"\n"
bytes_written:	.asciiz	"Bytes Written: "
bytes_read:	.asciiz	"Bytes Read: "

	.text
.globl	main
main:
	la $t0, write_out_name  # load the filename pointer into a register
	# Open the file with name in write_out_name
	# Save descriptor value in $s0
	file_open($t0, FILE_OPEN_WRITE, $s0)
	
	# Determine length of data to write in $t0
	la $t0, write_out_data
	la $t1, write_out_data_end
	sub $t1, $t1, $t0  # computation
	la $t0, write_out_data  # load the buffer pointer 
	
	# Write out to file descriptor in $s0 the data in the buffer
	# Save chars written count in $s1
	file_write($s0, $t0, $t1, $s1)
	
	print(bytes_written)
	move $a0, $s1
	print_int  # Print the chars written count
	print(newline)
	
	# Close the file descriptor in $s0
	file_close($s0)
	
	la $t0, read_in_name # load the filename pointer into a register
	# Open the file with name in read_in_name
	# Save descriptor value in $s0 
	file_open($t0, FILE_OPEN_READ, $s0)
	
	# Read from file in $s0 into buff
	# Save chars read in $s1
	file_read($s0, buff, MAX_LEN, $s1)
	
	print(bytes_read)
	move $a0, $s1
	print_int  # Print the chars read count
	print(newline)
	
	# Close the file descriptor in $s0
	file_close($s0)
	
	exit(0)
