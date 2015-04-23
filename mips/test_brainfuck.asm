        ###
        # File: test_brainfuck.asm
        #
        # Code to exercise that brainfuck interpreter.
        ###

.include "util-macros.asm"

.data
test_pass:      .asciiz "TEST PASSED.\n"
test_fail:      .asciiz "==> TEST FAILED!\n"
test_start:     .asciiz "STARTING TESTS.\n"
test_end:       .asciiz "FINISHED TESTS.\n"

test_code1:      .asciiz "ab . a' <uskc>.[]) {w,+ -( })"

test_str1:      .asciiz ".<>.[],+-"

.text
.globl main

main:
        print(test_start)
	jal test_bf_load_code
        print(test_end)
        exit(0)

pass:
        print(test_pass)
        jr $ra
fail:
        print(test_fail)
        jr $ra

test_bf_load_code:
        push($ra)
        la $a0, test_code1
        jal bf_load_code
        pop($ra)
        bne $v0, $zero, fail
        la $a0, test_str1
        la $a1, code
	push($ra)
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass


.include "brainfuck.asm"
.include "string.asm"
