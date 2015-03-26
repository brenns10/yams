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
test_str6:      .asciiz "ab"
test_str7:      .asciiz "abcdtitive string with many t's."

# These are allowed to be modified.
test_buf:       .space 4
test_buf2:      .asciiz "Repetitive string with many t's."


.text
.globl main

main:
        print(test_start)
        jal test_str_index_of_exists
        jal test_str_index_of_none
        jal test_strncpy_same_size
        jal test_strncpy_too_big
        jal test_strncpy_small
        jal test_strcmp_eq_samelen
        jal test_strcmp_ne_samelen
        jal test_strcmp_ne_difflen
        jal test_memcpy
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

#################################### STRNCPY ###################################

test_strncpy_same_size:
        la $a0, test_buf
        la $a1, test_str2
        li $a2, 4
        push($ra)
        jal strncpy
        li $t0, 4               # expect 4 bytes written
        bne $v0, $t0, fail
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail    # expect that the strings are the same.
        j pass

test_strncpy_too_big:
        la $a0, test_buf
        la $a1, test_str4
        li $a2, 4
        push($ra)
        jal strncpy
        li $t0, 4               # expect 4 bytes written
        bne $v0, $t0, fail
        la $a1, test_str2
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail    # expect the buffer contains a small portion
        j pass

test_strncpy_small:
        la $a0, test_buf
        la $a1, test_str6
        li $a2, 4
        push($ra)
        jal strncpy
        li $t0, 3               # expect 3 bytes written
        bne $v0, $t0, fail
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail    # expect that the strings are the same.
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


#################################### MEMCPY ####################################

test_memcpy:
        la $a0, test_buf2
        la $a1, test_str4
        li $a2, 4
        push($ra)
        jal memcpy              # Copy "abcd" into "Repetitive "....string
	la $a0, test_buf2
        la $a1, test_str7
        jal strcmp              # Now compare against expected string
        pop($ra)
        bne $v0, $zero, fail
        j pass

.include "string.asm"
