###
# File: brainfuck.asm
#
# Code for brainfuck interpereter.
###

.eqv    CODE_BUFFER     4096
.eqv    OUT_BUFFER      4096
.eqv    MEMORY          32768

.data
bf_code:           .space  CODE_BUFFER
bf_code_size:      .word   0
bf_out:            .space  OUT_BUFFER
bf_buffer:         .space  MEMORY

.text
        # bf_load_code: Loads brainfuck code from a string.  Ignores all non-
        # coding characters.
        # Parameters:
        #   $a0: Address of source string (null terminated).
        # Return:
        #   $v0: 0 on success, 1 on memory error, 2 on bracket balance error
bf_load_code:
        li $t0, CODE_BUFFER
        la $t1, bf_code
        move $t4, $zero

        # $t0 - amount of code bytes remaining.
        # $t1 - current code byte to write into.
        # $t2 - current byte of input
        # $t3 - command to compare input to
        # $t4 - bracket balance
_bf_load_loop:
        lb $t2, 0($a0)
        beq $t2, $zero, _bf_load_return
        beq $t0, $zero, _bf_load_memerr_return
	li $t3, '>'
        beq $t2, $t3, _bf_load_store
	li $t3, '<'
        beq $t2, $t3, _bf_load_store
	li $t3, '+'
        beq $t2, $t3, _bf_load_store
	li $t3, '-'
        beq $t2, $t3, _bf_load_store
	li $t3, '.'
        beq $t2, $t3, _bf_load_store
	li $t3, ','
        beq $t2, $t3, _bf_load_store
	li $t3, '['
        beq $t2, $t3, _bf_load_increment_balance
	li $t3, ']'
        beq $t2, $t3, _bf_load_decrement_balance
        # Fall through for any non-coding characters.
        addi $a0, $a0, 1
        j _bf_load_loop
_bf_load_increment_balance:
        addi $t4, $t4, 1
        j _bf_load_store
_bf_load_decrement_balance:
        addi $t4, $t4, -1
        blt $t4, $zero, _bf_load_balerr_return
_bf_load_store:
        sb $t2, 0($t1)
        addi $t1, $t1, 1
        addi $t0, $t0, -1
        addi $a0, $a0, 1
        j _bf_load_loop

_bf_load_return:
        # Return an error if the bracket balance is off.
        bgt $t4, $zero, _bf_load_balerr_return
        move $v0, $zero
        li $t1, CODE_BUFFER
        sub $t1, $t1, $t0       # Calculate size of code
        la $t0, bf_code_size
        sw $t1, 0($t0)          # Save size of code in memory.
        jr $ra
_bf_load_memerr_return:
        li $v0, 1
        j _bf_load_err_return
_bf_load_balerr_return:
        li $v0, 2
_bf_load_err_return:
        la $t0, bf_code_size    # Make sure code_size is zero so nothing gets
        sw $zero, 0($t0)        # executed
        jr $ra


        # bf_intrp: Interprets brainfuck code given an input string.
        # Parameters:
        #   $a0: Address of input string (null terminated).
        # Returns:
        #   $v0: 0 on success.
bf_intrp:
        # Load code start pointer into $t0.
        # Load address of last instruction in $t1.
        la $t1, bf_code_size
        lw $t1, 0($t1)
        la $t0, bf_code
        add $t1, $t1, $t0
        addi $t1, $t1, -1

        # Address of current output in $t2.
        la $t2, bf_out

        # Data pointer is $t3.
        la $t3, bf_buffer
        sb $zero, 0($t3)

        # Current instruction pointer is $t4 (actual instruction, $t5).
        la $t4, bf_code

        # Max data pointer, so we know when to zero memory.
        addi $t9, $t3, 1

_bf_intrp_loop:
        bgt $t4, $t1, _bf_intrp_end
        blt $t4, $t0, _bf_intrp_end
        blt $t3, $t9, _bf_intrp_nozero
        sb $zero, 0($t3)
        move $t9, $t3
        addi $t9, $t9, 1
_bf_intrp_nozero:
        lbu $t5, 0($t4)
        li $t6, '+'
        beq $t5, $t6, _bf_intrp_inc
        li $t6, '-'
        beq $t5, $t6, _bf_intrp_dec
        li $t6, '>'
        beq $t5, $t6, _bf_intrp_nxt
        li $t6, '<'
        beq $t5, $t6, _bf_intrp_prv
        li $t6, ','
        beq $t5, $t6, _bf_intrp_read
        li $t6, '.'
        beq $t5, $t6, _bf_intrp_write
        li $t6, '['
        beq $t5, $t6, _bf_intrp_loopstart
        li $t6, ']'
        beq $t5, $t6, _bf_intrp_loopend

_bf_intrp_inc: # + (increment value at data cell)
        lbu $t6, 0($t3)
        addiu $t6, $t6, 1
        sb $t6, 0($t3)
        j _bf_intrp_continue

_bf_intrp_dec: # - (decrement value at data cell)
        lbu $t6, 0($t3)
        li $t7, 1
        sub $t6, $t6, $t7
        sb $t6, 0($t3)
        j _bf_intrp_continue

_bf_intrp_nxt: # > (increment data pointer)
        addi $t3, $t3, 1
        j _bf_intrp_continue

_bf_intrp_prv: # < (decrement data pointer)
        addi $t3, $t3, -1
        j _bf_intrp_continue

_bf_intrp_read: # , (read input)
	lbu $t6, 0($a0)
        sb $t6, 0($t3)
        # Check if reading \0, if so, skip incrementing
        beq $t6, $zero, _bf_intrp_continue
        addi $a0, $a0, 1
        j _bf_intrp_continue

_bf_intrp_write: # . (write output)
        lbu $t6, 0($t3)
        # Compute the second to last byte of output
        la $t7, bf_out
        addi $t7, $t7, OUT_BUFFER
        addi $t7, $t7, -2
        # Check if out of space, if so, do not overwrite
        bgt $t2, $t7, _bf_intrp_continue
        sb $t6, 0($t2)
        addi $t2, $t2, 1
        j _bf_intrp_continue

_bf_intrp_loopstart: # [ (if cell zero, leave loop)
        lbu $t6, 0($t3)
        bne $t6, $zero, _bf_intrp_continue
        li $t7, 1
        li $t8, ']'
_bf_intrp_loopstart_findmatching:
        addi $t4, $t4, 1        # Increment instruction pointer
        lbu $t6, 0($t4)
        beq $t6, $t5, _bf_intrp_loopstart_findmatching_open
        beq $t6, $t8, _bf_intrp_loopstart_findmatching_close
        j _bf_intrp_loopstart_findmatching
_bf_intrp_loopstart_findmatching_open:
        addi $t7, $t7, 1        # Increment nest count
        j _bf_intrp_loopstart_findmatching
_bf_intrp_loopstart_findmatching_close:
        addi $t7, $t7, -1       # Decrement nest count
        # If this evened the nest count, go to next instruction
        beq $t7, $zero, _bf_intrp_continue
        j _bf_intrp_loopstart_findmatching

_bf_intrp_loopend: # [ (if cell zero, leave loop)
        lbu $t6, 0($t3)
        beq $t6, $zero, _bf_intrp_continue
        li $t7, 1
        li $t8, '['
_bf_intrp_loopend_findmatching:
        addi $t4, $t4, -1       # Decrement instruction pointer
        lbu $t6, 0($t4)
        beq $t6, $t5, _bf_intrp_loopend_findmatching_close
        beq $t6, $t8, _bf_intrp_loopend_findmatching_open
        j _bf_intrp_loopend_findmatching
_bf_intrp_loopend_findmatching_close:
        addi $t7, $t7, 1        # Increment nest count
        j _bf_intrp_loopend_findmatching
_bf_intrp_loopend_findmatching_open:
        addi $t7, $t7, -1       # Decrement nest count
        # If this evened the nest count, go to next instruction
        beq $t7, $zero, _bf_intrp_continue
        j _bf_intrp_loopend_findmatching

_bf_intrp_continue:
        addi $t4, $t4, 1
        j _bf_intrp_loop
_bf_intrp_end:
        # Need to null-terminate output.
        sb $zero, 0($t2)
        jr $ra
