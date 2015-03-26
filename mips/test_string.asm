###
# File: test_string.asm
#
# Code to exercise string manipulation routines.
###

.include "util-macros.asm"

.data
test_pass:      .asciiz "TEST PASSED.\n"
test_fail:      .asciiz "TEST FAILED.\n"
test_start:     .asciiz "STARTING TESTS.\n"
test_end:       .asciiz "FINISHED TESTS.\n"

test_str1:      .asciiz "Repetitive string with many t's."


.text
.globl main

main:
        print(test_start)
        jal test_str_index_of_exists
        jal test_str_index_of_none
        print(test_end)
        exit(0)

pass:
        print(test_pass)
        jr $ra

fail:
        print(test_fail)
        jr $ra

test_str_index_of_exists:
        la $a0, test_str1
        li $a1, 't'
        push($ra)
        jal str_index_of
        pop($ra)
        li $t0, 4
        bne $v0, $t0, fail
        j pass

test_str_index_of_none:
        la $a0, test_str1
        li $a1, 'z'
        push($ra)
        jal str_index_of
        pop($ra)
        li $t0, -1
        bne $v0, $t0, fail
        j pass

.include "string.asm"
