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


        # substr_index_of: Returns the first index of a substring in a string.
        # Parameters:
        #   $a0: Address of null-terminated string to search within.
        #   $a1: Address of null-terminated substring to search for.
        # Returns:
        #   $v0: First index of $a1 in $a0, or -1 if not found.
substr_index_of:
        # Save values before strlen function call.
        push($ra)
        push($a0)
        push($a1)
        move $a0, $a1
        # Get the length of the substring.
        jal strlen
        move $t0, $v0   # Store it in $t0
        pop($a1)
        pop($a0)        # $ra still on stack

        # In this loop:
        #  $t0: Length of substring.
        #  $t1: Current address into $a0.
        #  $t2: Address of substring.
        move $t1, $a0
        move $t2, $a1
        push($a0)       # save $a0 so we can compute index later
_ssio_loop:
        # Check if we have reached the end of $a0.
        lbu $t3, 0($t1)
        beq $t3, $zero, _ssio_not_found

        # Call strncmp on the substring and the current index into $a0.
        move $a0, $t1   # Current addr into $a0
        move $a1, $t2   # Addr of substring.
        move $a2, $t0   # Number of characters to compare.
        push($t0)
        push($t1)
        push($t2)
        jal strncmp
        pop($t2)
        pop($t1)
        pop($t0)

        # If they are equal, we found it!
        beq $v0, $zero, _ssio_found
        # If not, increment index into $a0 and continue.
        addi $t1, $t1, 1
        j _ssio_loop

_ssio_not_found:
        pop($a0)        # Pop off $a0, which was still on stack.
        pop($ra)        # Ditto with $ra
        li $v0, -1      # Not found :(
        jr $ra
_ssio_found:
        pop($a0)
        pop($ra)
        sub $v0, $t1, $a0       # Current address minus original address
        jr $ra


        # strcat: Append two strings into a single buffer.
        # Parameters:
        #   $a0: The address of the prefix string (null-terminated).
        #   $a1: The address of the suffix string (null-terminated).
        #   $a2: The address of the destination buffer (hope you have room!)
        # Returns: nothing
        # Notes:
        #  - $a0 may be the same address as $a2.
        #  - $a0 may be the same address as $a1.
        #  - $a1 MAY NOT be the same address as $a2.
        #  - No other overlap between the buffers is allowed.
strcat:
        push($ra)       # We won't need this for a while.

        push($a0)       # Save the parameters for first strlen call.
        push($a1)
        push($a2)
        jal strlen      # Get the length of the prefix string.
        push($v0)       # Save the length of the prefix string

        # If $a0 == $a2, we don't need to copy the first string!
        beq $a0, $a2, _strcat_copy_suffix

        # Else, we should copy $a0 into $a2!
        # I know this looks screwy, I'm popping all those values from earlier
	# into different registers, and pushing them back in the same order.
        pop($a2)        # This is the saved prefix length
        pop($a0)        # This is the destination buffer
        pop($t0)        # Save the suffix string real quick.
        pop($a1)        # This is the source buffer
        push($a1)       # Save all those values again
        push($t0)
        push($a0)
        push($a2)
        addi $a2, $a2, 1        # strncpy needs to include the nul byte
        jal strncpy
_strcat_copy_suffix:
        # Increment the destination buffer to point to next open character.
        pop($t0)        # The number of chars in prefix
        pop($a2)        # Dest buffer
        pop($a1)        # Suffix string
        pop($a0)        # Prefix string
        add $a2, $a2, $t0
        push($a0)       # Prefix string
        push($a1)       # Suffix string
        push($a2)       # New dest addr

        # Get the length of the suffix string
        move $a0, $a1
        jal strlen

        # Now, use that length for strncpy from the suffix to the destination.
        move $a2, $v0
        pop($a0)
        pop($a1)
        push($a1)
        push($a0)
        addi $a2, $a2, 1        # strncpy needs to include the nul byte
        jal strncpy

        # Finally, we can pop everything out and return.
        pop($t0)
        pop($t0)
        pop($t0)
        pop($ra)
        jr $ra
