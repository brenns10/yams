# Syscall numbers
# Client sockets only
.eqv	SOCK_OPEN	100
.eqv	SOCK_WRITE	101
.eqv	SOCK_READ	102
.eqv	SOCK_CLOSE	103
# server socket only
.eqv	SERVER_SOCK_OPEN	110
.eqv	SERVER_SOCK_BIND	111	# does not appear to work
.eqv	SERVER_SOCK_ACCEPT	112
.eqv	SERVER_SOCK_CLOSE	113

# Socket Macros
.macro sock_open(%dest_sock_reg)
	li $v0, SOCK_OPEN
	syscall  #open
	move %dest_sock_reg, $v1
.end_macro
.macro sock_write(%sock_reg)
	move $a0, %sock_reg
	li $v0, SOCK_WRITE
	syscall  # write
.end_macro
.macro sock_read(%sock_reg)
	move $a0, %sock_reg
	li $v0, SOCK_READ  # read
	syscall
.end_macro
.macro sock_close(%sock_reg)
	move $a0, %sock_reg
	li $v0, SOCK_CLOSE
	syscall
.end_macro

.macro ssock_open(%dest_ssock_reg)
	li $v0, SERVER_SOCK_OPEN
	syscall
	move %dest_ssock_reg, $v1
.end_macro
.macro ssock_bind(%ssock_reg, %hostname_addr)
	move $a0, %ssock_reg
	la $a1, %hostname_addr
	li $v0, SERVER_SOCK_BIND
	syscall
.end_macro
.macro ssock_accept(%ssock_reg, %dest_reg)
	move $a0, %ssock_reg
	li $v0, SERVER_SOCK_ACCEPT
	syscall
	move %dest_reg, $v1
.end_macro
.macro ssock_close(%ssock_reg)
	move $a0, %ssock_reg
	li $v0, SERVER_SOCK_CLOSE
	syscall
.end_macro
