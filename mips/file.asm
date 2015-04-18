###
# File: file.asm
#
# Code for file URI to file handle conversion
###

# macro includes
.include "file-io-macros.asm"
.include "util-macros.asm"

.data

.eqv	_FILE_PATH_MAX_LEN		1023

default_file:	.asciiz "index.html"
default_dir:	.asciiz "html"
chr_slash:	.asciiz "/"
_file_path_buff:	.byte	0:_FILE_PATH_MAX_LEN # Intentionally not -1

.text

	# uri_file_handle_fetch: Return the file handle of the given URI if that
	#		file is reachable.
	# Parameters:
	#   $a0: Address of the null-terminated URI string. Must include the
	#		leading / and, if in need of the default_file, end with a
	#		trailing /.
	# Returns:
	#   $v0: MARS file handle if file is accessible, or <0 if not.
	# Note: parameters probably not going to be preserved.
uri_file_handle_fetch:
	push($ra)
	push($s0)
	
	# Save the URI string address
	move $s0, $a0
	
	# Push base path onto path
	la $a0, _file_path_buff
	la $a1, default_dir
	la $a2, _FILE_PATH_MAX_LEN
	
	jal strncpy
	
	# Now $v0 has count of chars written + \0
	# Parameters preserved
	
	# Concatenate URI
	
	# Calculate next copying start address
	add $a0, $a0, $v0  # _file_path_buff + chars_written
	addi $a0, $a0, -1  # get next start address: subtract off writing \0
	
	move $a1, $s0
	
	sub $a2, $a2, $v0  # _FILE_PATH_MAX_LEN - chars_written
	addi $a2, $a2, 1  # get next max length: add for writing over \0
	
	jal strncpy
	
	# Now $v0 has count of additional chars written + \0
	# Parameters preserved
	
	# Concatenate default file if required
	
	# Calculate next copying start address
	add $a0, $a0, $v0  # last_start_address + chars_written
	addi $a0, $a0, -1  # get next start address: subtract off writing \0
	
	# Check if wrote to end of buffer
	sub $a2, $a2, $v0  # last_max_len - chars_written
	addi $a2, $a2, 1  # get next max length: add for writing over \0
	
	li $v0, -1  # error condition from over-filled buffer
	ble $a2, $zero, _uri_file_handle_fetch_return  # ble due to +1
	
	addi $t0, $a0, -1  # last character in string buffer
	lbu $t1, 0($t0)  # get that character
	lbu $t2, chr_slash  # get the slash character
	
	# Check if requires concatenation of default_file
	bne $t1, $t2, _uri_file_handle_fetch_file_open
	
	# requiring concatenation:
	# Already have $a0, $a2 prepared
	la $a1, default_file
	
	jal strncpy
	
	# Check if wrote to end of buffer
	sub $a2, $a2, $v0  # last_max_len - chars_written
	addi $a2, $a2, 1  # get next max length: add for writing over \0
	
	li $v0, -1  # error condition from over-filled buffer
	ble $a2, $zero, _uri_file_handle_fetch_return  # ble due to +1
	
	# Call to open and handle goes in $v0
_uri_file_handle_fetch_file_open:	
	la $t0, _file_path_buff
	file_open($t0, FILE_OPEN_READ, $v0)
	
	# Cleanup and return
_uri_file_handle_fetch_return:
	pop($s0)
	pop($ra)
	jr $ra

# module includes
.include "string.asm"