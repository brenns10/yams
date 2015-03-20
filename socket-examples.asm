###
# File; socket-examples.asm
#
# Compile, run, go to http://localhost:19001/index.html to view a demo page.
###

# Syscall numbers
# Client sockets only
.eqv	SOCK_OPEN	100
.eqv	SOCK_WRITE	101
.eqv	SOCK_READ	102
.eqv	SOCK_CLOSE	103
# server socket only
.eqv	SERVER_SOCK_OPEN	110
.eqv	SERVER_SOCK_BIND	111	# doesn't seem to work atm, but we may not need it.
.eqv	SERVER_SOCK_ACCEPT	112
.eqv	SERVER_SOCK_CLOSE	113


# I was also playing around with macros while playing around with sockets. They can
# make the code more C-like, but they have weird properties (i.e. can't accept a literal -1
# as an argument.
.macro exit (%exit_val)
	la $a0, %exit_val
	li $v0, 10
	syscall
.end_macro
.macro print (%str_addr)
	la $a0, %str_addr
	li $v0, 4
	syscall
.end_macro
.macro print_int
	li $v0, 1
	syscall
.end_macro

# Socket Macros
.macro sock_open (%addr, %port)
	la $a0, %addr
	li $a1, %port
	li $v0, SOCK_OPEN
	syscall  #open
.end_macro
.macro sock_write (%data, %max_len)
	move $a0, $s1
	la $a1, %data
	li $a2, %max_len
	li $v0, SOCK_WRITE
	syscall  # write
.end_macro
.macro sock_read (%buff, %max_len)
	move $a0, $s1
	la $a1, %buff
	li $a2, %max_len
	li $v0, SOCK_READ  # read
	syscall
.end_macro
.macro sock_close
	move $a0, $s1
	li $v0, SOCK_CLOSE
	syscall
.end_macro
.macro ssock_open (%port)
	li $a0, %port
	li $v0, SERVER_SOCK_OPEN
	syscall
.end_macro
.macro ssock_bind (%hostnameAddr)
	move $a0, $s0
	la $a1, %hostnameAddr
	li $v0, SERVER_SOCK_BIND
	syscall
.end_macro
.macro ssock_accept
	move $a0, $s0
	li $v0, SERVER_SOCK_ACCEPT
	syscall
.end_macro
.macro ssock_close
	move $a0, $s0
	li $v0, SERVER_SOCK_CLOSE
	syscall
.end_macro

.eqv	NEG_ONE		0xFFFFFFFF  # hackity hack hack hack. macro expansions don't like '-1' for some reason
.eqv	MAX_LEN		16384

.data
localhost: .asciiz	"localhost"
google: .asciiz		"google.com"
req:	.asciiz		"GET /index.html HTTP/1.1\r\nHost: google.com\r\n\r\n"
hwhtml:	.asciiz		"<html><h1>Hello, world!</h1><br/><h4>Served by MIPS and MARS.</h4></html>\r\n\r\n"
buff:	.byte	        0:MAX_LEN
.text
.globl	main
main:
	jal serve_hw
	exit(0)
get_google:
	sock_open(google, 80)
	move $s1, $v1    # To retrieve the socket's FD
	sock_write(req, MAX_LEN)
	sock_read(buff, MAX_LEN)
	sock_close
	print(buff)
	jr $ra
serve_hw:
	ssock_open(19001)
	move $s0, $v1  # move server socket FD to safe place
	ssock_accept
	move $s1, $v1  # get client socket FD
	sock_read(buff, MAX_LEN)
	print(buff)  # print for debugging
	sock_write(hwhtml, NEG_ONE)  # writing to -1 means "read to double CRLF"
	sock_close()
	ssock_close()
	jr $ra
	
