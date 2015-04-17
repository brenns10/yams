###
# File: file.asm
#
# Code for file URI to file handle conversion
###

# macro includes
.include "file-io-macros.asm"

.eqv	_FILE_PATH_MAX_LEN		1024

default_file:	.asciiz "index.html"
default_dir:	.asciiz "html"
chr_slash:	.asciiz "/"
_file_path_buff:	.byte	0:MAX_LEN

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
	
	# Concatenate URI
	
	# Concatenate default file if required
	
	# Call to open and handle goes in $v0
	file_open(%filename, FILE_OPEN_READ, $v0)
	
	# Cleanup and return
	pop($s0)
	pop($ra)
	jr $ra

# module includes
.include "string.asm"
