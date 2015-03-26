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
test_str2:      .asciiz "abc"
test_str3:      .asciiz "abd"
test_str4:      .asciiz "abcd"
test_str5:      .asciiz "abc"

.text
.globl main

main:
        print(test_start)
        jal test_str_index_of_exists
        jal test_str_index_of_none
        jal test_strcmp_eq_samelen
        jal test_strcmp_ne_samelen
        jal test_strcmp_ne_difflen
        print(test_end)
        exit(0)

pass:
        print(test_pass)
        jr $ra

fail:
        print(test_fail)
        jr $ra

################################# STR_INDEX_OF #################################

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

#################################### STRCMP ####################################

test_strcmp_eq_samelen:
        la $a0, test_str2
        la $a1, test_str5
        push($ra)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_strcmp_ne_samelen:
        la $a0, test_str2
        la $a1, test_str3
        push($ra)
        jal strcmp
        pop($ra)
        bgez $v0, fail
        j pass

test_strcmp_ne_difflen:
        la $a0, test_str2
        la $a1, test_str4
        push($ra)
        jal strcmp
        pop($ra)
        bgez $v0, fail
        j pass

.include "string.asm"
