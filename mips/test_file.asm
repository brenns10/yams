###
# File: test_file.asm
#
# Code to exercise the URI file handler implementation.
###

.include "util-macros.asm"
.include "file-io-macros.asm"

.data
test_pass:	.asciiz "TEST PASSED.\n"
test_fail:	.asciiz "==> TEST FAILED!\n"
test_start:	.asciiz "STARTING TESTS.\n"
test_end:	.asciiz "FINISHED TESTS.\n"

test_uri1:	.asciiz "/"
test_uri2:	.asciiz "/minimal_page.html"
test_uri3:	.asciiz "/invalid/invalid.txt"
test_uri4:	.asciiz "/../../../etc/passwd"

.text
.globl main
main:
	print(test_start)
	
	jal test_root_uri
	jal test_specific_resource
	jal test_inaccessible_resource
	jal test_blocking_dotdot
	
	print(test_end)
	exit(0)

# Utility jump points for tests
pass:
	print(test_pass)
	jr $ra
fail:
	print(test_fail)
	jr $ra

## Testing uri_file_handle_fetch

test_root_uri:
	push($ra)
	la $a0, test_uri1
	jal uri_file_handle_fetch
	pop($ra)
	
	blt $v0, $zero, fail  # Expect to get a proper file handle
	j pass

test_specific_resource:
	push($ra)
	la $a0, test_uri2
	jal uri_file_handle_fetch
	pop($ra)
	
	blt $v0, $zero, fail  # Expect to get a proper file handle
	j pass

test_inaccessible_resource:
	push($ra)
	la $a0, test_uri3
	jal uri_file_handle_fetch
	pop($ra)
	
	bge $v0, $zero, fail   # Expect to get an invalid (<0) file handle
	j pass
test_blocking_dotdot:
	push($ra)
	la $a0, test_uri4
	jal uri_file_handle_fetch
	pop($ra)
	
	bge $v0, $zero, fail   # Expect to get an invalid (<0) file handle
	j pass

.include "file.asm"
