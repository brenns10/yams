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


        # strncpy: Copies at most 'n' bytes of a string into another buffer.
        # Parameters:
        #   $a0: Address of destination buffer.
        #   $a1: Address of source buffer.
        #   $a2: Number of bytes to write in destination buffer (including null
        #        byte).
        # Returns:
        #   $v0: Number of characters written out (including null byte).
strncpy:
        move $t0, $a0       # $t0: pointer to current destination byte
        move $t1, $a1       # $t1: pointer to current source byte
        add  $t2, $a0, $a2  # $t2: 1 byte past the last write
_strncpy_loop:
        beq $t0, $t2, _strncpy_overflow   # Stop if we're about to write too far
        lbu $t3, 0($t1)  # load
        sb  $t3, 0($t0)  # write
        addi $t0, $t0, 1
        addi $t1, $t1, 1
        beq $t3, $zero, _strncpy_return   # Return if we hit a null terminator
        j _strncpy_loop
_strncpy_overflow:
        addi $t2, $t2, -1
        sb $zero, 0($t2)
_strncpy_return:
        sub $v0, $t0, $a0
        jr $ra
