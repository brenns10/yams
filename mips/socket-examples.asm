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
.eqv	SERVER_SOCK_BIND	111	# does not seem to work atm, but we may not need it.
.eqv	SERVER_SOCK_ACCEPT	112
.eqv	SERVER_SOCK_CLOSE	113

# macro includes
.include "util-macros.asm"
.include "socket-macros.asm"

.eqv	MAX_LEN		16384

.data
localhost: .asciiz	"localhost"
google: .asciiz		"google.com"
req:	.ascii		"GET /index.html HTTP/1.1\r\nHost: google.com\r\n\r\n"
req_end:
hwhtml:	.ascii		"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Length: 73\r\nConnection: close\r\n\r\n<html><h1>Hello, world!</h1><br/><h4>Served by MIPS and MARS.</h4></html>"
hwhtml_end:
buff:	.byte	        0:MAX_LEN
ln:	.asciiz		"\n"

.text
.globl	main
main:
	jal serve_hw	# serves a demo HTML page to "localhost:19001"
	#jal get_google	# prints content of "google.com/index.html" to console
	exit(0)

	# serve_hw: demonstration of serving a page in a string
serve_hw:
	li $a0, 19001		# magic port number
	ssock_open($s0)		# open server_socket on 19001 and store FD in $s0
	ssock_accept($s0, $s1)	# accept connection, store client FD in $s1

	# Read in HTTP request
	la $a1, buff
	li $a2, MAX_LEN
	sock_read($s1)		# read up to MAX_LEN bytes into buff from socket w/ FD in $s1
	print(buff)		# print for debugging

	# Write our pre-made response to client
	la $a1, hwhtml
	# compute length of hwhtml
	la $a2, hwhtml_end
	sub $a2, $a2, $a1
	sock_write($s1)		# write $a2 bits from the buffer at $a1

	# view the number of bytes written (-1 == error)
	print_int($v0)
	print(ln)

	# close client and server sockets
	sock_close($s1)
	ssock_close($s0)
	jr $ra

	# get_google: demonstration of contacting Google
get_google:
	# open socket to google.com:80
	la $a0, google
	li $a1, 80
	sock_open($s1)

	# view the FD
	print_int($s1)
	print(ln)

	# Request index.html from gogle
	la $a1, req
	# compute length of req
	la $a2, req_end
	sub $a2, $a2, $a1
	sock_write($s1)

	# view the number of bytes written (-1 == error)
	print_int($v1)
	print(ln)

	# Read response from Google
	la $a1, buff
	li $a2, MAX_LEN
	sock_read($s1)

	# close, print, and exit
	sock_close($s1)
	nop
	print(buff)
	jr $ra
