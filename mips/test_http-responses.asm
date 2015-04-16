###
# File: test_http-responses.asm
#
# Code to exercise http response routines.
###

.include "util-macros.asm"

.data
test_pass:      .asciiz "TEST PASSED.\n"
test_fail:      .asciiz "==> TEST FAILED!\n"
test_start:     .asciiz "STARTING TESTS.\n"
test_end:       .asciiz "FINISHED TESTS.\n"

_method_name_not_allowed_resp: .asciiz "HTTP/1.1 405 METHOD NAME NOT ALLOWED\r\n\r\n"
_bad_request_resp: .asciiz "HTTP/1.1 400 BAD REQUEST\r\n\r\n"

.text
.globl main

main:
        print(test_start)
        jal test_return_method_name_not_allowed
        jal test_return_bad_request
        print(test_end)
        exit(0)

pass:
        print(test_pass)
        jr $ra

fail:
        print(test_fail)
        jr $ra

############################### _return_method_name_not_allowed ##############################

test_return_method_name_not_allowed:
  push($ra)
  jal _return_method_name_not_allowed
  move $a0, $v0
  la $a1, _method_name_not_allowed_resp
  jal strncmp
  pop($ra)
  bne $v0, $zero, fail
  j pass

test_return_bad_request:
  push($ra)
  jal _return_bad_request
  move $a0, $v0
  la $a1, _bad_request_resp
  jal strncmp
  pop($ra)
  bne $v0, $zero, fail
  j pass

.eqv HTTP_GET 0
.eqv HTTP_POST 1
.eqv HTTP_OTHER 2
.eqv HTTP_ERROR 3

.include "http-responses.asm"
.include "string.asm"
