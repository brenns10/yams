###
# File: file.asm
#
# Code for file URI to file handle conversion
###

# macro includes
.include "file-io-macros.asm"

.text

	# uri_file_handle_fetch: Return the file handle of the given URI if that
	#		file is reachable.
	# Parameters:
	#   $a0: Address of the URI string.
	#   $a1: Character to find first instance of.
	# Returns:
	#   $v0: MARS file handle if file is accessible, or <0 if not.
	# Note: parameters probably not going to be preserved.
uri_file_handle_fetch:
	push($ra)
	
	# Implementation to live here
	
	pop($ra)
	jr $ra

# module includes
.include "string.asm"
