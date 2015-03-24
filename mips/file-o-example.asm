# Originally from
# http://courses.missouristate.edu/KenVollmar/MARS/Help/SyscallHelp.html
# Section "Example of File I/O"

	.data
# Output filename
fout:	   .asciiz "testout.txt~"
# Text to be written out
buffer:	 .asciiz "The quick brown fox jumps over the lazy dog."

	.text

.globl	main
main:
	# Open (for writing) a file that does not exist
	li   $v0, 13       # system call for open file
	la   $a0, fout     # output file name
	li   $a1, 1        # Open for writing (flags are 0: read, 1: write)
	li   $a2, 0        # mode is ignored
	syscall            # open a file (file descriptor returned in $v0)
	move $s6, $v0      # save the file descriptor

	# Write to file just opened
	li   $v0, 15       # system call for write to file
	move $a0, $s6      # file descriptor
	la   $a1, buffer   # address of buffer from which to write
	li   $a2, 44       # hardcoded buffer length
	syscall            # write to file

	# Close the file
	li   $v0, 16       # system call for close file
	move $a0, $s6      # file descriptor to close
	syscall            # close file

	# Exit
	la $a0, 0
	li $v0, 17
	syscall
