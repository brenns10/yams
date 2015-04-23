###
# File: test_string.asm
#
# Code to exercise string manipulation routines.
###

.include "util-macros.asm"

.data
test_pass:      .asciiz "TEST PASSED.\n"
test_fail:      .asciiz "==> TEST FAILED!\n"
test_start:     .asciiz "STARTING TESTS.\n"
test_end:       .asciiz "FINISHED TESTS.\n"

test_str1:      .asciiz "Repetitive string with many t's."
test_str2:      .asciiz "abc"
test_str3:      .asciiz "abd"
test_str4:      .asciiz "abcd"
test_str5:      .asciiz "abc"
test_str6:      .asciiz "ab"
test_str7:      .asciiz "abcdtitive string with many t's."
test_str8:      .asciiz "12345"
test_str9:      .asciiz "DeAdBeEf"
test_str10:     .asciiz "string"
test_str11:     .asciiz "abcdstring"
test_str12:     .asciiz "abcdabcd"
test_str13:     .asciiz "abcdstr"
test_str14:     .asciiz ""

# These are allowed to be modified.
test_buf:       .space 4
test_buf2:      .asciiz "Repetitive string with many t's."
test_buf3:      .space 20
test_buf4:      .asciiz "abcd"
                .space 15
test_buf5:      .asciiz "abcd"
                .space 4
test_buf6:      .space 20
test_buf7:      .space 4
test_buf8:      .space 8
test_buf9:      .asciiz "ABCD"

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
        jal test_atoi
        jal test_htoi
        jal test_strncmp
        jal test_strlen
        jal test_ssio_found
        jal test_ssio_not_found
        jal test_strcat
        jal test_strcat_into_same
        jal test_strcat_all_same
        jal test_strncat_plenty
        jal test_strncat_lessthan_prefix
        jal test_strncat_lessthan_suffix
        jal test_memset
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


##################################### ATOI #####################################

test_atoi:
        la $a0, test_str8
        push($ra)
        jal atoi
        pop($ra)
        li $t0, 12345
        bne $v0, $t0, fail
        j pass

test_htoi:
        la $a0, test_str9
        push($ra)
        jal htoi
        pop($ra)
        li $t0, 0xDEADBEEF
        bne $v0, $t0, fail
        j pass


################################### STRNCPY ####################################

test_strncmp:
        la $a0, test_str4
        la $a1, test_str7
        li $a2, 4
        push($ra)
        jal strncmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

#################################### STRLEN ####################################

test_strlen:
        la $a0, test_str9
        push($ra)
        jal strlen
        pop($ra)
        li $t0, 8
        bne $v0, $t0, fail
        j pass

############################### SUBSTR_INDEX_OF ################################

test_ssio_found:
        la $a0, test_str1
        la $a1, test_str10
        push($ra)
        jal substr_index_of
        pop($ra)
        li $t0, 11
        bne $v0, $t0, fail
        j pass

test_ssio_not_found:
        la $a0, test_str1
        la $a1, test_str9
        push($ra)
        jal substr_index_of
        pop($ra)
        li $t0, -1
        bne $v0, $t0, fail
        j pass

#################################### STRCAT ####################################

test_strcat:
        la $a0, test_str4       # "abcd"
        la $a1, test_str10      # "string"
        la $a2, test_buf3       # 20 byte space
        push($ra)
        jal strcat
        la $a0, test_str11      # "abcdstring"
        la $a1, test_buf3       # (destination buffer)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_strcat_into_same:
        la $a0, test_buf4       # "abcd" + 16 bytes
        la $a1, test_str10      # "string"
        la $a2, test_buf4       # "abcd" + 16 bytes
        push($ra)
        jal strcat
        la $a0, test_str11      # "abcdstring"
        la $a1, test_buf4       # (destination buffer)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_strcat_all_same:
        la $a0, test_buf5       # "abcd" + 16 bytes
        la $a1, test_buf5       # "abcd" + 16 bytes
        la $a2, test_buf5       # "abcd" + 16 bytes
        push($ra)
        jal strcat
        la $a0, test_str12      # "abcdabcd"
        la $a1, test_buf5       # (destination buffer)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_strncat_plenty:
        la $a0, test_str4       # "abcd"
        la $a1, test_str10      # "string"
        la $a2, test_buf6       # 20 byte space
        li $a3, 20
        push($ra)
        jal strncat
        la $a0, test_str11      # "abcdstring"
        la $a1, test_buf6       # (destination buffer)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_strncat_lessthan_prefix:
        la $a0, test_str4       # "abcd"
        la $a1, test_str10      # "string"
        la $a2, test_buf7       # 4 byte space
        li $a3, 4
        push($ra)
        jal strncat
        la $a0, test_str2       # "abc"
        la $a1, test_buf7       # (destination buffer)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_strncat_lessthan_suffix:
        la $a0, test_str4       # "abcd"
        la $a1, test_str10      # "string"
        la $a2, test_buf8       # 8 byte space
        li $a3, 8
        push($ra)
        jal strncat
        la $a0, test_str13      # "abcdstr"
        la $a1, test_buf8       # (destination buffer)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass

test_memset:
        la $a0, test_buf9
        li $a1, '\0'
        li $a2, 4
        push($ra)
        jal memset
        pop($ra)
	lb $t0, 0($a0)
        bne $t0, $zero, fail
	lb $t0, 1($a0)
        bne $t0, $zero, fail
	lb $t0, 2($a0)
        bne $t0, $zero, fail
	lb $t0, 3($a0)
        bne $t0, $zero, fail
        j pass


.include "string.asm"
