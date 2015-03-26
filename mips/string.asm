###
# File: string.asm
#
# Code for basic string manipulation.
###

.text

        # str_index_of: Return the index of the first instance of a character in
        #               a string.
        # Parameters:
        #   $a0: Address of the string.
        #   $a1: Character to find first instance of.
        # Returns:
        #   $v0: Index of first occurrence, or -1.
str_index_of:
        move $v0, $a0
_sio_loop:
        lbu $t0, 0($v0)
        beq $t0, $a1, _sio_return
        beq $t0, $zero, _sio_none
        addi $v0, $v0, 1
        j _sio_loop
_sio_return:
        sub $v0, $v0, $a0
        jr $ra
_sio_none:
        li $v0, -1
        jr $ra
