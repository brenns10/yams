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

test_no_tests:	.asciiz "No tests here.\n"

.text
.globl main
main:
	print(test_start)
	
	print(test_no_tests)
	
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
	jal uri_file_handle_fetch
	pop($ra)
	j pass

test_specific_resource:
	push($ra)
	jal uri_file_handle_fetch
	pop($ra)
	j pass

test_inaccessible_resource:
	push($ra)
	jal uri_file_handle_fetch
	pop($ra)
	j pass

.include "file.asm"
