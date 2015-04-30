# Syscall numbers
# Client sockets only
.eqv	SOCK_OPEN	100
.eqv	SOCK_WRITE	101
.eqv	SOCK_READ	102
.eqv	SOCK_CLOSE	103
# server socket only
.eqv	SERVER_SOCK_OPEN	110
.eqv	SERVER_SOCK_BIND	111	# does not appear to work (not used in project)
.eqv	SERVER_SOCK_ACCEPT	112
.eqv	SERVER_SOCK_CLOSE	113

.eqv	SOCK_CLOSE_ALL		120	# closes all sockets

# Socket Macros
.macro sock_open(%dest_sock_reg)
	li $v0, SOCK_OPEN
	syscall
	move %dest_sock_reg, $v1
.end_macro

.macro sock_write(%sock_reg)
	li $v0, SOCK_WRITE
	move $a0, %sock_reg
	syscall
.end_macro

.macro sock_read(%sock_reg)
	li $v0, SOCK_READ
	move $a0, %sock_reg
	syscall
.end_macro

.macro sock_close(%sock_reg)
	li $v0, SOCK_CLOSE
	move $a0, %sock_reg
	syscall
.end_macro

# Server socket macros
.macro ssock_open(%dest_ssock_reg)
	li $v0, SERVER_SOCK_OPEN
	syscall
	move %dest_ssock_reg, $v1
.end_macro

.macro ssock_bind(%ssock_reg, %hostname_addr)
	li $v0, SERVER_SOCK_BIND
	move $a0, %ssock_reg
	la $a1, %hostname_addr
	syscall
.end_macro

.macro ssock_accept(%ssock_reg, %dest_reg)
	li $v0, SERVER_SOCK_ACCEPT
	move $a0, %ssock_reg
	syscall
	move %dest_reg, $v1
.end_macro

.macro ssock_close(%ssock_reg)
	li $v0, SERVER_SOCK_CLOSE
	move $a0, %ssock_reg
	syscall
.end_macro

# Utility to close all existing sockets
.macro sock_close_all()
	li $v0, SOCK_CLOSE_ALL
	syscall
.end_macro
