        ###
        # File: brainfuck.asm
        #
        # Code for brainfuck interpereter.
        ###

.eqv    CODE_BUFFER     1024
.eqv    OUT_BUFFER      1024
.data
code:           .space CODE_BUFFER
code_size:      .word
out:            .space OUT_BUFFER


.text
        # bf_load_code: Loads brainfuck code from a string.  Ignores all non-
        # coding characters.
        # Parameters:
        #   $a0: Address of source string (null terminated).
        # Return:
        #   $v0: 0 on success, non-0 on memory error.
bf_load_code:
        li $t0, CODE_BUFFER
        la $t1, code

_bf_load_loop:
        lb $t2, 0($a0)
        beq $t2, $zero, _bf_load_return
        beq $t0, $zero, _bf_load_err_return
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
        beq $t2, $t3, _bf_load_store
	li $t3, ']'
        beq $t2, $t3, _bf_load_store
        addi $a0, $a0, 1
        j _bf_load_loop
_bf_load_store:
        sb $t2, 0($t2)
        addi $t1, $t1, 1
        addi $t0, $t0, -1
        j _bf_load_loop

_bf_load_return:
        move $v0, $zero
        li $t1, CODE_BUFFER
        sub $t1, $t1, $t0       # Calculate size of code
        la $t0, code_size
        sb $t1, 0($t0)          # Save size of code in memory.
        jr $ra
_bf_load_err_return:
        li $v0, -1
        jr $ra
