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
test_code2:     .asciiz "..[]+ [<><>-,.[[-]]]]"
test_code3:     .asciiz "[.+.+.,+-"
test_code4:     .asciiz "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

test_str1:      .asciiz ".<>.[],+-"
test_str2:      .asciiz "Hello World!\n"

.text
.globl main

main:
        print(test_start)
	jal test_bf_load_code
        jal test_bf_load_extra_close
        jal test_bf_load_extra_open
        jal test_bf_intrp
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

test_bf_load_extra_close:
        push($ra)
        la $a0, test_code2
        jal bf_load_code
        pop($ra)
        li $t0, 2
        bne $v0, $t0, fail      # make sure it returns balerr
        la $t0, code_size
        lw $t0, 0($t0)
        bne $t0, $zero, fail    # make sure code size is zero
        j pass

test_bf_load_extra_open:
        push($ra)
        la $a0, test_code3
        jal bf_load_code
        pop($ra)
        li $t0, 2
        bne $v0, $t0, fail      # make sure it returns balerr
        la $t0, code_size
        lw $t0, 0($t0)
        bne $t0, $zero, fail    # make sure code size is zero
        j pass

test_bf_intrp:
        push($ra)
        la $a0, test_code4
        jal bf_load_code
        jal bf_intrp
        la $a0, out
        li $v0, 34
        syscall
	print(out)
        la $a0, test_str2
        la $a1, out
        jal strcmp
        pop($ra)
        bne $v0, $zero, fail
        j pass


.include "brainfuck.asm"
.include "string.asm"
