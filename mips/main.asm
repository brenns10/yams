###
# File; main.asm
#
# The entry assembly file for YAMS.
###

# macro includes
.include "util-macros.asm"
.include "socket-macros.asm"

# module includes at bottom of file (otherwise entry point is messed up)

.eqv	MAX_LEN		16384

.data
hwhtml:	.ascii		"HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Length: 73\r\nConnection: close\r\n\r\n<html><h1>Hello, world!</h1><br/><h4>Served by MIPS and MARS.</h4></html>" 
hwhtml_end:
buff:	.byte	        0:MAX_LEN
	.word		0
ln:	.asciiz		"\n"
.text
.globl	main
main:
	li $a0, 19001		# Port = 19001
	ssock_open($s0)		# open server_socket on 19001 and store FD in $s0
req_loop:
	ssock_accept($s0, $s1)	# accept connection from server_socket in $s0, store client FD in $s1

	# debug prints!
	print_int($v1)
	print(ln)
	
	# read & parse a single request
	move $a0, $s1
	jal get_request
	
	move $s2, $v0	# request type, one of HTTP_GET, HTTP_POST, HTTP_OTHER, HTTP_ERROR
	move $s3, $v1	# req_uri addr
	
	print_int($v0)
	print(ln)

	# dispatch the appropriate handler -- below is only one for now
	la $a1, hwhtml
	# compute length of hwhtml
	la $a2, hwhtml_end
	sub $a2, $a2, $a1
	sock_write($s1)
	
	# we don't bother re-using connections, so we can close.
	sock_close($s1)
	#j req_loop		# handle the next HTTP request
	# end-of-program cleanup
	ssock_close($s0)
	exit(0)

# module includes
.include "http-requests.asm"

