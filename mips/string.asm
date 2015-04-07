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
        # Note: parameters are preserved.
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
        # Note: parameters are preserved.
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


        # strcmp: Compare two strings and return <0 if the first is less than
        #         the second, >0 if vice versa, or 0 if they are the same.
        # Parameters:
        #   $a0: Address of first string.
        #   $a1: Address of second string.
        # Returns:
        #   $v0: Value as described above.
        # Note: none of the parameters are preserved on return.
strcmp:
        lb $t0, 0($a0)
        lb $t1, 0($a1)
        bne $t0, $t1, _strcmp_ne
        # $t0 == $t1:
        bne $t0, $zero, _strcmp_equal_continue
        # $t0 == $t1 == '\0':
        move $v0, $zero
        jr $ra
_strcmp_equal_continue:
        # $t0 == $t1 != '\0':
        addi $a0, $a0, 1
        addi $a1, $a1, 1
        j strcmp
_strcmp_ne:
        # $t0 != $t1:
        sub $v0, $t0, $t1
        jr $ra


        # memcpy: Move n bytes from a source buffer to a destination buffer.
        # Parameters:
        #   $a0: Address of destination buffer.
        #   $a1: Address of source buffer.
        #   $a2: Number of bytes to write.
        # Returns: Nothing.
        # Note: none of the parameters are preserved on return.
memcpy:
        beq $a2, $zero, _memcpy_return
        lbu $t0, 0($a1)
        sb  $t0, 0($a0)
        addi $a0, $a0, 1
        addi $a1, $a1, 1
        addi $a2, $a2, -1
        j memcpy
_memcpy_return:
        jr $ra


        # atoi: Convert a decimal string into an integer.
        # Parameters:
        #   $a0: Address of null-terminated decimal string.
        # Returns:
        #   $v0: Value of string.
atoi:
        move $v0, $zero
        li  $t0, 10
_atoi_loop:
        lbu $t1, 0($a0)                 # load the character
        beq $t1, $zero, _atoi_return    # stop at null terminator
        mult $v0, $t0                   # move up result by one decimal place
        mflo $v0
        subi $t1, $t1, '0'              # get character value
        add $v0, $v0, $t1               # add character value to result
        addi $a0, $a0, 1                # increment string pointer
        j _atoi_loop
_atoi_return:
        jr $ra


        # htoi: Convert a hexadecimal string into an integer.
        # Parameters:
        #   $a0: Address of null-terminated, positive hex string.
        # Returns:
        #   $v0: Value of string.
        # Notes: Suports upper or lower case.  No error handling, or whitespace.
htoi:
        move $v0, $zero
        li   $t1, 'a'
        li   $t2, 'A'
_htoi_loop:
        lbu  $t0, 0($a0)
        addi $a0, $a0, 1
        beq  $t0, $zero, _htoi_return
        sll  $v0, $v0, 4
        bge  $t0, $t1, _htoi_lc
        bge  $t0, $t2, _htoi_uc
        subi $t0, $t0, '0'
        add  $v0, $v0, $t0
        j    _htoi_loop
_htoi_uc:
        addi $t0, $t0, -55
        add  $v0, $v0, $t0
        j    _htoi_loop
_htoi_lc:
        addi $t0, $t0, -87
        add  $v0, $v0, $t0
        j    _htoi_loop
_htoi_return:
        jr   $ra


        # strncmp: Compare first n bytes of two strings and return <0 if the
        #          first is less than the second, >0 if vice versa, or 0 if they
        #          are the same.
        # Parameters:
        #   $a0: Address of first string.
        #   $a1: Address of second string.
        #   $a2: Number of bytes to compare.
        # Returns:
        #   $v0: Value as described above.
        # Note: none of the parameters are preserved on return.
strncmp:
        lb $t0, 0($a0)
        lb $t1, 0($a1)
        beq $a2, $zero, _strncmp_end
        addi $a2, $a2, -1
        bne $t0, $t1, _strncmp_ne
        # $t0 == $t1:
        bne $t0, $zero, _strncmp_equal_continue
        # $t0 == $t1 == '\0':
_strncmp_end:
        move $v0, $zero
        jr $ra
_strncmp_equal_continue:
        # $t0 == $t1 != '\0':
        addi $a0, $a0, 1
        addi $a1, $a1, 1
        j strncmp
_strncmp_ne:
        # $t0 != $t1:
        sub $v0, $t0, $t1
        jr $ra


        # strlen: Returns the length of the string in $a0 (not including null
        #         terminating byte).
        # Parameters:
        #   $a0: Address of null terminated string.
        # Return:
        #   $v0: Number of characters in the string.
strlen:
        move $v0, $zero
_strlen_loop:
        lb $t0, 0($a0)
        beq $t0, $zero, _strlen_return
        addi $v0, $v0, 1
        addi $a0, $a0, 1
        j _strlen_loop
_strlen_return:
        jr $ra
